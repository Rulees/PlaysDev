
<?php
$lat = '44.34';
$lon = '10.99';
$appid = '83b957412ed2412dd318faac5264a660';  // твой API ключ

// Строим URL для API запроса
$url = "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$appid";

// Получаем данные с OpenWeatherMap
$response = file_get_contents($url);
$data = json_decode($response, true);  // Декодируем JSON ответ

// Проверяем, есть ли данные
if ($data && $data['cod'] == 200) {
    $city = $data['name'];
    $temperature = $data['main']['temp'] - 273.15;  // Преобразуем температуру в °C
    $weather = $data['weather'][0]['description'];
    $icon = "https://openweathermap.org/img/wn/" . $data['weather'][0]['icon'] . ".png";
    $humidity = $data['main']['humidity'];
    $wind_speed = $data['wind']['speed'];
    $sunrise = date('H:i:s', $data['sys']['sunrise']);
    $sunset = date('H:i:s', $data['sys']['sunset']);
} else {
    echo "Ошибка при получении данных.";
    exit;
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Weather Information</title>
</head>
<body>
    <h1>Weather Information for <?= $city ?></h1>
    <img src="<?= $icon ?>" alt="weather icon" />
    <p><strong>Temperature:</strong> <?= number_format($temperature, 2) ?> °C</p>
    <p><strong>Weather:</strong> <?= ucfirst($weather) ?></p>
    <p><strong>Humidity:</strong> <?= $humidity ?>%</p>
    <p><strong>Wind Speed:</strong> <?= $wind_speed ?> m/s</p>
    <p><strong>Sunrise:</strong> <?= $sunrise ?></p>
    <p><strong>Sunset:</strong> <?= $sunset ?></p>
</body>
</html>
