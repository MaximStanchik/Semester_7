import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/role.dart';
import '../services/firebase_service.dart';

class UserProvider with ChangeNotifier {
  AppUser? _currentUser;
  List<AppUser> _users = [];
  final CollectionReference _usersCollection = FirebaseService.firestore.collection('users');

  AppUser? get currentUser => _currentUser;
  List<AppUser> get users => _users;

  UserProvider() {
    _subscribeToUsers();
  }

  void _subscribeToUsers() {
    _usersCollection.snapshots().listen((snapshot) {
      _users = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return AppUser.fromMap(data);
      }).toList();
      notifyListeners();
    });
  }

  Future<void> setCurrentUser(AppUser? user) async {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> addUser(AppUser user) async {
    await _usersCollection.doc(user.id).set(user.toMap());
    // Data will be updated via snapshot listener
  }

  Future<void> updateUser(AppUser user) async {
    await _usersCollection.doc(user.id).update(user.toMap());
    // Data will be updated via snapshot listener
    if (_currentUser?.id == user.id) {
      _currentUser = user;
    }
  }

  Future<void> deleteUser(String userId) async {
    await _usersCollection.doc(userId).delete();
    // Data will be updated via snapshot listener
    if (_currentUser?.id == userId) {
      _currentUser = null;
    }
  }

  AppUser? getUserById(String id) {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }

  List<AppUser> getUsersByRole(UserRole role) {
    return _users.where((user) => user.role == role).toList();
  }

  Future<AppUser?> getUserByFirebaseId(String firebaseUserId) async {
    try {
      final doc = await _usersCollection.doc(firebaseUserId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return AppUser.fromMap(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
