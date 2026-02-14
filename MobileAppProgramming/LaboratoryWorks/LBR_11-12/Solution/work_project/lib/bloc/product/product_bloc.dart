import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/product.dart';
import '../../repositories/firestore_product_repository.dart';
import '../../services/analytics_service.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final FirestoreProductRepository _repo;

  StreamSubscription<List<Product>>? _productsSub;
  List<Product> _allProducts = const <Product>[];
  String _searchQuery = '';

  ProductBloc({FirestoreProductRepository? repo})
      : _repo = repo ?? FirestoreProductRepository(),
        super(const ProductInitial()) {
    on<ProductLoadRequested>(_onProductLoadRequested);
    on<ProductStreamUpdated>(_onProductStreamUpdated);
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
      emit(const ProductLoading());

      _productsSub ??= _repo.watchAll().listen(
        (products) {
          add(ProductStreamUpdated(products));
        },
      );

      if (_allProducts.isEmpty) {
        _allProducts = await _repo.fetchAll();
      }

      final filtered = _applyFilters(_allProducts);
      emit(ProductLoaded(products: filtered, searchQuery: _searchQuery));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onProductStreamUpdated(
    ProductStreamUpdated event,
    Emitter<ProductState> emit,
  ) async {
    _allProducts = event.products;
    final filtered = _applyFilters(_allProducts);
    emit(ProductLoaded(products: filtered, searchQuery: _searchQuery));
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
      final isNew = !_allProducts.any((p) => p.id == event.product.id);
      await AnalyticsService.instance.logEvent(
        isNew ? 'product_create' : 'product_update',
        parameters: <String, Object?>{
          'product_id': event.product.id,
        },
      );
      await _repo.upsert(event.product);
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onProductDeleteRequested(
    ProductDeleteRequested event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await AnalyticsService.instance.logEvent(
        'product_delete',
        parameters: <String, Object?>{
          'product_id': event.productId,
        },
      );
      await _repo.deleteById(event.productId);
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onProductLikeToggleRequested(
    ProductLikeToggleRequested event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await AnalyticsService.instance.logEvent(
        'product_like_toggle',
        parameters: <String, Object?>{
          'product_id': event.productId,
        },
      );
      await _repo.toggleLike(event.productId);
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _productsSub?.cancel();
    return super.close();
  }

  List<Product> _applyFilters(List<Product> products) {
    if (_searchQuery.isEmpty) {
      return List<Product>.from(products);
    }
    final q = _searchQuery.toLowerCase();
    return products.where((product) {
      return product.title.toLowerCase().contains(q) ||
          product.location.toLowerCase().contains(q) ||
          product.description.toLowerCase().contains(q);
    }).toList(growable: false);
  }
}

