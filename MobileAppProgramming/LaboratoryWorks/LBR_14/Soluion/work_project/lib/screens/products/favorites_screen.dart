import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/favorites/favorites_bloc.dart';
import '../../bloc/favorites/favorites_event.dart';
import '../../bloc/favorites/favorites_state.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_state.dart';
import '../../models/product.dart';
import '../../utils/animations.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        if (userState is! UserLoaded || userState.activeUser == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final activeUser = userState.activeUser!;
        
        return BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, favoritesState) {
            if (favoritesState is FavoritesInitial) {
              // Load favorites on first build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<FavoritesBloc>().add(FavoritesLoadRequested(activeUser.id));
              });
              return const Center(child: CircularProgressIndicator());
            }
            
            if (favoritesState is FavoritesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (favoritesState is FavoritesError) {
              return Center(child: Text('Ошибка: ${favoritesState.message}'));
            }

            if (favoritesState is! FavoritesLoaded) {
              return const Center(child: Text('Неизвестное состояние'));
            }

            final favorites = favoritesState.favorites;
            return ValueListenableBuilder(
              valueListenable: context.read<FavoritesBloc>().watchFavorites(),
              builder: (context, box, _) {
                // Get current favorites from the box
                final currentFavorites = context.read<FavoritesBloc>().getFavoritesForUser(activeUser.id);

                return Container(
                  color: Colors.grey[50],
                  child: SafeArea(
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
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Favorites',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          child: currentFavorites.isEmpty
                              ? const Center(child: Text('Избранных товаров пока нет'))
                              : ListView.separated(
                                  itemCount: currentFavorites.length,
                                  separatorBuilder: (context, _) => const SizedBox(height: 15),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  itemBuilder: (context, index) {
                                    final product = currentFavorites[index];
                                    return _buildFavoriteCard(
                                      context,
                                      product,
                                      activeUser.id,
                                      index,
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFavoriteCard(BuildContext context, Product product, int userId, int index) {
    final themeColor = index.isEven ? const Color(0xFFFFA726) : const Color(0xFF66BB6A);
    final bgColor = themeColor.withOpacity(0.22);

    final imageProvider = product.imagePath.startsWith('http')
        ? NetworkImage(product.imagePath)
        : AssetImage(product.imagePath) as ImageProvider<Object>;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        buildSlideUpFadeRoute(builder: (_) => ProductDetailScreen(product: product)),
      ),
      child: Container(
        height: 175,
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
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image(
                  image: imageProvider,
                  width: 92,
                  height: 147,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 92,
                    height: 147,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 40),
                  ),
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
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.favorite, color: Colors.red, size: 22),
                          onPressed: () {
                            context.read<FavoritesBloc>().add(
                              FavoriteToggleRequested(
                                userId: userId,
                                product: product,
                              ),
                            );
                          },
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
                    const SizedBox(height: 6),
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
                            onPressed: () => Navigator.push(
                              context,
                              buildSlideUpFadeRoute(builder: (_) => ProductDetailScreen(product: product)),
                            ),
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
      ),
    );
  }
}

