import 'package:firebase_database/firebase_database.dart';
import 'firebase_service.dart';

class UserStatusService {
  final DatabaseReference _statusRef = FirebaseService.database.ref('user_status');

  // Update user status to online
  Future<void> setUserOnline(String userId) async {
    final userStatusRef = _statusRef.child(userId);
    await userStatusRef.set({
      'status': 'online',
      'lastSeen': ServerValue.timestamp,
    });
    
    // Set up disconnect listener to mark as offline when user disconnects
    await userStatusRef.onDisconnect().set({
      'status': 'offline',
      'lastSeen': ServerValue.timestamp,
    });
  }

  // Update user status to offline
  Future<void> setUserOffline(String userId) async {
    await _statusRef.child(userId).set({
      'status': 'offline',
      'lastSeen': ServerValue.timestamp,
    });
  }

  // Update last activity timestamp
  Future<void> updateLastActivity(String userId) async {
    await _statusRef.child(userId).update({
      'lastSeen': ServerValue.timestamp,
    });
  }

  // Get user status stream
  Stream<Map<String, dynamic>?> getUserStatusStream(String userId) {
    return _statusRef.child(userId).onValue.map((event) {
      if (event.snapshot.value == null) return null;
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return {
        'status': data['status'] as String? ?? 'offline',
        'lastSeen': data['lastSeen'] as int?,
      };
    });
  }

  // Get user status once
  Future<Map<String, dynamic>?> getUserStatus(String userId) async {
    final snapshot = await _statusRef.child(userId).get();
    if (!snapshot.exists) return null;
    final data = snapshot.value as Map<dynamic, dynamic>;
    return {
      'status': data['status'] as String? ?? 'offline',
      'lastSeen': data['lastSeen'] as int?,
    };
  }
}

