import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/product/product_state.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_state.dart';
import '../../bloc/favorites/favorites_bloc.dart';
import '../../bloc/favorites/favorites_event.dart';
import '../../bloc/favorites/favorites_state.dart';
import '../../models/product.dart';
import '../../services/hive_service.dart';
import '../../utils/animations.dart';
import 'product_edit_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  ImageProvider<Object> _imageProvider(String path) {
    return path.startsWith('http') ? NetworkImage(path) : AssetImage(path);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, productState) {
        return BlocBuilder<UserBloc, UserState>(
          builder: (context, userState) {
            return BlocBuilder<FavoritesBloc, FavoritesState>(
              builder: (context, favoritesState) {
                Product currentProduct = product;
                if (productState is ProductLoaded) {
                  currentProduct = productState.products.firstWhere(
                    (item) => item.id == product.id,
                    orElse: () => product,
                  );
                }

                if (userState is! UserLoaded || userState.activeUser == null) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }

                final activeUser = userState.activeUser!;
                final canManage = userState.canManageProducts;

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
                            buildScaleFadeRoute(
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
                        child: Image(
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
                                    userId: activeUser.id,
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
                                      activeUser.id,
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
                                      activeUser.id,
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
                          Container(
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
                                currentProduct.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
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
      context.read<ProductBloc>().add(ProductDeleteRequested(current.id));
      if (context.mounted) Navigator.pop(context);
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
  @override
  Widget build(BuildContext context) {
    final hiveService = HiveService.instance;
    return ValueListenableBuilder(
      valueListenable: hiveService.watchReviews(),
      builder: (context, box, _) {
        final reviews = hiveService.getReviewsForProduct(widget.productId);
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
            if (reviews.isEmpty)
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
      final hiveService = HiveService.instance;
      final userState = context.read<UserBloc>().state;
      if (userState is UserLoaded && userState.activeUser != null) {
        await hiveService.addReview(
          author: userState.activeUser!,
          productId: widget.productId,
          rating: rating,
          text: controller.text.trim(),
        );
      }
    }
  }
}

