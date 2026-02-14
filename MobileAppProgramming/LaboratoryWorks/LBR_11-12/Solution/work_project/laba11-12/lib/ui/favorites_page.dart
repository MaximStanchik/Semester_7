import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../bloc/app_bloc.dart';
import '../models/favorite.dart';

class FavoritesPage extends StatefulWidget {
  final AppUser currentUser;
  const FavoritesPage({super.key, required this.currentUser});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final favoriteItems = state.favorites.where((f) => f.userId == widget.currentUser.id).toList();
        final favIds = favoriteItems.map((f) => f.productId).toSet();
        final favoriteProducts = state.products.where((p) => favIds.contains(p.id)).toList();

        return Scaffold(
          appBar: AppBar(title: const Text('Моё избранное')),
          body: favoriteProducts.isEmpty
              ? const Center(child: Text('Пока пусто'))
              : ListView.separated(
                  itemCount: favoriteProducts.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final p = favoriteProducts[i];
                    return ListTile(
                      leading: Image.asset(p.imagePath, width: 48, height: 48, fit: BoxFit.cover),
                      title: Text(p.title),
                      subtitle: Text('${p.location} • ${p.price.toStringAsFixed(2)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.bookmark_remove),
                      onPressed: () async {
                          context.read<AppBloc>().add(ToggleFavoriteEvent(widget.currentUser.id, p.id));
                        },
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}


