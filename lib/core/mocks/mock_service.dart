// lib/core/mocks/mock_service.dart
import 'dart:math';

class MockService {
  /// Simula una llamada API con delay y posible error
  static Future<T> simulateApiCall<T>({
    required T Function() dataGenerator,
    Duration? delay,
    double errorProbability = 0.0,
    String? errorMessage,
  }) async {
    // Simular delay de red
    await Future.delayed(
      delay ?? Duration(milliseconds: Random().nextInt(1000) + 300),
    );

    // Simular errores aleatorios
    if (Random().nextDouble() < errorProbability) {
      throw Exception(errorMessage ?? 'Simulated network error');
    }

    return dataGenerator();
  }

  /// Simula un stream de datos
  static Stream<T> simulateStreamCall<T>({
    required List<T> data,
    Duration? intervalDelay,
  }) async* {
    for (var item in data) {
      await Future.delayed(
        intervalDelay ?? Duration(milliseconds: Random().nextInt(500) + 100),
      );
      yield item;
    }
  }
}
