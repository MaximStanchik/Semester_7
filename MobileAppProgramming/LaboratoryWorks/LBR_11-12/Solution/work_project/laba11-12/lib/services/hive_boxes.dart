import 'dart:typed_data';
import 'dart:convert';

import 'package:archive/archive_io.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/user.dart';
import '../models/product.dart';
import '../models/favorite.dart';
import '../models/history.dart';
import 'secure_key_service.dart';
import '../models/adapters.dart';

class HiveBoxes {
  static const String users = 'users_box';
  static const String products = 'products_box';
  static const String favorites = 'favorites_box';
  static const String history = 'history_box';

  static Future<void> registerAdapters() async {
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(UserRoleAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(AppUserAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(ProductAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(FavoriteItemAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(SearchHistoryAdapter());
  }

  static Future<void> openAll({required Uint8List key}) async {
    await Hive.openBox<AppUser>(users, encryptionCipher: HiveAesCipher(key));
    await Hive.openBox<Product>(products, encryptionCipher: HiveAesCipher(key));
    await Hive.openBox<FavoriteItem>(favorites, encryptionCipher: HiveAesCipher(key));
    await Hive.openBox<SearchHistory>(history, encryptionCipher: HiveAesCipher(key));
  }

  // Демонстрация чтения с неверным ключом (упадёт при доступе)
  static Future<Exception?> tryOpenWithWrongKey(Uint8List wrongKey) async {
    try {
      final box = await Hive.openBox<Product>(
        '${products}_wrong',
        encryptionCipher: HiveAesCipher(wrongKey),
      );
      await box.close();
      return null;
    } catch (e) {
      return e is Exception ? e : Exception(e.toString());
    }
  }

  // Сжатие: выгрузить содержимое бокса -> json bytes -> gzip -> хранить в отдельном боксе/ключе
  static Future<List<int>> exportCompressedProducts() async {
    final box = Hive.box<Product>(products);
    final list = box.values
        .map((p) => {
              'id': p.id,
              'title': p.title,
              'imagePath': p.imagePath,
              'price': p.price,
              'location': p.location,
              'reviewsCount': p.reviewsCount,
              'description': p.description,
              'liked': p.liked,
            })
        .toList();
    final jsonStr = jsonEncode(list);
    final bytes = Uint8List.fromList(jsonStr.codeUnits);
    final encoder = GZipEncoder();
    return encoder.encode(bytes) ?? <int>[];
  }

  static Future<void> importCompressedProducts(List<int> gzBytes) async {
    final decoder = GZipDecoder();
    final decoded = decoder.decodeBytes(gzBytes);
    final jsonStr = String.fromCharCodes(decoded);
    final dynamic data = jsonDecode(jsonStr);
    if (data is List) {
      final box = Hive.box<Product>(products);
      for (final item in data) {
        final p = Product(
          id: item['id'] as String,
          title: item['title'] as String,
          imagePath: item['imagePath'] as String,
          price: (item['price'] as num).toDouble(),
          location: item['location'] as String,
          reviewsCount: item['reviewsCount'] as int,
          description: item['description'] as String,
          liked: item['liked'] as bool,
        );
        await box.put(p.id, p);
      }
    }
  }

  // Сжатие
  static Future<void> compactAllBoxes() async {
    final boxes = [
      Hive.box<AppUser>(users),
      Hive.box<Product>(products),
      Hive.box<FavoriteItem>(favorites),
      Hive.box<SearchHistory>(history),
    ];
    
    for (final box in boxes) {
      await box.compact();
    }
  }
}


