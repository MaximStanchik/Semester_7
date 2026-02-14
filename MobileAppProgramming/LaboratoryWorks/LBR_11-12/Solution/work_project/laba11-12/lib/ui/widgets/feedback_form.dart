import 'package:flutter/material.dart';

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({super.key});

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final TextEditingController _controller = TextEditingController();
  String _lastMessage = '';
  final List<String> _items =
      List.generate(20, (index) => 'Отзыв #$index: Всё понравилось!');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _lastMessage = _controller.text.trim();
    });
  }

  void _clear() {
    setState(() {
      _controller.clear();
      _lastMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(top: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Форма обратной связи',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('feedback_field'),
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Ваш комментарий',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  key: const Key('send_feedback_button'),
                  onPressed: _submit,
                  child: const Text('Отправить'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  key: const Key('clear_feedback_button'),
                  onPressed: _clear,
                  child: const Text('Очистить'),
                ),
              ],
            ),
            if (_lastMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Последнее сообщение: $_lastMessage',
                key: const Key('feedback_result'),
                style: const TextStyle(fontSize: 16),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: ListView.separated(
                key: const Key('feedback_scroll_list'),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_items[index]),
                    leading: const Icon(Icons.feedback_outlined),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

