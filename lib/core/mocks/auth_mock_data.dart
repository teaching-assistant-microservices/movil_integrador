// lib/core/mocks/auth_mock_data.dart
import 'package:integrador/features/auth/data/models/auth_response_dto.dart';

class AuthMockData {
  static final mockUser = UserDto(
    id: 'test_user_123',
    email: 'demo@asistente.com',
    name: 'Usuario Demo',
  );

  static AuthResponseDto mockLogin(String email, String password) {
    // Simular validación
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    if (email != 'demo@asistente.com' && email != 'admin@asistente.com') {
      throw Exception('Usuario no encontrado');
    }

    return AuthResponseDto(
      accessToken: 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken:
          'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      expiresIn: 3600,
      user: mockUser,
    );
  }

  static AuthResponseDto mockRegister(
    String email,
    String name,
    String password,
  ) {
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    if (email == 'demo@asistente.com') {
      throw Exception('Email already exists');
    }

    return AuthResponseDto(
      accessToken: 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken:
          'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      expiresIn: 3600,
      user: UserDto(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
      ),
    );
  }
}
