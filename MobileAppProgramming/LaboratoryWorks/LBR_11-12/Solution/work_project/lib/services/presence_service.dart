import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';

class PresenceService with WidgetsBindingObserver {
  PresenceService._();

  static final PresenceService instance = PresenceService._();

  static const String _databaseUrl =
      'https://lbr11-12-default-rtdb.europe-west1.firebasedatabase.app';

  final FirebaseDatabase _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: _databaseUrl,
  );

  StreamSubscription<DatabaseEvent>? _connectedSub;
  DatabaseReference? _statusRef;
  bool _isObserving = false;
  bool _connected = false;

  String? _uid;

  DatabaseReference get _connectedRef => _db.ref('.info/connected');

  Future<void> start({required String uid}) async {
    if (_uid == uid && _statusRef != null) return;

    await stop();

    _uid = uid;
    _statusRef = _db.ref('status/$uid');

    if (!_isObserving) {
      WidgetsBinding.instance.addObserver(this);
      _isObserving = true;
    }

    _connectedSub = _connectedRef.onValue.listen((event) async {
      final connected = (event.snapshot.value as bool?) ?? false;
      _connected = connected;
      if (!connected) return;

      final ref = _statusRef;
      if (ref == null) return;

      await ref.onDisconnect().set({
        'online': false,
        'lastActive': ServerValue.timestamp,
      });

      await ref.set({
        'online': true,
        'lastActive': ServerValue.timestamp,
      });
    });
  }

  Future<void> stop() async {
    final ref = _statusRef;
    _uid = null;
    _statusRef = null;

    await _connectedSub?.cancel();
    _connectedSub = null;

    if (ref != null) {
      try {
        await ref.set({
          'online': false,
          'lastActive': ServerValue.timestamp,
        });
      } catch (_) {
      }
    }

    if (_isObserving) {
      WidgetsBinding.instance.removeObserver(this);
      _isObserving = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ref = _statusRef;
    if (ref == null) return;

    if (state == AppLifecycleState.resumed) {
      ref.set({
        'online': true,
        'lastActive': ServerValue.timestamp,
      });
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      ref.set({
        'online': false,
        'lastActive': ServerValue.timestamp,
      });
    }
  }
}
