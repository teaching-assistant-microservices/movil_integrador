import 'dart:math';

class MockService {
  static Future<T> simulateApiCall<T>({
    required T Function() dataGenerator,
    Duration? delay,
    double errorProbability = 0.1,
  }) async {
    // Simular delay de red
    await Future.delayed(
      delay ?? Duration(milliseconds: Random().nextInt(1500) + 500),
    );

    // Simular errores aleatorios
    if (Random().nextDouble() < errorProbability) {
      throw Exception('Simulated network error');
    }

    return dataGenerator();
  }
}
