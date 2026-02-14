import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../bloc/app_bloc.dart';

class FavoritesHistoryPage extends StatefulWidget {
  final AppUser currentUser;
  const FavoritesHistoryPage({super.key, required this.currentUser});

  @override
  State<FavoritesHistoryPage> createState() => _FavoritesHistoryPageState();
}

class _FavoritesHistoryPageState extends State<FavoritesHistoryPage> {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final favorites = state.favorites.where((f) => f.userId == widget.currentUser.id).toList();
        final favIds = favorites.map((f) => f.productId).toSet();
        final favoriteProducts = state.products.where((p) => favIds.contains(p.id)).toList();
        final history = state.history.where((h) => h.userId == widget.currentUser.id).toList();

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Избранное и История'),
              bottom: const TabBar(tabs: [Tab(text: 'Избранное'), Tab(text: 'История')]),
            ),
            body: TabBarView(children: [
              // Favorites
              ListView.separated(
                itemCount: favoriteProducts.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final p = favoriteProducts[i];
                  final isFav = state.favorites.any((f) => f.userId == widget.currentUser.id && f.productId == p.id);
                  return ListTile(
                    leading: Image.asset(p.imagePath, width: 48, height: 48, fit: BoxFit.cover),
                    title: Text(p.title),
                    subtitle: Text('${p.location} • ${p.price.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: Icon(isFav ? Icons.bookmark : Icons.bookmark_border),
                      onPressed: () async {
                        context.read<AppBloc>().add(ToggleFavoriteEvent(widget.currentUser.id, p.id));
                      },
                    ),
                  );
                },
              ),
              // History
              ListView.separated(
                itemCount: history.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final h = history[i];
                  return ListTile(
                    title: Text(h.query),
                    subtitle: Text(h.createdAt.toIso8601String()),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        context.read<AppBloc>().add(DeleteSearchHistoryEvent(h.id));
                      },
                    ),
                  );
                },
              ),
            ]),
          ),
        );
      },
    );
  }
}


