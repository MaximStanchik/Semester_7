import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models/app_user.dart';
import '../../models/product.dart';
import '../../services/hive_service.dart';
import 'product_detail_screen.dart';
import 'product_edit_screen.dart';

class ProductListScreen extends StatefulWidget {
  final AppUser activeUser;
  final HiveService hiveService;

  const ProductListScreen({
    super.key,
    required this.activeUser,
    required this.hiveService,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Product>>(
      valueListenable: widget.hiveService.watchProducts(),
      builder: (context, box, _) {
        final products = box.values.where((product) {
          if (_searchQuery.isEmpty) return true;
          return product.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              product.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              product.description.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (products.isEmpty) {
          return Center(
            child: Text(
              widget.hiveService.canManageProducts(widget.activeUser)
                  ? 'Добавьте первый товар'
                  : 'Список товаров пуст',
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Поиск',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: products.length,
                separatorBuilder: (context, _) => const SizedBox(height: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                itemBuilder: (context, index) {
                  final product = products[index];
                  final canManage = widget.hiveService.canManageProducts(widget.activeUser);
                  return Card(
                    child: ListTile(
                      leading: _buildImage(product.imagePath),
                      title: Text(product.title),
                      subtitle: Text('${product.location} · ${product.price.toStringAsFixed(0)} \$'),
                      trailing: Wrap(
                        spacing: 4,
                        children: [
                          IconButton(
                            icon: Icon(
                              product.isLiked ? Icons.favorite : Icons.favorite_border,
                              color: product.isLiked ? Colors.red : null,
                            ),
                            onPressed: () => widget.hiveService.toggleProductLike(product.id),
                          ),
                          if (canManage)
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _openEditor(context, product),
                            ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () => _openDetails(context, product),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openDetails(BuildContext context, Product product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          product: product,
          activeUser: widget.activeUser,
          hiveService: widget.hiveService,
        ),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, Product product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductEditScreen(
          hiveService: widget.hiveService,
          existing: product,
        ),
      ),
    );
  }

  Widget _buildImage(String path) {
    final provider = path.startsWith('http')
        ? NetworkImage(path)
        : AssetImage(path) as ImageProvider<Object>;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image(
        image: provider,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
      ),
    );
  }
}

