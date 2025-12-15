// lib/features/auth/data/datasources/auth_local_datasource.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Contrato del data source local
abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearCache();

  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> cacheTokens(String accessToken, String refreshToken);
  Future<void> clearTokens();
}

/// Implementación con SharedPreferences
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String CACHED_USER_KEY = 'CACHED_USER';
  static const String ACCESS_TOKEN_KEY = 'ACCESS_TOKEN';
  static const String REFRESH_TOKEN_KEY = 'REFRESH_TOKEN';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString = sharedPreferences.getString(CACHED_USER_KEY);
      if (jsonString != null) {
        return UserModel.fromJson(json.decode(jsonString));
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Error al obtener usuario del cache');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final jsonString = json.encode(user.toJson());
      await sharedPreferences.setString(CACHED_USER_KEY, jsonString);
    } catch (e) {
      throw CacheException(message: 'Error al guardar usuario en cache');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(CACHED_USER_KEY);
    } catch (e) {
      throw CacheException(message: 'Error al limpiar cache');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    return sharedPreferences.getString(ACCESS_TOKEN_KEY);
  }

  @override
  Future<String?> getRefreshToken() async {
    return sharedPreferences.getString(REFRESH_TOKEN_KEY);
  }

  @override
  Future<void> cacheTokens(String accessToken, String refreshToken) async {
    try {
      await sharedPreferences.setString(ACCESS_TOKEN_KEY, accessToken);
      await sharedPreferences.setString(REFRESH_TOKEN_KEY, refreshToken);
    } catch (e) {
      throw CacheException(message: 'Error al guardar tokens');
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      await sharedPreferences.remove(ACCESS_TOKEN_KEY);
      await sharedPreferences.remove(REFRESH_TOKEN_KEY);
    } catch (e) {
      throw CacheException(message: 'Error al limpiar tokens');
    }
  }
}
