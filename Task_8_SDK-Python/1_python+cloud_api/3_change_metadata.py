import yandexcloud
import json
from yandex.cloud.compute.v1.instance_service_pb2 import UpdateInstanceMetadataRequest
from yandex.cloud.compute.v1.instance_service_pb2_grpc import InstanceServiceStub


# Загружаем конфигурацию из файла config.json
with open('/mnt/c/Users/serge/Desktop/Letsplay/Tasks/Task_8_SDK-Python/1_python+cloud_api/3_change_metadata.json', 'r') as f:
    config = json.load(f)

# Получаем OAUTH токен из config.json
oauth_token = config['oauth_token']

# Создаем SDK клиент с OAuth токеном
sdk = yandexcloud.SDK(token=oauth_token)

# Создаем клиент для InstanceService
channel = sdk.client(InstanceServiceStub)

# Создаем запрос
request = UpdateInstanceMetadataRequest(
    instance_id=config['instance_id'],
    delete=config['delete'],
    upsert=config['upsert']
)

# Выполняем запрос
try:
    response = channel.UpdateMetadata(request)
    print(f"Metadata updated successfully: {response}")
except Exception as e:
    print(f"Failed to update metadata: {e}")