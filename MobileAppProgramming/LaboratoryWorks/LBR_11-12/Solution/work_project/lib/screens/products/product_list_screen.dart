import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/product/product_state.dart';
import '../../models/product.dart';
import '../../services/remote_config_service.dart';
import '../employee_list_screen.dart';
import 'favorites_screen.dart';
import 'product_detail_screen.dart';
import 'product_edit_screen.dart';
import 'security_tools_screen.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      buildWhen: (previous, current) => current is! ProductInitial,
      builder: (context, productState) {
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (productState is ProductLoading || productState is ProductInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (productState is ProductError) {
              return Center(child: Text('Ошибка: ${productState.message}'));
            }

            if (productState is! ProductLoaded) {
              return const Center(child: Text('Неизвестное состояние'));
            }

            final products = productState.products;
            final canManage = authState is AuthAuthenticated && authState.canManageProducts;

            return Container(
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Discover',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildProgressCard(),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCategoryItem(
                          context: context,
                          icon: Icons.apps,
                          label: 'Каталог',
                          onTap: () {},
                        ),
                        _buildCategoryItem(
                          context: context,
                          icon: Icons.favorite,
                          label: 'Избранное',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                          ),
                        ),
                        _buildCategoryItem(
                          context: context,
                          icon: Icons.lock,
                          label: 'Безопасность',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SecurityToolsScreen()),
                          ),
                        ),
                        _buildCategoryItem(
                          context: context,
                          icon: Icons.people,
                          label: 'Сотрудники',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const EmployeeListScreen()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Exercise',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Row(
                          children: const [
                            Text(
                              'See More',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              Icons.play_arrow,
                              color: Colors.orange,
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSearchBar(context),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: products.isEmpty
                        ? Center(
                            child: Text(
                              canManage ? 'Добавьте первый товар' : 'Список товаров пуст',
                            ),
                          )
                        : ListView.separated(
                            itemCount: products.length,
                            separatorBuilder: (context, _) => const SizedBox(height: 15),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return _buildProductCard(context, product, canManage, index);
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProgressCard() {
    return ValueListenableBuilder<Color>(
      valueListenable: RemoteConfigService.instance.progressCardColor,
      builder: (context, bgColor, _) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.home,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Привет!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Продолжим работу?',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '60%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: 0.6,
                      strokeWidth: 3,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.withOpacity(0.25)),
            ),
            child: Icon(icon, color: Colors.black, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 55,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            offset: const Offset(10, 10),
            blurRadius: 20,
            color: Colors.grey.withOpacity(0.28),
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          hintStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal,
          ),
          hintText: 'Поиск...',
          border: InputBorder.none,
          suffixIcon: Icon(
            Icons.search_outlined,
            color: Color.fromARGB(255, 1, 12, 50),
            size: 28,
          ),
        ),
        onChanged: (value) {
          context.read<ProductBloc>().add(ProductSearchQueryChanged(value));
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, bool canManage, int index) {
    final themeColor = index.isEven ? const Color(0xFFFFA726) : const Color(0xFF66BB6A);
 
    return ValueListenableBuilder<Color>(
      valueListenable: RemoteConfigService.instance.productCardColor,
      builder: (context, bgColor, _) {
        return GestureDetector(
          onTap: () => _openDetails(context, product),
          child: Container(
            height: 190,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  (index + 1).toString().padLeft(2, '0'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      width: 92,
                      height: 158,
                      child: _buildImage(product.imagePath),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            ValueListenableBuilder<bool>(
                              valueListenable: RemoteConfigService.instance.likesEnabled,
                              builder: (context, enabled, _) {
                                if (!enabled) return const SizedBox.shrink();
                                return IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    product.isLiked ? Icons.favorite : Icons.favorite_border,
                                    color:
                                        product.isLiked ? Colors.red : Colors.black.withOpacity(0.55),
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    context
                                        .read<ProductBloc>()
                                        .add(ProductLikeToggleRequested(product.id));
                                  },
                                );
                              },
                            ),
                            if (canManage)
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(Icons.edit, color: Colors.black.withOpacity(0.55), size: 22),
                                onPressed: () => _openEditor(context, product),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          product.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black.withOpacity(0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black.withOpacity(0.55),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.75),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                '${product.price.toStringAsFixed(0)} \$',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: themeColor.withOpacity(0.95),
                                ),
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              height: 36,
                              child: ElevatedButton(
                                onPressed: () => _openDetails(context, product),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3A2A2A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: const Text(
                                  "Let's Go",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
            ),
          ),
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
    final trimmed = path.trim();
    if (trimmed.isEmpty) {
      return Container(
        width: 120,
        height: 120,
        color: Colors.grey[300],
        child: const Icon(Icons.image_not_supported, size: 40),
      );
    }
    final ImageProvider<Object> provider = path.startsWith('http')
        ? NetworkImage(path)
        : path.startsWith('img/')
            ? AssetImage(path)
            : FileImage(File(path));
    return Image(
      image: provider,
      width: 120,
      height: 120,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: 120,
        height: 120,
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, size: 40),
      ),
    );
  }
}

