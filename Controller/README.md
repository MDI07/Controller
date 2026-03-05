# Controller - Универсальный мобильный контроллер

iOS-приложение, которое превращает ваш iPhone/iPad в универсальный контроллер (джойстик/кнопки/гироскоп) для подключения к серверу AdaOS.

## Функционал

### 1. Экран подключения
- Поля для ввода:
  - **Hub URL** (например, `https://example.com:8777`)
  - **Access Token** (строка, выданная AdaOS)
- Кнопка **Connect** для проверки подключения
- После успешного подключения к `/api/ping` показывает статус "Connected to [URL]"
- Настройки сохраняются автоматически

### 2. Экран контроллера
- **Виртуальный джойстик** (ось X/Y) - перетаскивание для управления
- **2 кнопки**: A и B
- При изменении состояния отправляет JSON-события на сервер:
```json
{
  "type": "mobile_input",
  "device_id": "UUID устройства",
  "axes": { "x": 0.3, "y": -0.7 },
  "buttons": { "A": true, "B": false },
  "ts": 1732523456123
}
```

### 3. Дополнительные возможности
- **Гироскоп/Акселерометр**: автоматическое чтение ориентации устройства и отправка каждые 100мс:
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
- **Лог событий**: отображение последних отправленных событий на экране (для отладки)

## Архитектура проекта

```
Controller/
├── Controller/
│   ├── Models/
│   │   ├── InputEvent.swift          # Модели событий ввода
│   │   └── ConnectionSettings.swift  # Настройки подключения
│   ├── Views/
│   │   ├── ConnectionView.swift      # Экран подключения
│   │   └── ControllerView.swift      # Экран контроллера
│   ├── Managers/
│   │   ├── NetworkManager.swift      # Управление сетевыми запросами
│   │   └── MotionManager.swift       # Управление гироскопом
│   ├── Components/
│   │   ├── VirtualJoystick.swift     # Компонент виртуального джойстика
│   │   └── GameButton.swift          # Компонент игровой кнопки
│   ├── ContentView.swift             # Главный view с навигацией
│   └── ControllerApp.swift           # Точка входа приложения
└── README.md
```

## Требования

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

### Настройка Info.plist

Для работы гироскопа необходимо добавить описание использования Motion в настройках проекта:

1. Откройте проект в Xcode
2. Выберите target "Controller"
3. Перейдите на вкладку "Info"
4. Добавьте ключ `NSMotionUsageDescription` со значением: `"This app uses motion sensors to send device orientation data to the controller server."`

Или добавьте в Build Settings:
- `INFOPLIST_KEY_NSMotionUsageDescription` = `"This app uses motion sensors to send device orientation data to the controller server."`

## Сборка проекта

1. Откройте `Controller.xcodeproj` в Xcode
2. Выберите целевое устройство (iPhone/iPad) или симулятор
3. Нажмите `Cmd + R` для сборки и запуска

## Настройка

### Настройка URL и токена

1. При первом запуске откроется экран подключения
2. Введите **Hub URL** вашего сервера (например, `https://192.168.1.100:8777`)
3. Введите **Access Token**, выданный AdaOS
4. Нажмите **Connect**
5. При успешном подключении откроется экран контроллера

Настройки автоматически сохраняются и загружаются при следующем запуске.

### API Endpoints

Приложение ожидает следующие endpoints на сервере:

- `GET /api/ping` - проверка подключения
  - Headers: `Authorization: Bearer <token>`
  - Response: HTTP 200 при успехе

- `POST /api/input` - отправка событий ввода
  - Headers: `Authorization: Bearer <token>`, `Content-Type: application/json`
  - Body: JSON с событием `mobile_input`

- `POST /api/orientation` - отправка событий ориентации
  - Headers: `Authorization: Bearer <token>`, `Content-Type: application/json`
  - Body: JSON с событием `mobile_orientation`

## Формат событий

### Событие ввода (mobile_input)
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

- `axes.x`, `axes.y`: значения от -1.0 до 1.0
- `buttons.A`, `buttons.B`: булевы значения
- `ts`: timestamp в миллисекундах

### Событие ориентации (mobile_orientation)
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

- Кватернион ориентации устройства
- Отправляется каждые 100мс при активном подключении

## Разработка

### Добавление новых компонентов

1. **Модели**: добавьте в `Models/`
2. **UI компоненты**: добавьте в `Components/`
3. **Экраны**: добавьте в `Views/`
4. **Логика**: добавьте в `Managers/`

### Тестирование с Postman

Для тестирования API без реального сервера используйте Postman:

1. **Импорт коллекции**:
   - Откройте Postman
   - Нажмите **"Import"**
   - Выберите файл `Controller_API.postman_collection.json` из корня проекта
   - Коллекция будет автоматически создана со всеми запросами

2. **Настройка переменных**:
   - Откройте коллекцию **"Controller API"**
   - Перейдите на вкладку **"Variables"**
   - Установите:
     - `base_url`: URL вашего сервера (например, `http://localhost:8777`)
     - `access_token`: ваш токен доступа

3. **Тестирование запросов**:
   - **Ping**: Проверка подключения к серверу
   - **Send Input Event**: Тестирование отправки событий ввода
   - **Send Orientation Event**: Тестирование отправки событий ориентации

4. **Создание Mock сервера** (опционально):
   - В коллекции нажмите **"..."** → **"Mock Collection"**
   - Настройте примеры ответов
   - Используйте URL мок-сервера в приложении

Подробная инструкция по настройке Postman находится в файле `Postman_Setup.md`.

### Другие инструменты для тестирования

- [ngrok](https://ngrok.com/) для туннелирования локального сервера
- [httpie](https://httpie.io/) для командной строки

## Лицензия

Проект создан для использования с AdaOS.

