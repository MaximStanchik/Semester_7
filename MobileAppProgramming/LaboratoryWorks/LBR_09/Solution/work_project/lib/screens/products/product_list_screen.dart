import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/user_provider.dart';
import 'product_detail_screen.dart';
import 'product_edit_screen.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProductProvider, UserProvider>(
      builder: (context, productProvider, userProvider, _) {
        return ValueListenableBuilder(
          valueListenable: productProvider.watchProducts(),
          builder: (context, box, _) {
            final products = productProvider.getFilteredProducts();

            if (products.isEmpty) {
              return Center(
                child: Text(
                  userProvider.canManageProducts()
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
                    onChanged: (value) => productProvider.setSearchQuery(value),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: products.length,
                    separatorBuilder: (context, _) => const SizedBox(height: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final canManage = userProvider.canManageProducts();
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
                                onPressed: () => productProvider.toggleProductLike(product.id),
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
      },
    );
  }

  Future<void> _openDetails(BuildContext context, Product product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, Product product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductEditScreen(existing: product),
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

