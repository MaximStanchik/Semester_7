# Firebase Setup Instructions

## Обзор
Приложение интегрировано с Firebase. Для работы необходимо настроить Firebase проект.

## Требуемые сервисы Firebase

1. **Firebase Authentication**
   - Email/Password провайдер
   - Google Sign-In провайдер

2. **Cloud Firestore**
   - Коллекции: `users`, `products`, `favorites`, `history`
   - Включена оффлайн персистентность

3. **Realtime Database**
   - Путь: `user_status/{userId}`
   - Структура: `{status: 'online'|'offline', lastSeen: timestamp}`

4. **Firebase Cloud Messaging**
   - Для push-уведомлений

5. **Firebase Remote Config**
   - Параметры:
     - `like_button_enabled` (boolean, default: true)
     - `block_color` (string, default: "#2841E3")

6. **Firebase Analytics**
   - Автоматически отслеживаются события

## Шаги настройки

### 1. Создание Firebase проекта
1. Перейдите на https://console.firebase.google.com/
2. Создайте новый проект
3. Добавьте Android/iOS приложение

### 2. Android настройка
1. Скачайте `google-services.json`
2. Поместите в `android/app/`
3. Добавьте в `android/build.gradle`:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
   }
   ```
4. Добавьте в `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

### 3. iOS настройка
1. Скачайте `GoogleService-Info.plist` из Firebase Console
2. Поместите файл в папку `ios/Runner/` (на том же уровне, что и `Info.plist`)
3. Откройте проект в Xcode:
   - Откройте `ios/Runner.xcworkspace` (важно: .xcworkspace, а не .xcodeproj)
   - В Xcode: перетащите `GoogleService-Info.plist` из Finder в папку `Runner` в навигаторе проекта
   - Убедитесь, что в диалоговом окне выбрано "Copy items if needed" и "Runner" в "Add to targets"
4. Установите iOS SDK через CocoaPods:
   - Откройте терминал в папке `ios/`
   - Выполните: `pod install`
   - Если CocoaPods не установлен: `sudo gem install cocoapods`

### 4. Включение Authentication
1. В Firebase Console → Authentication → Sign-in method
2. Включите Email/Password
3. Включите Google Sign-In (настройте OAuth consent screen)

### 5. Настройка Firestore
1. Firebase Console → Firestore Database
2. Создайте базу данных в режиме test mode (или настройте правила)
3. Правила безопасности (пример):
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       match /products/{productId} {
         allow read: if true;
         allow write: if request.auth != null;
       }
       match /favorites/{favoriteId} {
         allow read, write: if request.auth != null;
       }
       match /history/{historyId} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

### 6. Настройка Realtime Database
1. Firebase Console → Realtime Database
2. Создайте базу данных
3. Правила безопасности:
   ```json
   {
     "rules": {
       "user_status": {
         "$userId": {
           ".read": "$userId === auth.uid",
           ".write": "$userId === auth.uid"
         }
       }
     }
   }
   ```

### 7. Настройка Remote Config
1. Firebase Console → Remote Config
2. Добавьте параметры:
   - `like_button_enabled`: boolean, default: true
   - `block_color`: string, default: "#2841E3"

### 8. Настройка Cloud Messaging
1. Firebase Console → Cloud Messaging
2. Для Android: добавьте серверный ключ в настройки
3. Для iOS: загрузите APNs сертификат

## Оффлайн режим
Firestore автоматически поддерживает оффлайн режим. Данные синхронизируются при восстановлении соединения.

## Тестирование
1. Зарегистрируйте пользователя через Email/Password
2. Войдите через Google
3. Проверьте работу CRUD операций
4. Отключите интернет и проверьте оффлайн режим
5. Включите интернет и проверьте синхронизацию

## Analytics события
Приложение отслеживает следующие события:
1. `login` - вход пользователя
2. `sign_up` - регистрация пользователя
3. `search` - поиск поездок
4. `product_liked` - лайк продукта
5. `product_favorited` - добавление в избранное
6. `product_edited` - редактирование продукта
7. `product_deleted` - удаление продукта

