import 'package:flutter/material.dart';

import '../services/analytics_service.dart';

class AnalyticsDemoScreen extends StatefulWidget {
  const AnalyticsDemoScreen({super.key});

  @override
  State<AnalyticsDemoScreen> createState() => _AnalyticsDemoScreenState();
}

class _AnalyticsDemoScreenState extends State<AnalyticsDemoScreen> {
  String? _status;

  Future<void> _log(String name, {Map<String, Object?> parameters = const <String, Object?>{}}) async {
    await AnalyticsService.instance.logEvent(name, parameters: parameters);
    if (!mounted) return;
    setState(() {
      _status = 'Отправлено событие: $name\nВремя: ${DateTime.now().toLocal()}\nПараметры: $parameters';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics (демо)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.play_circle_outline),
            title: const Text('demo_screen_open'),
            subtitle: const Text('Событие открытия демо-экрана'),
            onTap: () => _log('demo_screen_open'),
          ),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('login_email'),
            subtitle: const Text('Демо: логин по Email'),
            onTap: () => _log('login_email', parameters: {'source': 'analytics_demo'}),
          ),
          ListTile(
            leading: const Icon(Icons.person_add_alt_1),
            title: const Text('signup_email'),
            subtitle: const Text('Демо: регистрация по Email'),
            onTap: () => _log('signup_email', parameters: {'source': 'analytics_demo'}),
          ),
          ListTile(
            leading: const Icon(Icons.thumb_up_alt_outlined),
            title: const Text('product_like_toggle'),
            subtitle: const Text('Демо: переключение лайка товара'),
            onTap: () => _log(
              'product_like_toggle',
              parameters: {
                'product_id': 'demo_product',
                'liked': true,
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_box_outlined),
            title: const Text('product_create'),
            subtitle: const Text('Демо: создание товара'),
            onTap: () => _log(
              'product_create',
              parameters: {
                'product_id': 'demo_product',
                'price': 10,
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit_note),
            title: const Text('product_update'),
            subtitle: const Text('Демо: редактирование товара'),
            onTap: () => _log(
              'product_update',
              parameters: {
                'product_id': 'demo_product',
                'field': 'title',
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('product_delete'),
            subtitle: const Text('Демо: удаление товара'),
            onTap: () => _log(
              'product_delete',
              parameters: {
                'product_id': 'demo_product',
              },
            ),
          ),
          if (_status != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_status!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
