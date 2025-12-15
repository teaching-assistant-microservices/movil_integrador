// lib/features/profile/data/datasources/profile_local_datasource.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_profile_model.dart';

/// Contrato del data source local
abstract class ProfileLocalDataSource {
  Future<UserProfileModel?> getCachedProfile();
  Future<void> cacheProfile(UserProfileModel profile);
  Future<void> clearCache();
}

/// Implementación con SharedPreferences
class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String CACHED_PROFILE_KEY = 'CACHED_PROFILE';

  ProfileLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserProfileModel?> getCachedProfile() async {
    try {
      final jsonString = sharedPreferences.getString(CACHED_PROFILE_KEY);
      if (jsonString != null) {
        return UserProfileModel.fromJson(json.decode(jsonString));
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Error al obtener perfil del cache');
    }
  }

  @override
  Future<void> cacheProfile(UserProfileModel profile) async {
    try {
      final jsonString = json.encode(profile.toJson());
      await sharedPreferences.setString(CACHED_PROFILE_KEY, jsonString);
    } catch (e) {
      throw CacheException(message: 'Error al guardar perfil en cache');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(CACHED_PROFILE_KEY);
    } catch (e) {
      throw CacheException(message: 'Error al limpiar cache de perfil');
    }
  }
}
