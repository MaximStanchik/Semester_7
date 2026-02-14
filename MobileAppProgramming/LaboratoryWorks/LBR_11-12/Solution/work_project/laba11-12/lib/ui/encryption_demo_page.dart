import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/hive_boxes.dart';
import '../services/secure_key_service.dart';

class EncryptionDemoPage extends StatefulWidget {
  const EncryptionDemoPage({super.key});

  @override
  State<EncryptionDemoPage> createState() => _EncryptionDemoPageState();
}

class _EncryptionDemoPageState extends State<EncryptionDemoPage> {
  String _wrongKeyResult = '';
  List<int>? _gzData;
  String _compactResult = '';

  Future<void> _tryWrongKey() async {
    final keyService = SecureKeyService();
    final wrong = await keyService.getOrCreateSecondaryKey();
    final err = await HiveBoxes.tryOpenWithWrongKey(wrong);
    setState(() {
      _wrongKeyResult = err == null ? 'Открыто без ошибки (неожиданно)' : 'Ошибка: ${err.toString()}';
    });
  }

  Future<void> _exportGzip() async {
    final data = await HiveBoxes.exportCompressedProducts();
    setState(() => _gzData = data);
  }

  Future<void> _importGzip() async {
    if (_gzData != null) {
      await HiveBoxes.importCompressedProducts(_gzData!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Импортировано из gzip')));
      }
    }
  }

  Future<void> _compactBoxes() async {
    try {
      await HiveBoxes.compactAllBoxes();
      setState(() {
        _compactResult = 'Сжатие выполнено успешно! Все боксы сжаты.';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Сжатие данных выполнено')));
      }
    } catch (e) {
      setState(() {
        _compactResult = 'Ошибка при сжатии: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Шифрование и сжатие')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Демонстрация неверного ключа'),
            ElevatedButton(onPressed: _tryWrongKey, child: const Text('Пробовать открыть с неверным ключом')),
            Text(_wrongKeyResult),
            const SizedBox(height: 24),
            const Text('Экспорт/импорт gzip продуктов'),
            Row(children: [
              ElevatedButton(onPressed: _exportGzip, child: const Text('Экспорт (gzip)')),
              const SizedBox(width: 12),
              ElevatedButton(onPressed: _importGzip, child: const Text('Импорт из gzip')),
            ]),
            if (_gzData != null) Text('Размер gzip: ${_gzData!.length} байт'),
            const SizedBox(height: 24),
            const Text('Сжатие данных в боксах (compact)'),
            ElevatedButton(
              onPressed: _compactBoxes, 
              child: const Text('Сжать все боксы')
            ),
            if (_compactResult.isNotEmpty) Text(_compactResult),
          ],
        ),
      ),
    );
  }
}


