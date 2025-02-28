import yandexcloud
import json
from yandex.cloud.compute.v1.instance_service_pb2 import DeleteInstanceRequest
from yandex.cloud.compute.v1.instance_service_pb2_grpc import InstanceServiceStub


# Загружаем конфигурацию из файла config.json
with open('/mnt/c/Users/serge/Desktop/Letsplay/Tasks/Task_8_SDK-Python/1_python+cloud_api/4_remove_vm.json', 'r') as f:
    config = json.load(f)

# Получаем OAUTH токен из config.json
oauth_token = config['oauth_token']

# Создаем SDK клиент с OAuth токеном
sdk = yandexcloud.SDK(token=oauth_token)

# Создаем клиент для InstanceService
channel = sdk.client(InstanceServiceStub)

# Создаем запрос
request = DeleteInstanceRequest(
    instance_id=config['instance_id'],
)

# Выполняем запрос
try:
    response = channel.Delete(request)
    print(f"VM is removed successfully: {response}")
except Exception as e:
    print(f"Failed to remove VM: {e}")