import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/product/product_state.dart';
import '../../bloc/favorites/favorites_bloc.dart';
import '../../bloc/favorites/favorites_event.dart';
import '../../bloc/favorites/favorites_state.dart';
import '../../models/product.dart';
import '../../models/review.dart';
import '../../repositories/firestore_product_repository.dart';
import '../../repositories/firestore_reviews_repository.dart';
import '../../services/remote_config_service.dart';
import 'product_edit_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  ImageProvider<Object> _imageProvider(String path) {
    return path.startsWith('http')
        ? NetworkImage(path)
        : path.startsWith('img/')
            ? AssetImage(path)
            : FileImage(File(path));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, productState) {
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            return BlocBuilder<FavoritesBloc, FavoritesState>(
              builder: (context, favoritesState) {
                Product currentProduct = product;
                if (productState is ProductLoaded) {
                  currentProduct = productState.products.firstWhere(
                    (item) => item.id == product.id,
                    orElse: () => product,
                  );
                }

                if (authState is! AuthAuthenticated) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }

                final profile = authState.profile;
                final canManage = authState.canManageProducts;

                return Scaffold(
                  backgroundColor: Colors.grey[50],
                  appBar: AppBar(
                    title: Text(currentProduct.title),
                    actions: [
                      if (canManage)
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductEditScreen(
                                existing: currentProduct,
                              ),
                            ),
                          ),
                        ),
                      if (canManage)
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _confirmDelete(context, currentProduct),
                        ),
                    ],
                  ),
                  body: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: currentProduct.imagePath.trim().isEmpty
                            ? Container(
                                height: 220,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported, size: 72),
                              )
                            : Image(
                                image: _imageProvider(currentProduct.imagePath),
                                height: 220,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 220,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image, size: 72),
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        currentProduct.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentProduct.location,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFA726).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${currentProduct.price.toStringAsFixed(2)} \$',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFA726),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Отзывы: ${currentProduct.reviewsCount}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        currentProduct.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      _ReviewsSection(
                        productId: currentProduct.id,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final favoritesBloc = context.read<FavoritesBloc>();
                                  favoritesBloc.add(FavoriteToggleRequested(
                                    userId: profile.uid,
                                    product: currentProduct,
                                  ));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                icon: BlocBuilder<FavoritesBloc, FavoritesState>(
                                  builder: (context, state) {
                                    final isFavorite = context.read<FavoritesBloc>().isFavorite(
                                      profile.uid,
                                      currentProduct,
                                    );
                                    return Icon(
                                      isFavorite ? Icons.favorite : Icons.favorite_border,
                                      color: Colors.white,
                                    );
                                  },
                                ),
                                label: BlocBuilder<FavoritesBloc, FavoritesState>(
                                  builder: (context, state) {
                                    final isFavorite = context.read<FavoritesBloc>().isFavorite(
                                      profile.uid,
                                      currentProduct,
                                    );
                                    return Text(
                                      isFavorite ? 'Убрать из избранного' : 'В избранное',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ValueListenableBuilder<bool>(
                            valueListenable: RemoteConfigService.instance.likesEnabled,
                            builder: (context, enabled, _) {
                              if (!enabled) return const SizedBox.shrink();
                              return Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    context.read<ProductBloc>().add(
                                      ProductLikeToggleRequested(currentProduct.id),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  icon: Icon(
                                    currentProduct.isLiked
                                        ? Icons.thumb_up
                                        : Icons.thumb_up_outlined,
                                    color: Colors.orange,
                                  ),
                                  label: const Text(
                                    'Лайк',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Product current) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить товар?'),
        content: Text('Товар "${current.title}" будет удален.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить')),
        ],
      ),
    );
    if (confirmed == true) {
      final bloc = context.read<ProductBloc>();
      bloc.add(ProductDeleteRequested(current.id));

      final removedFuture = bloc.stream.firstWhere(
        (state) =>
            state is ProductLoaded && !state.products.any((p) => p.id == current.id),
      );

      final errorFuture = bloc.stream
          .firstWhere((state) => state is ProductError)
          .then((state) => throw StateError((state as ProductError).message));

      try {
        await Future.any<Object?>(<Future<Object?>>[removedFuture, errorFuture])
            .timeout(const Duration(seconds: 6));
        if (context.mounted) Navigator.pop(context);
      } on TimeoutException {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось удалить товар: таймаут')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка удаления: ${e.toString()}')),
        );
      }
    }
  }
}

class _ReviewsSection extends StatefulWidget {
  final String productId;

  const _ReviewsSection({
    required this.productId,
  });

  @override
  State<_ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<_ReviewsSection> {
  FirestoreReviewsRepository? _reviewsRepo;
  FirestoreProductRepository? _productsRepo;

  @override
  void initState() {
    super.initState();
    try {
      _reviewsRepo = FirestoreReviewsRepository();
      _productsRepo = FirestoreProductRepository();
    } catch (_) {
      _reviewsRepo = null;
      _productsRepo = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewsRepo = _reviewsRepo;
    if (reviewsRepo == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Отзывы', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.add_comment),
                label: const Text('Добавить'),
                onPressed: () => _showAddDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Отзывы недоступны'),
        ],
      );
    }

    return StreamBuilder<List<Review>>(
      stream: reviewsRepo.watchReviewsForProduct(widget.productId),
      builder: (context, snapshot) {
        final reviews = snapshot.data ?? const <Review>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Отзывы', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.add_comment),
                  label: const Text('Добавить'),
                  onPressed: () => _showAddDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (snapshot.hasError)
              Text('Ошибка: ${snapshot.error}')
            else if (!snapshot.hasData)
              const Text('Загрузка...')
            else if (reviews.isEmpty)
              const Text('Пока нет отзывов')
            else
              ...reviews.map(
                (r) => Card(
                  child: ListTile(
                    title: Text('${r.userName} · ${r.rating}/5'),
                    subtitle: Text(r.comment),
                    trailing: Text(
                      '${r.createdAt.day.toString().padLeft(2, '0')}.'
                      '${r.createdAt.month.toString().padLeft(2, '0')}.'
                      '${r.createdAt.year}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    if (_reviewsRepo == null || _productsRepo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Отзывы недоступны')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    int rating = 5;
    final controller = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const Text('Новый отзыв'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: rating,
                decoration: const InputDecoration(labelText: 'Оценка (1-5)'),
                items: List.generate(
                  5,
                  (index) => DropdownMenuItem(value: index + 1, child: Text('${index + 1}')),
                ),
                onChanged: (value) => rating = value ?? 5,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Комментарий'),
                minLines: 2,
                maxLines: 4,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Введите текст отзыва' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() != true) return;
              Navigator.pop(context, true);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );

    if (result == true) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final review = Review(
          id: const Uuid().v4(),
          productId: widget.productId,
          userId: authState.profile.uid,
          userName: authState.profile.name,
          rating: rating,
          comment: controller.text.trim(),
          createdAt: DateTime.now(),
        );

        await _reviewsRepo!.addReview(productId: widget.productId, review: review);
        await _productsRepo!.incrementReviewsCount(widget.productId, 1);
      }
    }
  }
}

