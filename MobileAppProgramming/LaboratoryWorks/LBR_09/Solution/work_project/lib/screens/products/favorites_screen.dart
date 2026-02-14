import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/favorites_provider.dart';
import '../../providers/user_provider.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<FavoritesProvider, UserProvider>(
      builder: (context, favoritesProvider, userProvider, _) {
        final activeUser = userProvider.activeUser;
        if (activeUser == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return ValueListenableBuilder(
          valueListenable: favoritesProvider.watchFavorites(),
          builder: (context, favoritesBox, _) {
            final favorites = favoritesProvider.getFavoritesForUser(activeUser.id);
            if (favorites.isEmpty) {
              return const Center(
                child: Text('Избранных товаров пока нет'),
              );
            }

            return ListView.builder(
              itemCount: favorites.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final product = favorites[index];
                final imageProvider = product.imagePath.startsWith('http')
                    ? NetworkImage(product.imagePath)
                    : AssetImage(product.imagePath);
                return Card(
                  child: ListTile(
                    title: Text(product.title),
                    subtitle: Text(product.location),
                    leading: CircleAvatar(
                      backgroundImage: imageProvider as ImageProvider<Object>,
                      onBackgroundImageError: (exception, stackTrace) {},
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () => favoritesProvider.toggleFavorite(activeUser.id, product),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: product),
                      ),
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
}

