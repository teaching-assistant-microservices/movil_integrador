// lib/core/usecases/usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../errors/failures.dart';

/// Caso de uso base para toda la aplicación
///
/// [Type] es el tipo de retorno exitoso
/// [Params] son los parámetros de entrada
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Para casos de uso sin parámetros
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}

/// Para casos de uso con Stream
abstract class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}
