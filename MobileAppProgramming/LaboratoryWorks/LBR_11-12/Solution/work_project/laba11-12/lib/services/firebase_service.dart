import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseService {
  static FirebaseFirestore? _firestore;
  static FirebaseAuth? _auth;
  static FirebaseDatabase? _database;
  static FirebaseMessaging? _messaging;
  static FirebaseRemoteConfig? _remoteConfig;
  static FirebaseAnalytics? _analytics;
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    if (_initialized) return;
    await Firebase.initializeApp();
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;
    _database = FirebaseDatabase.instance;
    _messaging = FirebaseMessaging.instance;
    _remoteConfig = FirebaseRemoteConfig.instance;
    _analytics = FirebaseAnalytics.instance;
    _initialized = true;

    // Enable Firestore offline persistence
    _firestore!.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Initialize Remote Config
    await _initializeRemoteConfig();
  }

  static Future<void> _initializeRemoteConfig() async {
    await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      // Allow instant refreshes during development/demo
      minimumFetchInterval: Duration.zero,
    ));

    await _remoteConfig!.setDefaults(const {
      'like_button_enabled': true,
      'block_color': '#4B0082', // Default indigo color
    });

    try {
      await _remoteConfig!.fetchAndActivate();
    } catch (e) {
      print('Error fetching remote config: $e');
    }
  }

  static Future<void> refreshRemoteConfig() async {
    try {
      await _remoteConfig?.fetchAndActivate();
    } catch (e) {
      print('Error refreshing remote config: $e');
    }
  }

  static FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('Firebase not initialized. Call FirebaseService.initialize() first.');
    }
    return _firestore!;
  }

  static FirebaseAuth get auth {
    if (_auth == null) {
      throw Exception('Firebase not initialized. Call FirebaseService.initialize() first.');
    }
    return _auth!;
  }

  static FirebaseDatabase get database {
    if (_database == null) {
      throw Exception('Firebase not initialized. Call FirebaseService.initialize() first.');
    }
    return _database!;
  }

  static FirebaseMessaging get messaging {
    if (_messaging == null) {
      throw Exception('Firebase not initialized. Call FirebaseService.initialize() first.');
    }
    return _messaging!;
  }

  static FirebaseRemoteConfig get remoteConfig {
    if (_remoteConfig == null) {
      throw Exception('Firebase not initialized. Call FirebaseService.initialize() first.');
    }
    return _remoteConfig!;
  }

  static FirebaseAnalytics get analytics {
    if (_analytics == null) {
      throw Exception('Firebase not initialized. Call FirebaseService.initialize() first.');
    }
    return _analytics!;
  }
}

