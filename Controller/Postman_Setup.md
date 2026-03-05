# Настройка Postman для тестирования Controller API

## Шаг 1: Установка Postman

1. Скачайте Postman с официального сайта: https://www.postman.com/downloads/
2. Установите и запустите Postman
3. Создайте аккаунт (опционально, но рекомендуется для синхронизации)

## Шаг 2: Создание коллекции

1. В Postman нажмите **"New"** → **"Collection"**
2. Назовите коллекцию: **"Controller API"**
3. Нажмите **"Create"**

## Шаг 3: Настройка переменных коллекции

1. Откройте созданную коллекцию
2. Перейдите на вкладку **"Variables"**
3. Добавьте следующие переменные:

| Variable | Initial Value | Current Value | Description |
|----------|---------------|---------------|-------------|
| `base_url` | `http://localhost:8777` | `http://localhost:8777` | Базовый URL вашего сервера |
| `access_token` | `your_token_here` | `your_token_here` | Токен доступа от AdaOS |

## Шаг 4: Создание запросов

### Запрос 1: Ping (Проверка подключения)

1. В коллекции нажмите **"Add Request"**
2. Назовите: **"Ping - Test Connection"**
3. Настройте запрос:
   - **Method**: `GET`
   - **URL**: `{{base_url}}/api/ping`
   - **Headers**:
     ```
     Authorization: Bearer {{access_token}}
     Content-Type: application/json
     ```
4. Нажмите **"Save"**

### Запрос 2: Send Input Event (Отправка события ввода)

1. В коллекции нажмите **"Add Request"**
2. Назовите: **"Send Input Event"**
3. Настройте запрос:
   - **Method**: `POST`
   - **URL**: `{{base_url}}/api/input`
   - **Headers**:
     ```
     Authorization: Bearer {{access_token}}
     Content-Type: application/json
     ```
   - **Body** (выберите `raw` → `JSON`):
     ```json
     {
       "type": "mobile_input",
       "device_id": "550e8400-e29b-41d4-a716-446655440000",
       "axes": {
         "x": 0.3,
         "y": -0.7
       },
       "buttons": {
         "A": true,
       "B": false
       },
       "ts": 1732523456123
     }
     ```
4. Нажмите **"Save"**

### Запрос 3: Send Orientation Event (Отправка события ориентации)

1. В коллекции нажмите **"Add Request"**
2. Назовите: **"Send Orientation Event"**
3. Настройте запрос:
   - **Method**: `POST`
   - **URL**: `{{base_url}}/api/orientation`
   - **Headers**:
     ```
     Authorization: Bearer {{access_token}}
     Content-Type: application/json
     ```
   - **Body** (выберите `raw` → `JSON`):
     ```json
     {
       "type": "mobile_orientation",
       "orientation": {
         "qx": 0.0,
         "qy": 0.0,
         "qz": 0.0,
         "qw": 1.0
       }
     }
     ```
4. Нажмите **"Save"**

## Шаг 5: Тестирование

### Тест 1: Проверка подключения
1. Откройте запрос **"Ping - Test Connection"**
2. Убедитесь, что переменные `base_url` и `access_token` заполнены
3. Нажмите **"Send"**
4. Ожидаемый ответ: HTTP 200 OK

### Тест 2: Отправка события ввода
1. Откройте запрос **"Send Input Event"**
2. При необходимости измените значения в JSON body
3. Нажмите **"Send"**
4. Проверьте ответ сервера

### Тест 3: Отправка события ориентации
1. Откройте запрос **"Send Orientation Event"**
2. Измените значения кватерниона в JSON body для тестирования
3. Нажмите **"Send"**

## Шаг 6: Использование с мок-сервером (если нет реального сервера)

Postman может создать мок-сервер для тестирования:

1. В коллекции нажмите **"..."** → **"Mock Collection"**
2. Настройте мок-сервер:
   - Выберите коллекцию
   - Настройте примеры ответов для каждого запроса
3. Получите URL мок-сервера
4. Используйте этот URL в приложении как `base_url`

## Примеры ответов

### Успешный ответ (200 OK)
```json
{
  "status": "ok",
  "message": "Connection successful"
}
```

### Ошибка авторизации (401 Unauthorized)
```json
{
  "error": "Unauthorized",
  "message": "Invalid or missing access token"
}
```

### Ошибка валидации (400 Bad Request)
```json
{
  "error": "Bad Request",
  "message": "Invalid request format"
}
```

## Советы по отладке

1. **Проверка переменных**: Убедитесь, что переменные `base_url` и `access_token` правильно установлены
2. **Логирование**: Используйте вкладку **"Console"** в Postman для просмотра детальных логов запросов
3. **Тесты**: Добавьте автоматические тесты в Postman для проверки ответов:
   ```javascript
   pm.test("Status code is 200", function () {
       pm.response.to.have.status(200);
   });
   ```
4. **Environment**: Создайте разные окружения (Development, Production) для разных серверов

## Импорт готовой коллекции

Если у вас есть JSON файл коллекции Postman, вы можете импортировать его:
1. В Postman нажмите **"Import"**
2. Выберите файл коллекции или вставьте JSON
3. Коллекция будет автоматически создана со всеми запросами

