import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models/app_user.dart';
import '../../models/product.dart';
import '../../services/hive_service.dart';
import 'product_edit_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final AppUser activeUser;
  final HiveService hiveService;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.activeUser,
    required this.hiveService,
  });

  ImageProvider<Object> _imageProvider(String path) {
    return path.startsWith('http') ? NetworkImage(path) : AssetImage(path);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Product>>(
      valueListenable: hiveService.watchProducts(),
      builder: (context, box, _) {
        final currentProduct =
            box.values.firstWhere((item) => item.id == product.id, orElse: () => product);
        final canManage = hiveService.canManageProducts(activeUser);

        return Scaffold(
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
                        hiveService: hiveService,
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
            padding: const EdgeInsets.all(16),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image(
                  image: _imageProvider(currentProduct.imagePath),
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 72),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                currentProduct.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                currentProduct.location,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Chip(label: Text('Цена: ${currentProduct.price.toStringAsFixed(2)} \$')),
                  const SizedBox(width: 8),
                  Chip(label: Text('Отзывы: ${currentProduct.reviewsCount}')),
                ],
              ),
              const SizedBox(height: 16),
              Text(currentProduct.description),
              const SizedBox(height: 24),
              _ReviewsSection(
                hiveService: hiveService,
                productId: currentProduct.id,
                activeUser: activeUser,
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder(
                valueListenable: hiveService.watchFavorites(),
                builder: (context, favoritesBox, _) {
                  final isFavorite = hiveService.isFavorite(activeUser.id, currentProduct);
                  return Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => hiveService.toggleFavorite(activeUser.id, currentProduct),
                          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                          label: Text(isFavorite ? 'Убрать из избранного' : 'В избранное'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.tonalIcon(
                        onPressed: () => hiveService.toggleProductLike(currentProduct.id),
                        icon: Icon(currentProduct.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined),
                        label: const Text('Лайк'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
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
      await hiveService.deleteProduct(current.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class _ReviewsSection extends StatefulWidget {
  final HiveService hiveService;
  final String productId;
  final AppUser activeUser;

  const _ReviewsSection({
    required this.hiveService,
    required this.productId,
    required this.activeUser,
  });

  @override
  State<_ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<_ReviewsSection> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.hiveService.watchReviews(),
      builder: (context, box, _) {
        final reviews = widget.hiveService.getReviewsForProduct(widget.productId);
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
      await widget.hiveService.addReview(
        author: widget.activeUser,
        productId: widget.productId,
        rating: rating,
        text: controller.text.trim(),
      );
    }
    controller.dispose();
  }
}

