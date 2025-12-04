// lib/core/mocks/users_mock_data.dart
class UsersMockData {
  static List<Map<String, dynamic>> mockUsers = [
    {
      'id': 'test_user_123',
      'email': 'demo@asistente.com',
      'name': 'Usuario Demo',
      'academicLevel': 'UNIVERSITY',
      'createdAt': DateTime.now()
          .subtract(Duration(days: 30))
          .toIso8601String(),
    },
    {
      'id': 'user_456',
      'email': 'profesor@escuela.com',
      'name': 'María García',
      'academicLevel': 'SECONDARY',
      'createdAt': DateTime.now()
          .subtract(Duration(days: 15))
          .toIso8601String(),
    },
  ];

  static Map<String, dynamic>? getUserById(String id) {
    try {
      return mockUsers.firstWhere((user) => user['id'] == id);
    } catch (e) {
      return null;
    }
  }

  static Map<String, dynamic> createUser({
    required String email,
    required String name,
    required String password,
    String? academicLevel,
  }) {
    final newUser = {
      'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
      'email': email,
      'name': name,
      'academicLevel': academicLevel ?? 'UNIVERSITY',
      'createdAt': DateTime.now().toIso8601String(),
    };

    mockUsers.add(newUser);
    return newUser;
  }

  static bool updateUser(String id, Map<String, dynamic> updates) {
    final index = mockUsers.indexWhere((user) => user['id'] == id);
    if (index == -1) return false;

    mockUsers[index] = {...mockUsers[index], ...updates};
    return true;
  }

  static bool deleteUser(String id) {
    final index = mockUsers.indexWhere((user) => user['id'] == id);
    if (index == -1) return false;

    mockUsers.removeAt(index);
    return true;
  }
}
