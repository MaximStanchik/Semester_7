import 'package:equatable/equatable.dart';
import '../../models/product.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class ProductLoadRequested extends ProductEvent {
  const ProductLoadRequested();
}

class ProductSearchQueryChanged extends ProductEvent {
  final String query;

  const ProductSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class ProductAddOrUpdateRequested extends ProductEvent {
  final Product product;

  const ProductAddOrUpdateRequested(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductDeleteRequested extends ProductEvent {
  final String productId;

  const ProductDeleteRequested(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ProductStreamUpdated extends ProductEvent {
  final List<Product> products;

  const ProductStreamUpdated(this.products);

  @override
  List<Object?> get props => [products];
}

class ProductLikeToggleRequested extends ProductEvent {
  final String productId;

  const ProductLikeToggleRequested(this.productId);

  @override
  List<Object?> get props => [productId];
}

