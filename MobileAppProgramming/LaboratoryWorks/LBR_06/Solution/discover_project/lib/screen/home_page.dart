import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import 'details_page.dart';
import 'pageview_page.dart';
import 'platform_demo_page.dart';
import 'camera_demo_page.dart';
import 'player_details_page.dart';
import '../models/player.dart';

class Product {
  final String title;
  final String description;
  final String image;
  final int index;
  const Product(this.index, this.title, this.description, this.image);
}

final products = [
  Product(0, 'Angkat beban', 'Latihan angkat beban untuk meningkatkan strength', 'assets/rabbit.png'),
  Product(1, 'Maraton', 'Maraton untuk 100m merupakan test kecepatan', 'assets/crocodile.png'),
];

final List<Player> leaderboardPlayers = [
  const Player(
    position: 4,
    emoji: '🦊',
    name: 'Jennifer',
    points: 750,
    change: '+3',
    bio: 'Jennifer — марафонец, увлекается трейлраннингом и ведет YouTube-канал о фитнесе.',
  ),
  const Player(
    position: 5,
    emoji: '🐸',
    name: 'William',
    points: 720,
    change: '-1',
    bio: 'William любит командные соревнования, в свободное время тренирует школьную команду.',
  ),
  const Player(
    position: 6,
    emoji: '🐨',
    name: 'Samantha',
    points: 680,
    change: '-2',
    bio: 'Samantha — фанатка функциональных тренировок и йоги, участвует в благотворительных забегах.',
  ),
  const Player(
    position: 7,
    emoji: '🦊',
    name: 'Emory',
    points: 630,
    change: '-1',
    bio: 'Emory специализируется на кроссфите и ведёт локальное сообщество любителей спорта.',
  ),
  const Player(
    position: 8,
    emoji: '🐸',
    name: 'Lydia',
    points: 540,
    change: '-1',
    bio: 'Lydia — начинающий тренер, разрабатывает авторские программы для новичков.',
  ),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int? _highlightedLeaderboardIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _selectedIndex == 0 ? _buildDiscoverPage() : _buildLeaderBoard(),
      ),
      bottomNavigationBar: _selectedIndex == 1 ? null : _buildBottomNavigationBar(),
    );
  }



  Widget _buildDiscoverPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Discover',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // Progress Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF8B7355),
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
                          'Holos Artik asik, yuk\'s',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'lanjutkan misimu!',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ), // Закрывающая скобка добавлена здесь
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
                      // Yellow progress ring that doesn't complete the circle
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: 0.6,
                          strokeWidth: 3,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Categories
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCategoryItem(Icons.apps, 'Kategori'),
                _buildCategoryItem(Icons.search, 'Cari'),
                _buildCategoryItem(Icons.calendar_today, 'Acara'),
                _buildCategoryItem(
                  Icons.emoji_events,
                  'Leaderboard',
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Exercise Section
            Row(
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
                  children: [
                    const Text(
                      'See More',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.play_arrow,
                      color: Colors.orange,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Exercise Cards
            Row(
              children: [
                Expanded(
                  child: _buildExerciseCard(
                    'Angkat beban',
                    'Latihan angkat beban untuk meningkatkan st...',
                    '01',
                    Colors.orange,
                    'assets/rabbit.png',
                    const Color(0xFFFFA726),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildExerciseCard(
                    'Maraton',
                    'Maraton untuk 100m merupakan test kecepat...',
                    '02',
                    Colors.green,
                    'assets/crocodile.png',
                    const Color(0xFF66BB6A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Замена Row с тремя ElevatedButton на красивую GridView с иконками и названиями
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildDemoTile(
                    icon: Icons.view_carousel,
                    label: 'PageView Demo',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PageViewDemoPage(),
                        ),
                      );
                    },
                  ),
                  _buildDemoTile(
                    icon: Icons.devices_other,
                    label: 'Platform Demo',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlatformDemoPage(),
                        ),
                      );
                    },
                  ),
                  _buildDemoTile(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CameraDemoPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Заменяем две ElevatedButton на красивые плитки-демо ниже блока камеры:
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildDemoTile(
                  icon: Icons.swap_horiz,
                  label: 'PushReplacement на Details',
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsPage(
                          title: 'PushReplacement',
                          description: 'This is pushReplacement',
                          image: products.first.image,
                        ),
                      ),
                    );
                  },
                ),
                _buildDemoTile(
                  icon: Icons.delete_sweep,
                  label: 'PushNamedAndRemoveUntil на Details',
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      'detailsPage',
                      ModalRoute.withName('/'),
                      arguments: {
                        "title": "Details (из pushNamedAndRemoveUntil)",
                        "description": "Навигация удаляет все сверху и оставляет корень.",
                        "image": "assets/rabbit.png",
                      },
                    );
                  },
                ),
              ],
            ),
          ], // Закрывающая скобка для Column
        ),
      ),
    );
  }

  Widget _buildLeaderBoard() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
                icon: Transform.rotate(
                  angle: math.pi, // left-pointing triangle
                  child: const Icon(Icons.play_arrow, size: 24),
                ),
              ),
              const Expanded(
                child: Text(
                  'Leader Board',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 48), // Balance the back button
            ],
          ),
          const SizedBox(height: 30),

          // Podium
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFFFA726).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                // Removed side decorative trees

                // Podium
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 2nd place
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildAvatar('😊', const Color(0xFF8B4513)),
                          Container(
                            width: 80,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Color(0xFF8B4513),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            child: const Center(
                  child: Text(
                                '2',
                    style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                          ),
                        ],
                      ),

                      // 1st place
                      Column(
                        mainAxisSize: MainAxisSize.min,
                    children: [
                          _buildAvatar('🐸', const Color(0xFF2E7D32)),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                '1',
                          style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                            fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 3rd place
                      Column(
                        mainAxisSize: MainAxisSize.min,
                          children: [
                          _buildAvatar('🦊', const Color(0xFFF57C00)),
                            Container(
                            width: 80,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF57C00),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                '3',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
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
          const SizedBox(height: 30),

          // Leaderboard List
          Expanded(
            child: ListView(
              children: leaderboardPlayers.asMap().entries.map((entry) {
                final index = entry.key;
                final player = entry.value;
                return _buildLeaderboardItem(player, _highlightedLeaderboardIndex == index, index);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String emoji, Color backgroundColor) {
    return Container(
      width: 50,
      height: 50,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(
    Player player,
    bool isHighlighted,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_highlightedLeaderboardIndex == index) {
            _highlightedLeaderboardIndex = null; // Remove highlight if уже выбран
          } else {
            _highlightedLeaderboardIndex = index; // Set highlight
          }
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerDetailsPage(player: player),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isHighlighted ? const Color(0xFFE3F2FD) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: isHighlighted
              ? Border.all(color: const Color(0xFF2196F3), width: 2)
              : Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
              child: Row(
                children: [
          Text(
            player.formattedPosition,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 20),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                player.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
                      child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  player.formattedPoints,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            player.change,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: player.change.startsWith('+') ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 5),
          Icon(
            player.change.startsWith('+') ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: player.change.startsWith('+') ? Colors.green : Colors.red,
            size: 16,
          ),
        ],
      ),
    ));
  }

  Widget _buildCategoryItem(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.withOpacity(0.25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: const Color(0xFF9C7D57),
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(
    String title,
    String description,
    String number,
    Color numberColor,
    String imagePath,
    Color backgroundColor,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsPage(
              title: title,
              description: description,
              image: imagePath,
            ),
          ),
        );
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            if (number.isNotEmpty)
              Positioned(
                top: 0,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: numberColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 15,
              left: 15,
              right: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Let's Go",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomNavItem(Icons.home_filled, 0),
          _buildBottomNavItem(Icons.apps, 1),
          _buildBottomNavItem(Icons.notifications, 2),
          _buildBottomNavItem(Icons.person, 3),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index || (index > 0 && _selectedIndex > 0);
    return GestureDetector(
      onTap: () {
        setState(() {
          // При нажатии на кнопки 2, 3, 4 (индексы 1, 2, 3) показываем Leader Board
          if (index == 1 || index == 2 || index == 3) {
            _selectedIndex = 1; // Устанавливаем в состояние Leader Board
          } else {
            _selectedIndex = index; // Для кнопки Home (индекс 0)
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey[400],
          size: 24,
        ),
      ),
    );
  }

  Widget _buildDemoTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 34, color: Colors.deepPurple),
              const SizedBox(height: 12),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class RabbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Rabbit body (orange)
    paint.color = const Color(0xFFF57C00);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.7),
      size.width * 0.25,
      paint,
    );

    // Rabbit head (lighter orange)
    paint.color = const Color(0xFFFFB74D);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.4),
      size.width * 0.2,
      paint,
    );

    // Ears
    paint.color = const Color(0xFFF57C00);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.35, size.height * 0.25),
        width: size.width * 0.12,
        height: size.height * 0.25,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.65, size.height * 0.25),
        width: size.width * 0.12,
        height: size.height * 0.25,
      ),
      paint,
    );

    // Eyes
    paint.color = Colors.black;
    canvas.drawCircle(
      Offset(size.width * 0.42, size.height * 0.35),
      size.width * 0.03,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.58, size.height * 0.35),
      size.width * 0.03,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CrocodilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Crocodile body (green)
    paint.color = const Color(0xFF66BB6A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.6),
        width: size.width * 0.6,
        height: size.height * 0.4,
      ),
      paint,
    );

    // Head
    paint.color = const Color(0xFF4CAF50);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.35),
        width: size.width * 0.4,
        height: size.height * 0.3,
      ),
      paint,
    );

    // Snout
    paint.color = const Color(0xFF66BB6A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.25),
        width: size.width * 0.3,
        height: size.height * 0.15,
      ),
      paint,
    );

    // Eyes
    paint.color = Colors.black;
    canvas.drawCircle(
      Offset(size.width * 0.42, size.height * 0.3),
      size.width * 0.03,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.58, size.height * 0.3),
      size.width * 0.03,
      paint,
    );

    // Teeth
    paint.color = Colors.white;
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * (0.4 + i * 0.07),
          size.height * 0.32,
          size.width * 0.02,
          size.height * 0.04,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
