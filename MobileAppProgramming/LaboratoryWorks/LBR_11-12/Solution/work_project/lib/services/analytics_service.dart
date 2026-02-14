import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics? _analytics;

  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const <String, Object?>{},
  }) async {
    try {
      final analytics = _analytics ??= FirebaseAnalytics.instance;
      final Map<String, Object> cleaned = <String, Object>{};
      parameters.forEach((key, value) {
        if (value != null) cleaned[key] = value;
      });

      await analytics.logEvent(
        name: name,
        parameters: cleaned.isEmpty ? null : cleaned,
      );
    } catch (_) {
      return;
    }
  }
}
