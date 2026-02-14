import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';

class UserProfileRepository {
  final FirebaseFirestore _firestore;

  UserProfileRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _doc(String uid) => _firestore.collection('users').doc(uid);

  Future<UserProfile> getOrCreateProfile(User user) async {
    final ref = _doc(user.uid);
    final snap = await ref.get();

    if (snap.exists) {
      final data = snap.data();
      if (data != null) return UserProfile.fromJson(data);
    }

    final email = user.email;
    final name = user.displayName ?? (email != null ? email.split('@').first : 'User');

    final profile = UserProfile(
      uid: user.uid,
      email: email,
      name: name,
      role: 'viewer',
      avatarUrl: user.photoURL,
    );

    await ref.set(profile.toJson(), SetOptions(merge: true));
    return profile;
  }

  Stream<UserProfile> watchProfile(String uid) {
    return _doc(uid).snapshots().map(
          (snap) => UserProfile.fromJson(snap.data() ?? <String, dynamic>{'uid': uid}),
        );
  }

  Future<void> upsertProfile(UserProfile profile) {
    return _doc(profile.uid).set(profile.toJson(), SetOptions(merge: true));
  }
}
