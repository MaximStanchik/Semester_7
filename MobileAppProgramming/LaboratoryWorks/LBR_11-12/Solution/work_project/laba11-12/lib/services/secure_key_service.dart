import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SecureKeyService {
  static const String primaryKeyFile = 'hive_primary.key';
  static const String secondaryKeyFile = 'hive_secondary.key';

  Future<File> _file(String name) async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$name');
  }

  Future<Uint8List> _generateKey() async {
    final rnd = Random.secure();
    final key = List<int>.generate(32, (_) => rnd.nextInt(256));
    return Uint8List.fromList(key);
  }

  Future<Uint8List> getOrCreatePrimaryKey() async {
    final f = await _file(primaryKeyFile);
    if (await f.exists()) {
      final bytes = await f.readAsBytes();
      return Uint8List.fromList(bytes);
    }
    final key = await _generateKey();
    await f.writeAsBytes(key, flush: true);
    return key;
  }

  Future<Uint8List> getOrCreateSecondaryKey() async {
    final f = await _file(secondaryKeyFile);
    if (await f.exists()) {
      final bytes = await f.readAsBytes();
      return Uint8List.fromList(bytes);
    }
    final key = await _generateKey();
    await f.writeAsBytes(key, flush: true);
    return key;
  }
}


