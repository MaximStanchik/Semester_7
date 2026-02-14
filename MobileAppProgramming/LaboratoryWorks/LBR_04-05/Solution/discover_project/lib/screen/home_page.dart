import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import 'details_page.dart';

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
              children: [
                _buildLeaderboardItem('04', '🦊', 'Jennifer', '750 pts', '+3', _highlightedLeaderboardIndex == 0, 0),
                _buildLeaderboardItem('05', '🐸', 'William', '740 pts', '-1', _highlightedLeaderboardIndex == 1, 1),
                _buildLeaderboardItem('06', '🐨', 'Samantha', '720 pts', '-2', _highlightedLeaderboardIndex == 2, 2),
                _buildLeaderboardItem('05', '🦊', 'Emory', '630 pts', '-1', _highlightedLeaderboardIndex == 3, 3),
                _buildLeaderboardItem('05', '🐸', 'Lydia', '540 pts', '-1', _highlightedLeaderboardIndex == 4, 4),
              ],
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
    String position,
    String emoji,
    String name,
    String points,
    String change,
    bool isHighlighted,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_highlightedLeaderboardIndex == index) {
            _highlightedLeaderboardIndex = null; // Remove highlight if already selected
          } else {
            _highlightedLeaderboardIndex = index; // Set new highlight
          }
        });
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
            position,
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
                emoji,
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
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  points,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            change,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: change.startsWith('+') ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 5),
          Icon(
            change.startsWith('+') ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: change.startsWith('+') ? Colors.green : Colors.red,
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
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Removed brown decorative rectangles

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

          // Removed character illustration

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
