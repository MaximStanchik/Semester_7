import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/app_user.dart';
import '../models/favorite_entry.dart';
import '../models/product.dart';
import '../models/review.dart';

class CompressionStats {
  final int originalBytes;
  final int compressedBytes;
  final String boxPath;
  final DateTime timestamp;

  CompressionStats({
    required this.originalBytes,
    required this.compressedBytes,
    required this.boxPath,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class HiveService {
  HiveService._();


  static final HiveService instance = HiveService._();

  static const String _usersBoxName = 'users_box';
  static const String _productsBoxName = 'products_box';
  static const String _favoritesBoxName = 'favorites_box';
  static const String _compressedBoxName = 'compressed_snapshots';
  static const String _reviewsBoxName = 'reviews_box';

  static final List<AppUser> _seedUsers = [
    AppUser(id: 1, name: 'Анна', role: 'admin'),
    AppUser(id: 2, name: 'Борис', role: 'manager'),
    AppUser(id: 3, name: 'Сергей', role: 'viewer'),
    AppUser(id: 4, name: 'Дарья', role: 'viewer'),
    AppUser(id: 5, name: 'Егор', role: 'viewer'),
  ];

  bool _initialized = false;
  late HiveAesCipher _cipher;
  late Uint8List _primaryKey;

  Box<AppUser>? _usersBox;
  Box<Product>? _productsBox;
  Box<FavoriteEntry>? _favoritesBox;
  Box<Uint8List>? _compressedBox;
  Box<Review>? _reviewsBox;

  Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();
    _registerAdapters();

    _primaryKey = await _loadOrCreateKey('hive_primary.key');
    _cipher = HiveAesCipher(_primaryKey);

    _usersBox = await Hive.openBox<AppUser>(_usersBoxName, encryptionCipher: _cipher);
    _productsBox = await Hive.openBox<Product>(_productsBoxName, encryptionCipher: _cipher);
    _favoritesBox = await Hive.openBox<FavoriteEntry>(_favoritesBoxName, encryptionCipher: _cipher);
    _compressedBox = await Hive.openBox<Uint8List>(_compressedBoxName, encryptionCipher: _cipher);
    _reviewsBox = await Hive.openBox<Review>(_reviewsBoxName, encryptionCipher: _cipher);

    await _ensureSeedData();
    _initialized = true;
  }

  ValueListenable<Box<Product>> watchProducts() => _productsBox!.listenable();

  ValueListenable<Box<FavoriteEntry>> watchFavorites() => _favoritesBox!.listenable();
  ValueListenable<Box<Review>> watchReviews() => _reviewsBox!.listenable();

  List<AppUser> getUsers() => _usersBox!.values.toList();

  Future<String> getKeyFilePath() async {
    final file = await _getKeyFile('hive_primary.key');
    return file.path;
  }

  Future<String> getCompressedBoxPath() async {
    if (_compressedBox?.path != null) return _compressedBox!.path!;
    final dir = await _ensureDocumentsDirectory();
    return p.join(dir.path, '$_compressedBoxName.hive');
  }

  Future<void> addOrUpdateProduct(Product product) async {
    final existingKey = _productsBox!.keys.cast<dynamic>().firstWhere(
          (key) {
            final stored = _productsBox!.get(key);
            return stored?.id == product.id;
          },
          orElse: () => null,
        );
    if (existingKey != null) {
      await _productsBox!.put(existingKey, product);
    } else {
      await _productsBox!.add(product);
    }
  }

  Future<void> deleteProduct(String productId) async {
    final key = _productsBox!.keys.cast<dynamic>().firstWhere(
          (item) => _productsBox!.get(item)?.id == productId,
          orElse: () => null,
        );
    if (key != null) {
      await _productsBox!.delete(key);
    }
    await _favoritesBox!
        .deleteAll(_favoritesBox!.keys.where((k) => _favoritesBox!.get(k)?.productId == productId));
    await _reviewsBox!
        .deleteAll(_reviewsBox!.keys.where((k) => _reviewsBox!.get(k)?.productId == productId));
  }

  Future<void> toggleProductLike(String productId) async {
    for (final key in _productsBox!.keys) {
      final product = _productsBox!.get(key);
      if (product?.id == productId) {
        await _productsBox!.put(key, product!.copyWith(isLiked: !product.isLiked));
        break;
      }
    }
  }

  bool canManageProducts(AppUser user) => user.role == 'admin' || user.role == 'manager';

  Future<void> toggleFavorite(int userId, Product product) async {
    final key = _favoritesBox!.keys.cast<dynamic>().firstWhere(
          (item) {
            final entry = _favoritesBox!.get(item);
            return entry?.userId == userId && entry?.productId == product.id;
          },
          orElse: () => null,
        );
    if (key != null) {
      await _favoritesBox!.delete(key);
    } else {
      await _favoritesBox!.add(FavoriteEntry(userId: userId, productId: product.id));
    }
  }

  bool isFavorite(int userId, Product product) {
    return _favoritesBox!.values.any(
      (entry) => entry.userId == userId && entry.productId == product.id,
    );
  }

  List<Product> getFavoritesForUser(int userId) {
    final favoriteIds = _favoritesBox!.values
        .where((entry) => entry.userId == userId)
        .map((entry) => entry.productId)
        .toSet();
    return _productsBox!.values.where((product) => favoriteIds.contains(product.id)).toList();
  }

  Future<CompressionStats> compressProductsSnapshot() async {
    final payload = _productsBox!.values
        .map(
          (product) => {
            'id': product.id,
            'title': product.title,
            'imagePath': product.imagePath,
            'price': product.price,
            'location': product.location,
            'reviewsCount': product.reviewsCount,
            'description': product.description,
            'isLiked': product.isLiked,
            'createdAt': product.createdAt.toIso8601String(),
          },
        )
        .toList();

    final original = utf8.encode(jsonEncode(payload));
    final compressed = Uint8List.fromList(gzip.encode(original));

    await _compressedBox!.put('latest_snapshot', compressed);

    final boxPath = _compressedBox!.path ?? p.join((await _ensureDocumentsDirectory()).path, '$_compressedBoxName.hive');

    return CompressionStats(
      originalBytes: original.length,
      compressedBytes: compressed.length,
      boxPath: boxPath,
    );
  }

  Future<String> demonstrateWrongKeyRead() async {
    final productsPath = _productsBox?.path ?? '';
    final primaryKeyFile = await _getKeyFile('hive_primary.key');
    final wrongKeyFile = await _getKeyFile('hive_wrong.key');

    await _closeBoxes();
    final wrongKey = await _loadOrCreateKey('hive_wrong.key', cache: false);
    final wrongCipher = HiveAesCipher(wrongKey);

    try {
      final box = await Hive.openBox<Product>(_productsBoxName, encryptionCipher: wrongCipher);
      final _ = box.values.first;
      await box.close();
      return 'Неожиданно удалось прочитать данные с неправильным ключом.\n'
          'Правильный ключ: ${primaryKeyFile.path}\n'
          'Использованный неправильный ключ: ${wrongKeyFile.path}\n'
          'Путь бокса: $productsPath';
    } catch (e) {
      return 'Ошибка чтения с неправильным ключом: $e\n'
          'Правильный ключ: ${primaryKeyFile.path}\n'
          'Использованный неправильный ключ: ${wrongKeyFile.path}\n'
          'Путь бокса: $productsPath';
    } finally {
      await _reopenBoxes();
    }
  }

  Future<void> compactEncryptedBoxes() async {
    await _usersBox?.compact();
    await _productsBox?.compact();
    await _favoritesBox?.compact();
    await _reviewsBox?.compact();
    await _compressedBox?.compact();
  }

  Future<void> _closeBoxes() async {
    await _productsBox?.close();
    await _favoritesBox?.close();
    await _usersBox?.close();
    await _compressedBox?.close();
    await _reviewsBox?.close();
  }

  Future<void> _reopenBoxes() async {
    _usersBox = await Hive.openBox<AppUser>(_usersBoxName, encryptionCipher: _cipher);
    _productsBox = await Hive.openBox<Product>(_productsBoxName, encryptionCipher: _cipher);
    _favoritesBox = await Hive.openBox<FavoriteEntry>(_favoritesBoxName, encryptionCipher: _cipher);
    _compressedBox = await Hive.openBox<Uint8List>(_compressedBoxName, encryptionCipher: _cipher);
    _reviewsBox = await Hive.openBox<Review>(_reviewsBoxName, encryptionCipher: _cipher);
  }

  Future<void> _ensureSeedData() async {
    for (final user in _seedUsers) {
      final exists = _usersBox!.values.any((u) => u.id == user.id);
      if (!exists) {
        await _usersBox!.add(user);
      }
    }
    if (_productsBox!.isEmpty) {
      await _productsBox!.addAll(_seedProducts);
    } else {
      await _migrateProductsAssetsAndReviews();
    }

    if (_reviewsBox!.isEmpty) {
      await _reviewsBox!.addAll(_seedReviews);
    }
  }

  Future<void> _migrateProductsAssetsAndReviews() async {
    final assetMap = <String, String>{
      'hotel_spa': 'img/hotel.jpg',
      'eco_camp': 'img/camping.jpg',
      'city_tour': 'img/tur.jfif',
    };
    for (final key in _productsBox!.keys) {
      final product = _productsBox!.get(key);
      if (product == null) continue;
      final newPath = assetMap[product.id];
      final needsPathUpdate = newPath != null && product.imagePath != newPath;
      final needsReviews = product.reviewsCount <= 0;
      if (needsPathUpdate || needsReviews) {
        await _productsBox!.put(
          key,
          product.copyWith(
            imagePath: needsPathUpdate ? newPath : null,
            reviewsCount: needsReviews ? 1 : null,
          ),
        );
      }
    }
  }

  List<Review> getReviewsForProduct(String productId) {
    return _reviewsBox!.values.where((r) => r.productId == productId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addReview({
    required AppUser author,
    required String productId,
    required int rating,
    required String text,
  }) async {
    final review = Review(
      id: const Uuid().v4(),
      productId: productId,
      userId: author.id.toString(),
      userName: author.name,
      rating: rating,
      comment: text,
    );
    await _reviewsBox!.add(review);
  }

  List<Product> get _seedProducts => [
        Product(
          id: 'hotel_spa',
          title: 'SPA Релакс Отель',
          imagePath: 'img/hotel.jpg',
          price: 120.0,
          location: 'Алматы, Казахстан',
          reviewsCount: 245,
          description: 'Тихий отель с панорамным видом и авторской кухней.',
          isLiked: true,
        ),
        Product(
          id: 'eco_camp',
          title: 'Эко кемпинг',
          imagePath: 'img/camping.jpg',
          price: 45.0,
          location: 'Астана, Казахстан',
          reviewsCount: 87,
          description: 'Глэмпинг с индивидуальными программами отдыха.',
        ),
        Product(
          id: 'city_tour',
          title: 'Авторский тур по городу',
          imagePath: 'img/tur.jfif',
          price: 80.0,
          location: 'Бишкек, Кыргызстан',
          reviewsCount: 120,
          description: 'Персональный маршрут по скрытым местам города.',
        ),
      ];

  List<Review> get _seedReviews => [
        Review(
          id: const Uuid().v4(),
          productId: 'hotel_spa',
          userId: '1',
          userName: 'Анна',
          rating: 5,
          comment: 'Отличное место, сервис на уровне.',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Review(
          id: const Uuid().v4(),
          productId: 'eco_camp',
          userId: '2',
          userName: 'Борис',
          rating: 4,
          comment: 'Чисто, уютно, вернусь ещё.',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AppUserAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ProductAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(FavoriteEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(ReviewAdapter());
    }
  }

  Future<Uint8List> _loadOrCreateKey(String fileName, {bool cache = true}) async {
    final file = await _getKeyFile(fileName);
    if (await file.exists()) {
      return Uint8List.fromList(await file.readAsBytes());
    }
    final generated = Uint8List.fromList(Hive.generateSecureKey());
    await file.writeAsBytes(generated, flush: true);
    if (cache && fileName == 'hive_primary.key') {
      _primaryKey = generated;
    }
    return generated;
  }

  Future<File> _getKeyFile(String fileName) async {
    final dir = await _ensureDocumentsDirectory();
    return File(p.join(dir.path, fileName));
  }

  Directory? _documentsDirectory;

  Future<Directory> _ensureDocumentsDirectory() async {
    if (_documentsDirectory != null) {
      return _documentsDirectory!;
    }
    final dir = await getApplicationDocumentsDirectory();
    _documentsDirectory = dir;
    return dir;
  }
}

