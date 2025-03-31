#!/usr/bin/env python3

from __future__ import (absolute_import, division, print_function)

from ansible.errors import AnsibleError
from ansible.plugins.inventory import BaseInventoryPlugin, Constructable, Cacheable
from ansible.utils.display import Display
import yandexcloud
import os
import sys
import json
import yaml
import argparse
from google.protobuf.json_format import MessageToDict
from yandex.cloud.compute.v1.instance_service_pb2_grpc import InstanceServiceStub
from yandex.cloud.compute.v1.instance_service_pb2 import ListInstancesRequest
from yandex.cloud.resourcemanager.v1.cloud_service_pb2 import ListCloudsRequest
from yandex.cloud.resourcemanager.v1.cloud_service_pb2_grpc import CloudServiceStub
from yandex.cloud.resourcemanager.v1.folder_service_pb2 import ListFoldersRequest
from yandex.cloud.resourcemanager.v1.folder_service_pb2_grpc import FolderServiceStub

display = Display()

class InventoryModule(BaseInventoryPlugin, Constructable, Cacheable):

    NAME = 'yc_compute'

    def verify_file(self, path):
        return True

    def __init__(self):
        """Теперь инициализация конфигурации происходит внутри parse."""
        super(InventoryModule, self).__init__()
        self.inventory = {}
        self.args = sys.argv
        self.list = '--list' in self.args
        self.host = '--host' in self.args

    def _load_config(self, path):
        """Загружаем конфигурацию из YAML файла."""
        try:
            with open(path, 'r') as file:
                return yaml.safe_load(file)
        except Exception as e:
            raise AnsibleError(f"Не удалось загрузить конфигурацию из {path}: {str(e)}")

    def _init_client(self, config):
        """Инициализация клиента Yandex Cloud SDK с токеном."""
        token = os.getenv("OAUTH_TOKEN", None)
        if not token:
            token = config.get('yc_token', None)

        if not token:
            raise AnsibleError("Токен Yandex Cloud (OAUTH_TOKEN) отсутствует.")
        
        sdk = yandexcloud.SDK(token=token)
        self.instance_service = sdk.client(InstanceServiceStub)
        self.folder_service = sdk.client(FolderServiceStub)
        self.cloud_service = sdk.client(CloudServiceStub)

    def _get_clouds(self, config):
        """Получаем облака из Yandex Cloud."""
        all_clouds = MessageToDict(self.cloud_service.List(ListCloudsRequest()))["clouds"]
        # Фильтруем облака, если в конфиге указаны yc_clouds
        return [cloud for cloud in all_clouds if cloud['name'] in config.get('yc_clouds', [])]

    def _get_folders(self, cloud_id, config):
        """Получаем папки из облака Yandex Cloud."""
        all_folders = MessageToDict(self.folder_service.List(ListFoldersRequest(cloud_id=cloud_id)))["folders"]
        # Фильтруем папки, если в конфиге указаны yc_folders
        return [folder for folder in all_folders if folder['name'] in config.get('yc_folders', [])]

    def _get_all_hosts(self, config):
        """Получаем все хосты из папок в Yandex Cloud."""
        hosts = []
        for cloud in self._get_clouds(config):
            for folder in self._get_folders(cloud["id"], config):
                instances = self.instance_service.List(ListInstancesRequest(folder_id=folder["id"]))
                dict_ = MessageToDict(instances)
                if dict_:
                    hosts += dict_["instances"]
                else:
                    print(f"Warning: No instances found in folder {folder['name']}")
        return hosts


    def _process_hosts(self, hosts, config):
        """Processes hosts and creates a valid Ansible inventory structure without _meta."""

        inventory = {
            "all": {
                "hosts": {},  # Dictionary to hold hosts with variables
                "children": {
                    "yandex_dynamic": {
                        "hosts": {}
                    }
                }
            }
        }

        group_label = config.get('yc_group_label', "yandex_dynamic")

        for host in hosts:
            # Process only running instances
            if host["status"] != "RUNNING":
                continue

            # Get the IP address for the instance
            ip = self._get_ip_for_instance(host)
            if ip:
                host["ansible_host"] = ip  

            # Store host variables under all.hosts
            inventory["all"]["hosts"][host["name"]] = {
                "ansible_host": host["ansible_host"]
            }

            # Add host to 'yandex_dynamic' group
            inventory["all"]["children"]["yandex_dynamic"]["hosts"][host["name"]] = {}

            # Process dynamic groups from labels
            if "labels" in host:
                for label_key, label_value in host["labels"].items():
                    if label_value:  
                        key_value_group = f"{label_key}_{label_value}"
                        if key_value_group not in inventory["all"]["children"]:
                            inventory["all"]["children"][key_value_group] = {"hosts": {}}
                        inventory["all"]["children"][key_value_group]["hosts"][host["name"]] = {}

                    key_only_group = label_key
                    if key_only_group not in inventory["all"]["children"]:
                        inventory["all"]["children"][key_only_group] = {"hosts": {}}
                    inventory["all"]["children"][key_only_group]["hosts"][host["name"]] = {}
            

        return inventory

    def parse(self, inventory, loader, path, cache=True):
        """Парсим аргументы и обрабатываем инвентарь."""
        super(InventoryModule, self).parse(inventory, loader, path, cache=cache)

        # Чтение конфигурации
        config = self._load_config(path)
        
        # Инициализация клиента
        self._init_client(config)

        # Получение хостов
        hosts = self._get_all_hosts(config)

        # Обработка хостов
        inventory_data = self._process_hosts(hosts, config)

        # Output to console .yml inventory
        if self.list:
            print(yaml.dump(inventory_data))
        
        # Write to file .yml inventory:  IF: 1) inside /inventory 2) if /inventory is inside folder 3) Ask about path to store 
        cwd = os.getcwd()
        script_dir = os.path.dirname(os.path.abspath(__file__))
        inventory_dir = os.path.join(cwd, "inventory")

        if cwd == script_dir:
            output_dir = cwd
        elif os.path.isdir(inventory_dir):
            output_dir = inventory_dir
        else:
            output_dir = input("Enter the directory path to store the file: ").strip()
            if not os.path.isdir(output_dir):
                exit("Invalid path. File will not be written.")

        output_file = os.path.join(output_dir, "hosts_yc_dynamic.yml")

        if self.list:
            with open(output_file, "w") as f:
                yaml.dump(inventory_data, f)
        else:
            exit("No arguments passed. Expected --list")


    def _get_ip_for_instance(self, instance):
        """Get the IP address for the instance."""
        interfaces = instance["networkInterfaces"]
        for interface in interfaces:
            address = interface["primaryV4Address"]
            if address:
                if address.get("oneToOneNat"):
                    return address["oneToOneNat"]["address"]
                else:
                    return address["address"]
        return None


if __name__ == "__main__":
    inventory = InventoryModule()
    inventory.parse(None, None, "/mnt/c/Users/serge/Desktop/Letsplay/Tasks/Task_4_Nginx__Dynamic-Inventory__Terraform-for_each/2_ansible/inventory/yc_compute.yml")
