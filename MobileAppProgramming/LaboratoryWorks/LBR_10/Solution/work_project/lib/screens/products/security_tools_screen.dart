import 'package:flutter/material.dart';

import '../../services/hive_service.dart';

class SecurityToolsScreen extends StatefulWidget {
  const SecurityToolsScreen({super.key});

  @override
  State<SecurityToolsScreen> createState() => _SecurityToolsScreenState();
}

class _SecurityToolsScreenState extends State<SecurityToolsScreen> {
  String? _status;
  final HiveService _hiveService = HiveService.instance;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
    );
  }
}

