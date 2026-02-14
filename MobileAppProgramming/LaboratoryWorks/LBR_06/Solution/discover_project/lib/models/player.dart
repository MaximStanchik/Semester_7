class Player {
  final int position;
  final String emoji;
  final String name;
  final int points;
  final String change;
  final String bio;

  const Player({
    required this.position,
    required this.emoji,
    required this.name,
    required this.points,
    required this.change,
    required this.bio,
  });

  String get formattedPoints => '$points pts';
  String get formattedPosition => position.toString().padLeft(2, '0');
}
