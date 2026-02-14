import 'package:flutter/material.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
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
                ],
              ),
              const SizedBox(height: 30),
              // Podium
              // (No changes needed here, keep as is)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA726).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    // Decorative trees
                    Positioned(
                      left: 20,
                      bottom: 20,
                      child: Container(
                        width: 30,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xFF8B4513),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      bottom: 20,
                      child: Container(
                        width: 30,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xFF8B4513),
                        ),
                      ),
                    ),
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
                    _buildLeaderboardItem('04', '🦊', 'Jennifer', '750 pts', '+3', true),
                    _buildLeaderboardItem('05', '🐸', 'William', '740 pts', '-1', false),
                    _buildLeaderboardItem('06', '🐨', 'Samantha', '720 pts', '-2', false),
                    _buildLeaderboardItem('05', '🦊', 'Emory', '630 pts', '-1', false),
                    _buildLeaderboardItem('05', '🐸', 'Lydia', '540 pts', '-1', false),
                  ],
                ),
              ),
            ],
          ),
        ),
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
      String position, String emoji, String name, String points, String change, bool isHighlighted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.orange.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: isHighlighted ? Border.all(color: Colors.orange, width: 2) : Border.all(color: Colors.grey.withOpacity(0.2)),
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
            change.startsWith('+') ? Icons.arrow_upward : Icons.arrow_downward,
            color: change.startsWith('+') ? Colors.green : Colors.red,
            size: 16,
          ),
        ],
      ),
    );
  }
}