// lib/features/profile/data/datasources/profile_remote_datasource.dart
import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_profile_model.dart';

/// Contrato del data source remoto
abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile(String userId, String token);

  Future<UserProfileModel> updateProfile({
    required String userId,
    required String token,
    String? name,
    String? academicLevel,
    String? bio,
  });

  Future<void> changePassword({
    required String userId,
    required String token,
    required String currentPassword,
    required String newPassword,
  });

  Future<void> deleteAccount(String userId, String token);
}

/// Implementación del data source remoto con Dio
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  ProfileRemoteDataSourceImpl({required this.dio, required this.baseUrl});

  @override
  Future<UserProfileModel> getProfile(String userId, String token) async {
    try {
      final response = await dio.get(
        '$baseUrl/users/$userId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return UserProfileModel.fromJson(response.data);
      } else {
        throw ServerException(message: 'Error al obtener perfil');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Perfil no encontrado');
      } else if (e.response?.statusCode == 401) {
        throw UnauthorizedException(message: 'Sesión expirada');
      }
      throw ServerException(
        message: e.response?.data['message'] ?? 'Error al obtener perfil',
      );
    }
  }

  @override
  Future<UserProfileModel> updateProfile({
    required String userId,
    required String token,
    String? name,
    String? academicLevel,
    String? bio,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (academicLevel != null) updateData['academicLevel'] = academicLevel;
      if (bio != null) updateData['bio'] = bio;

      final response = await dio.put(
        '$baseUrl/users/$userId',
        data: updateData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return UserProfileModel.fromJson(response.data);
      } else {
        throw ServerException(message: 'Error al actualizar perfil');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Error al actualizar perfil',
      );
    }
  }

  @override
  Future<void> changePassword({
    required String userId,
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await dio.put(
        '$baseUrl/users/$userId',
        data: {'password': newPassword},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 200) {
        throw ServerException(message: 'Error al cambiar contraseña');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(message: 'Contraseña actual incorrecta');
      }
      throw ServerException(
        message: e.response?.data['message'] ?? 'Error al cambiar contraseña',
      );
    }
  }

  @override
  Future<void> deleteAccount(String userId, String token) async {
    try {
      final response = await dio.delete(
        '$baseUrl/users/$userId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw ServerException(message: 'Error al eliminar cuenta');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Error al eliminar cuenta',
      );
    }
  }
}
