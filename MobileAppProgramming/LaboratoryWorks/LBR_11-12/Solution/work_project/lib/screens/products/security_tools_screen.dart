import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../../services/hive_service.dart';
import '../../services/notification_service.dart';
import '../../services/remote_config_service.dart';
import '../analytics_demo_screen.dart';
import '../all_users_status_screen.dart';
import '../current_user_screen.dart';
import '../auth/change_password_screen.dart';

class SecurityToolsScreen extends StatefulWidget {
  const SecurityToolsScreen({super.key});

  @override
  State<SecurityToolsScreen> createState() => _SecurityToolsScreenState();
}

class _SecurityToolsScreenState extends State<SecurityToolsScreen> {
  String? _status;
  final HiveService _hiveService = HiveService.instance;
  final RemoteConfigService _remoteConfig = RemoteConfigService.instance;
  bool _firestoreOffline = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Безопасность')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
          leading: Icon(_firestoreOffline ? Icons.cloud_off : Icons.cloud_queue),
          title: Text(_firestoreOffline ? 'Firestore: офлайн (симуляция)' : 'Firestore: онлайн'),
          subtitle: const Text('Для демонстрации синхронизации без интернета'),
          onTap: () async {
            try {
              if (_firestoreOffline) {
                await FirebaseFirestore.instance.enableNetwork();
              } else {
                await FirebaseFirestore.instance.disableNetwork();
              }
              setState(() {
                _firestoreOffline = !_firestoreOffline;
                _status = _firestoreOffline
                    ? 'Firestore network: DISABLED (работаем офлайн, данные в кеше)'
                    : 'Firestore network: ENABLED (синхронизация включена)';
              });
            } catch (e) {
              setState(() => _status = 'Ошибка Firestore network toggle: ${e.toString()}');
            }
          },
          ),
          ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Показать FCM token'),
          subtitle: const Text('Нужен для отправки тестового push на устройство'),
          onTap: () async {
            final token = await NotificationService.instance.getToken();
            setState(() => _status = token == null ? 'FCM token: null' : 'FCM token: $token');
          },
          ),
          ListTile(
          leading: const Icon(Icons.cloud_sync),
          title: const Text('Обновить Remote Config'),
          subtitle: const Text('likes_enabled, progress_card_color, product_card_color'),
          onTap: () async {
            try {
              final activated = await _remoteConfig.refresh();

              final rc = FirebaseRemoteConfig.instance;
              setState(
                () => _status =
                    'activated: $activated\n'
                    'lastFetchStatus: ${rc.lastFetchStatus}\n'
                    'lastFetchTime: ${rc.lastFetchTime.toLocal()}\n'
                    'likes_enabled: ${_remoteConfig.likesEnabled.value}\n'
                    'progress_card_color: ${_remoteConfig.progressCardColor.value}\n'
                    'product_card_color: ${_remoteConfig.productCardColor.value}\n'
                    'product_card_color_raw: ${rc.getString('product_card_color')}',
              );
            } catch (e) {
              setState(() => _status = 'Ошибка Remote Config refresh: ${e.toString()}');
            }
          },
          ),
          ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Текущий пользователь'),
          subtitle: const Text('Профиль и статус online/offline'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CurrentUserScreen()),
            );
          },
          ),
          ListTile(
          leading: const Icon(Icons.people),
          title: const Text('Все пользователи'),
          subtitle: const Text('Список пользователей и статус online/offline'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AllUsersStatusScreen()),
            );
          },
          ),
          ListTile(
          leading: const Icon(Icons.analytics_outlined),
          title: const Text('Analytics (демо)'),
          subtitle: const Text('Сгенерировать 5+ событий для Firebase Analytics'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AnalyticsDemoScreen()),
            );
          },
          ),
          ListTile(
          leading: const Icon(Icons.password),
          title: const Text('Сменить пароль'),
          subtitle: const Text('Для аккаунтов с Email/Password'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            );
          },
          ),
          ListTile(
          leading: const Icon(Icons.key),
          title: const Text('Показать путь к ключу шифрования'),
          subtitle: const Text('Ключ хранится во внутренней памяти устройства'),
          onTap: () async {
            final path = await _hiveService.getKeyFilePath();
            setState(() => _status = 'Ключ: $path');
          },
          ),
          ListTile(
          leading: const Icon(Icons.compress),
          title: const Text('Сжать данные бокса'),
          subtitle: const Text('Экспорт и gzip-сжатие текущего содержимого'),
          onTap: () async {
            final stats = await _hiveService.compressProductsSnapshot();
            setState(
              () => _status =
                  'Сжатие выполнено: ${stats.originalBytes}B → ${stats.compressedBytes}B\n'
                  'Путь файла: ${stats.boxPath}',
            );
          },
          ),
          ListTile(
          leading: const Icon(Icons.data_usage),
          title: const Text('Компактировать зашифрованные боксы'),
          subtitle: const Text('Hive compact() + данные остаются зашифрованными'),
          onTap: () async {
            await _hiveService.compactEncryptedBoxes();
            setState(() => _status = 'Компактация выполнена.');
          },
          ),
          ListTile(
          leading: const Icon(Icons.folder),
          title: const Text('Где хранится сжатое содержимое'),
          subtitle: const Text('Путь к box compressed_snapshots'),
          onTap: () async {
            final path = await _hiveService.getCompressedBoxPath();
            setState(() => _status = 'compressed_snapshots: $path');
          },
          ),
          ListTile(
          leading: const Icon(Icons.lock_open),
          title: const Text('Попытка чтения с неправильным ключом'),
          subtitle: const Text('Корректное отображение ошибки'),
          onTap: () async {
            final message = await _hiveService.demonstrateWrongKeyRead();
            setState(() => _status = message);
          },
          ),
          if (_status != null)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_status!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

