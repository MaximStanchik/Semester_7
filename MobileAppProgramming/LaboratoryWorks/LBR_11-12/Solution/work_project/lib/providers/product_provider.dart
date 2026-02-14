import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../services/hive_service.dart';

class ProductProvider extends ChangeNotifier {
  final HiveService _hiveService = HiveService.instance;
  String _searchQuery = '';

  String get searchQuery => _searchQuery;

  ValueListenable<Box<Product>> watchProducts() => _hiveService.watchProducts();

  List<Product> getProducts() {
    final box = _hiveService.watchProducts().value;
    return box.values.toList();
  }

  List<Product> getFilteredProducts() {
    final products = getProducts();
    if (_searchQuery.isEmpty) {
      return products..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    final filtered = products.where((product) {
      return product.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
    return filtered..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  Future<void> addOrUpdateProduct(Product product) async {
    await _hiveService.addOrUpdateProduct(product);
    notifyListeners();
  }

  Future<void> deleteProduct(String productId) async {
    await _hiveService.deleteProduct(productId);
    notifyListeners();
  }

  Future<void> toggleProductLike(String productId) async {
    await _hiveService.toggleProductLike(productId);
    notifyListeners();
  }
}

