// lib/core/mocks/auth_mock_data.dart

class AuthMockData {
  static final mockUser = {
    'id': 'test_user_123',
    'email': 'demo@asistente.com',
    'name': 'Usuario Demo',
  };

  static LoginResponseDto mockLogin(String email, String password) {
    // Simular validación
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    return LoginResponseDto(
      accessToken: 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken:
          'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      expiresIn: 3600,
      user: mockUser,
    );
  }
}

class LoginResponseDto {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final Map<String, dynamic> user;

  LoginResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });
}
