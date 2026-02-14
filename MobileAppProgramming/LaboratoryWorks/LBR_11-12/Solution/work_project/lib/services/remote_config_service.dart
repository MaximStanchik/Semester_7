import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  RemoteConfigService._();

  static final RemoteConfigService instance = RemoteConfigService._();

  final ValueNotifier<bool> likesEnabled = ValueNotifier<bool>(true);
  final ValueNotifier<Color> progressCardColor = ValueNotifier<Color>(const Color(0xFF8B7355));
  final ValueNotifier<Color> productCardColor = ValueNotifier<Color>(const Color(0xFFF3E2C2));

  Color _parseColorOrDefault(String raw, Color fallback) {
    final value = raw.trim();
    try {
      if (value.startsWith('#')) {
        final hex = value.substring(1);
        if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        }
        if (hex.length == 8) {
          return Color(int.parse(hex, radix: 16));
        }
      }
      if (value.startsWith('0x') || value.startsWith('0X')) {
        return Color(int.parse(value.substring(2), radix: 16));
      }
      if (RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(value)) {
        return Color(int.parse('FF$value', radix: 16));
      }
      if (RegExp(r'^[0-9a-fA-F]{8}$').hasMatch(value)) {
        return Color(int.parse(value, radix: 16));
      }
    } catch (_) {
      return fallback;
    }
    return fallback;
  }

  Future<void> init() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: kDebugMode ? Duration.zero : const Duration(minutes: 30),
      ),
    );

    await remoteConfig.setDefaults(<String, dynamic>{
      'likes_enabled': true,
      'progress_card_color': '#8B7355',
      'product_card_color': '#F3E2C2',
    });

    try {
      await remoteConfig.fetchAndActivate();
    } catch (_) {
      // ignore fetch errors, defaults will be used
    }

    likesEnabled.value = remoteConfig.getBool('likes_enabled');
    progressCardColor.value = _parseColorOrDefault(
      remoteConfig.getString('progress_card_color'),
      progressCardColor.value,
    );
    productCardColor.value = _parseColorOrDefault(
      remoteConfig.getString('product_card_color'),
      productCardColor.value,
    );
  }

  Future<bool> refresh() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    final activated = await remoteConfig.fetchAndActivate();
    likesEnabled.value = remoteConfig.getBool('likes_enabled');
    progressCardColor.value = _parseColorOrDefault(
      remoteConfig.getString('progress_card_color'),
      progressCardColor.value,
    );
    productCardColor.value = _parseColorOrDefault(
      remoteConfig.getString('product_card_color'),
      productCardColor.value,
    );
    return activated;
  }
}
