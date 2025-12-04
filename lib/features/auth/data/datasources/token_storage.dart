// lib/features/auth/data/datasources/token_storage.dart
import 'dart:convert';

import 'package:integrador/core/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    required Map<String, dynamic> userData,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

    await prefs.setString(AppConfig.accessTokenKey, accessToken);
    await prefs.setString(AppConfig.refreshTokenKey, refreshToken);
    await prefs.setString(AppConfig.expiresAtKey, expiresAt.toIso8601String());
    await prefs.setString(AppConfig.userDataKey, jsonEncode(userData));
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.refreshTokenKey);
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(AppConfig.userDataKey);
    if (userData != null) {
      return jsonDecode(userData) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<bool> isTokenExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final expiresAtStr = prefs.getString(AppConfig.expiresAtKey);

    if (expiresAtStr == null) return true;

    final expiresAt = DateTime.parse(expiresAtStr);
    return DateTime.now().isAfter(expiresAt);
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.accessTokenKey);
    await prefs.remove(AppConfig.refreshTokenKey);
    await prefs.remove(AppConfig.expiresAtKey);
    await prefs.remove(AppConfig.userDataKey);
  }
}
