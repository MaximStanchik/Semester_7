import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/history.dart';
import '../services/firebase_service.dart';

class HistoryProvider with ChangeNotifier {
  List<SearchHistory> _history = [];
  final CollectionReference _historyCollection = FirebaseService.firestore.collection('history');

  List<SearchHistory> get history => _history;

  HistoryProvider() {
    _subscribeToHistory();
  }

  void _subscribeToHistory() {
    _historyCollection.orderBy('createdAt', descending: true).snapshots().listen((snapshot) {
      _history = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return SearchHistory.fromMap(data);
      }).toList();
      notifyListeners();
    });
  }

  Future<void> addSearchHistory(String userId, String query) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final searchHistory = SearchHistory(
      id: id,
      userId: userId,
      query: query,
      createdAt: DateTime.now(),
    );
    await _historyCollection.doc(id).set(searchHistory.toMap());
    // Data will be updated via snapshot listener
  }

  Future<void> deleteSearchHistory(String historyId) async {
    await _historyCollection.doc(historyId).delete();
    // Data will be updated via snapshot listener
  }

  Future<void> clearUserHistory(String userId) async {
    final userHistory = await _historyCollection
        .where('userId', isEqualTo: userId)
        .get();

    for (var doc in userHistory.docs) {
      await doc.reference.delete();
    }
    // Data will be updated via snapshot listener
  }

  List<SearchHistory> getHistoryByUser(String userId) {
    return _history.where((h) => h.userId == userId).toList();
  }

  List<SearchHistory> getRecentHistory(int limit) {
    return _history.take(limit).toList();
  }
}
