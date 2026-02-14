import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../models/role.dart';
import '../bloc/app_bloc.dart';
import '../services/firebase_service.dart';

class ProductsPage extends StatefulWidget {
  final AppUser currentUser;
  const ProductsPage({super.key, required this.currentUser});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  bool _likeButtonEnabled = true;
  Color _blockColor = const Color(0xFFA8072); // Default indigo

  @override
  void initState() {
    super.initState();
    _loadRemoteConfig();
  }

  Future<void> _loadRemoteConfig() async {
    if (!FirebaseService.isInitialized) {
      return;
    }
    try {
      final remoteConfig = FirebaseService.remoteConfig;
      await remoteConfig.fetchAndActivate();
      setState(() {
        _likeButtonEnabled = remoteConfig.getBool('like_button_enabled');
        final colorString = remoteConfig.getString('block_color');
        _blockColor = _parseColor(colorString);
      });
    } catch (e) {
      print('Error loading remote config: $e');
    }
  }

  Color _parseColor(String colorString) {
    try {
      final hex = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return const Color(0xFFA8072); // Default color
    }
  }

  bool get canEdit => widget.currentUser.role == UserRole.admin || widget.currentUser.role == UserRole.manager;

  Future<void> _editProduct([Product? p]) async {
    final title = TextEditingController(text: p?.title ?? '');
    final imagePath = TextEditingController(text: p?.imagePath ?? 'assets/mountain.jpg');
    final price = TextEditingController(text: p?.price.toString() ?? '0');
    final location = TextEditingController(text: p?.location ?? '');
    final reviews = TextEditingController(text: p?.reviewsCount.toString() ?? '0');
    final description = TextEditingController(text: p?.description ?? '');
    bool liked = p?.liked ?? false;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(p == null ? 'Добавить поездку' : 'Редактировать поездку'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: title, decoration: const InputDecoration(labelText: 'Название')),
              TextField(controller: imagePath, decoration: const InputDecoration(labelText: 'Путь к изображению')),
              TextField(controller: price, decoration: const InputDecoration(labelText: 'Цена'), keyboardType: TextInputType.number),
              TextField(controller: location, decoration: const InputDecoration(labelText: 'Локация')),
              TextField(controller: reviews, decoration: const InputDecoration(labelText: 'Число отзывов'), keyboardType: TextInputType.number),
              TextField(controller: description, decoration: const InputDecoration(labelText: 'Описание')),
              SwitchListTile(value: liked, onChanged: (v){ liked = v; }, title: const Text('Лайк')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () async {
              final id = p?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
              final prod = Product(
                id: id,
                title: title.text.trim(),
                imagePath: imagePath.text.trim(),
                price: double.tryParse(price.text.trim()) ?? 0,
                location: location.text.trim(),
                reviewsCount: int.tryParse(reviews.text.trim()) ?? 0,
                description: description.text.trim(),
                liked: liked,
              );
              context.read<AppBloc>().add(UpsertProductEvent(prod));
              if (context.mounted) Navigator.pop(ctx);
            },
            child: Text(p == null ? 'Создать' : 'Сохранить'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(Product p) async {
    context.read<AppBloc>().add(DeleteProductEvent(p.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final products = state.products;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Поездки'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Обновить Remote Config',
                onPressed: _loadRemoteConfig,
              ),
            ],
          ),
          floatingActionButton: canEdit ? FloatingActionButton(onPressed: () => _editProduct(), child: const Icon(Icons.add)) : null,
          body: RefreshIndicator(
            onRefresh: _loadRemoteConfig,
            child: ListView.separated(
            itemCount: products.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final p = products[i];
              final isFav = state.favorites.any((f) => f.userId == widget.currentUser.id && f.productId == p.id);
              final isRegularUser = widget.currentUser.role == UserRole.user;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: _blockColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _blockColor.withOpacity(0.3)),
                ),
                child: ListTile(
                  leading: Image.asset(p.imagePath, width: 48, height: 48, fit: BoxFit.cover),
                  title: Text('${p.title} — ${p.price.toStringAsFixed(2)}'),
                  subtitle: Text('${p.location} • отзывы: ${p.reviewsCount}\n${p.description}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Like button controlled by Remote Config
                    if (_likeButtonEnabled)
                      IconButton(
                        icon: Icon(p.liked ? Icons.favorite : Icons.favorite_border),
                        color: p.liked ? Colors.red : null,
                        onPressed: () async {
                          await context.read<AppBloc>().appProvider.toggleProductLike(p.id);
                          if (FirebaseService.isInitialized) {
                            FirebaseService.analytics.logEvent(
                              name: 'product_liked',
                              parameters: {
                                'product_id': p.id,
                                'liked': (!p.liked) ? 1 : 0,
                              },
                            );
                          }
                        },
                      ),
                    if (isRegularUser)
                      IconButton(
                        icon: Icon(isFav ? Icons.bookmark : Icons.bookmark_border),
                        onPressed: () async {
                          context.read<AppBloc>().add(ToggleFavoriteEvent(widget.currentUser.id, p.id));
                          if (FirebaseService.isInitialized) {
                            FirebaseService.analytics.logEvent(
                              name: 'product_favorited',
                              parameters: {
                                'product_id': p.id,
                                'is_favorite': (!isFav) ? 1 : 0,
                              },
                            );
                          }
                        },
                      ),
                    if (canEdit) ...[
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          await _editProduct(p);
                          if (FirebaseService.isInitialized) {
                            FirebaseService.analytics.logEvent(
                              name: 'product_edited',
                              parameters: {'product_id': p.id},
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await _deleteProduct(p);
                          if (FirebaseService.isInitialized) {
                            FirebaseService.analytics.logEvent(
                              name: 'product_deleted',
                              parameters: {'product_id': p.id},
                            );
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
              );
            },
          ),
          ),
        );
      },
    );
  }
}


