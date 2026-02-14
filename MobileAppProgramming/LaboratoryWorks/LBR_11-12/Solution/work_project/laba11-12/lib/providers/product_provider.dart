import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  final CollectionReference _productsCollection = FirebaseService.firestore.collection('products');

  List<Product> get products => _products;

  ProductProvider() {
    _initializeProducts();
    _subscribeToProducts();
  }

  Future<void> _initializeProducts() async {
    // Check if products exist, if not create demo products
    final snapshot = await _productsCollection.limit(1).get();
    if (snapshot.docs.isEmpty) {
      await _createDemoProducts();
    }
  }

  Future<void> _createDemoProducts() async {
    final demoProducts = [
      Product(
        id: '1',
        title: 'Рим - Флоренция',
        imagePath: 'assets/mountain.jpg',
        price: 120.0,
        location: 'Италия',
        reviewsCount: 45,
        description: 'Комфортная поездка по живописной Тоскане',
        liked: false,
      ),
      Product(
        id: '2',
        title: 'Париж - Лондон',
        imagePath: 'assets/forest.jpg',
        price: 85.0,
        location: 'Европа',
        reviewsCount: 32,
        description: 'Быстрое путешествие через Ла-Манш',
        liked: true,
      ),
      Product(
        id: '3',
        title: 'Токио - Осака',
        imagePath: 'assets/beach.jpg',
        price: 95.0,
        location: 'Япония',
        reviewsCount: 28,
        description: 'Скоростной поезд по японским пейзажам',
        liked: false,
      ),
    ];

    for (final product in demoProducts) {
      await _productsCollection.doc(product.id).set(product.toMap());
    }
  }

  void _subscribeToProducts() {
    _productsCollection.snapshots().listen((snapshot) {
      _products = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product.fromMap(data);
      }).toList();
      notifyListeners();
    });
  }

  Future<void> addProduct(Product product) async {
    await _productsCollection.doc(product.id).set(product.toMap());
    // Data will be updated via snapshot listener
  }

  Future<void> updateProduct(Product product) async {
    await _productsCollection.doc(product.id).update(product.toMap());
    // Data will be updated via snapshot listener
  }

  Future<void> deleteProduct(String productId) async {
    await _productsCollection.doc(productId).delete();
    // Data will be updated via snapshot listener
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Product> getProductsByLocation(String location) {
    return _products.where((product) =>
      product.location.toLowerCase().contains(location.toLowerCase())
    ).toList();
  }

  List<Product> getLikedProducts() {
    return _products.where((product) => product.liked).toList();
  }

  Future<void> toggleProductLike(String productId) async {
    final product = getProductById(productId);
    if (product != null) {
      final updatedProduct = Product(
        id: product.id,
        title: product.title,
        imagePath: product.imagePath,
        price: product.price,
        location: product.location,
        reviewsCount: product.reviewsCount,
        description: product.description,
        liked: !product.liked,
      );
      await updateProduct(updatedProduct);
    }
  }
}
