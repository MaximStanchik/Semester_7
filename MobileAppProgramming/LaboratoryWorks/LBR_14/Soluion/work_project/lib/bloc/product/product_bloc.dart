import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/product.dart';
import '../../services/hive_service.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final HiveService _hiveService = HiveService.instance;
  String _searchQuery = '';

  ProductBloc() : super(const ProductInitial()) {
    on<ProductLoadRequested>(_onProductLoadRequested);
    on<ProductSearchQueryChanged>(_onProductSearchQueryChanged);
    on<ProductAddOrUpdateRequested>(_onProductAddOrUpdateRequested);
    on<ProductDeleteRequested>(_onProductDeleteRequested);
    on<ProductLikeToggleRequested>(_onProductLikeToggleRequested);
    
    // Load initial data
    add(const ProductLoadRequested());
  }

  Future<void> _onProductLoadRequested(
    ProductLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final box = _hiveService.watchProducts().value;
      final allProducts = box.values.toList();
      
      List<Product> filteredProducts;
      if (_searchQuery.isEmpty) {
        filteredProducts = allProducts..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        filteredProducts = allProducts.where((product) {
          return product.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              product.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              product.description.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();
        filteredProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      emit(ProductLoaded(products: filteredProducts, searchQuery: _searchQuery));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onProductSearchQueryChanged(
    ProductSearchQueryChanged event,
    Emitter<ProductState> emit,
  ) async {
    _searchQuery = event.query;
    add(const ProductLoadRequested());
  }

  Future<void> _onProductAddOrUpdateRequested(
    ProductAddOrUpdateRequested event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await _hiveService.addOrUpdateProduct(event.product);
      add(const ProductLoadRequested());
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onProductDeleteRequested(
    ProductDeleteRequested event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await _hiveService.deleteProduct(event.productId);
      add(const ProductLoadRequested());
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onProductLikeToggleRequested(
    ProductLikeToggleRequested event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await _hiveService.toggleProductLike(event.productId);
      add(const ProductLoadRequested());
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  ValueListenable<Box<Product>> watchProducts() => _hiveService.watchProducts();
}

