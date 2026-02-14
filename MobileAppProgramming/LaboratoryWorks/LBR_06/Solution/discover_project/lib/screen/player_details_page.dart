import 'package:flutter/material.dart';
import '../models/player.dart';

class PlayerDetailsPage extends StatelessWidget {
  final Player player;
  const PlayerDetailsPage({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль игрока'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.deepPurple.withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    player.emoji,
                    style: const TextStyle(fontSize: 54),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              player.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  label: Text('Poz: ${player.formattedPosition}'),
                  avatar: const Icon(Icons.emoji_events, color: Colors.orange),
                  backgroundColor: Colors.orange.withOpacity(0.15),
                ),
                const SizedBox(width: 12),
                Chip(
                  label: Text(player.formattedPoints),
                  avatar: const Icon(Icons.star, color: Colors.deepPurple),
                  backgroundColor: Colors.deepPurple.withOpacity(0.15),
                ),
                const SizedBox(width: 12),
                Chip(
                  label: Text(player.change),
                  avatar: Icon(
                    player.change.startsWith('+') ? Icons.arrow_upward : Icons.arrow_downward,
                    color: player.change.startsWith('+') ? Colors.green : Colors.red,
                  ),
                  backgroundColor: (player.change.startsWith('+') ? Colors.green : Colors.red).withOpacity(0.12),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'О игроке',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              player.bio,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Последняя активность',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[850],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Icon(Icons.fitness_center, color: Colors.deepPurple),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Тренировка длительностью 45 минут и участие в челлендже «10к шагов».',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Назад к списку'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
