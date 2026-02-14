import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../services/hive_service.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final AppUser activeUser;
  final HiveService hiveService;

  const FavoritesScreen({
    super.key,
    required this.activeUser,
    required this.hiveService,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: hiveService.watchFavorites(),
      builder: (context, favoritesBox, _) {
        final favorites = hiveService.getFavoritesForUser(activeUser.id);
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
            final imageProvider =
                product.imagePath.startsWith('http') ? NetworkImage(product.imagePath) : AssetImage(product.imagePath);
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
                  onPressed: () => hiveService.toggleFavorite(activeUser.id, product),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(
                      product: product,
                      activeUser: activeUser,
                      hiveService: hiveService,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

