import yandexcloud
import json
from yandex.cloud.compute.v1.instance_service_pb2 import ListInstancesRequest
from yandex.cloud.compute.v1.instance_service_pb2 import StopInstanceRequest
from yandex.cloud.compute.v1.instance_service_pb2 import StartInstanceRequest
from yandex.cloud.compute.v1.instance_service_pb2_grpc import InstanceServiceStub


# Загружаем конфигурацию из файла config.json
with open('/mnt/c/Users/serge/Desktop/Letsplay/Tasks/Task_8_SDK-Python/1_python+cloud_api/start_stop_all_vm.json', 'r') as f:
    config = json.load(f)

# Получаем OAUTH токен из config.json
oauth_token = config['oauth_token']

# Создаем SDK клиент с OAuth токеном
sdk = yandexcloud.SDK(token=oauth_token)

# Создаем клиент для InstanceService
channel = sdk.client(InstanceServiceStub)

# Создать запрос для получения всех vms
list_request = ListInstancesRequest(folder_id=config['folder_id'])

# Выполнить запрос и получить список инстансов
response = channel.List(list_request)
print(response)

# Создать запрос для остановки всех vm's
for instance in response.instances:
    if instance.status == 2:
        stop_request = StopInstanceRequest(instance_id=instance.id)
        channel.Stop(stop_request)
        print(f"Stopped: {instance.name} (ID: {instance.id})")
    else:
        print("instances to stop: 0")

# Создать запрос для старта всех vm's
# for instance in response.instances:
#     if instance.status == 4:
#         start_request = StartInstanceRequest(instance_id=instance.id)
#         channel.Start(start_request)
#         print(f"Started: {instance.name} (ID: {instance.id})")
#     else:
#         print("instances to run: 0")
        