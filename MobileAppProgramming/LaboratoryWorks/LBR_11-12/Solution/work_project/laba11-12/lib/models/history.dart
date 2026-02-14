class SearchHistory {
  String id;
  String userId;
  String query;
  DateTime createdAt;

  SearchHistory({
    required this.id,
    required this.userId,
    required this.query,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'query': query,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SearchHistory.fromMap(Map<String, dynamic> map) {
    return SearchHistory(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      query: map['query'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}


