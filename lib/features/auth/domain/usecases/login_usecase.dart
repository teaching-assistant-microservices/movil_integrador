// lib/features/auth/domain/usecases/login_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// ========================================
/// LOGIN USE CASE
/// ========================================
class LoginUseCase implements UseCase<AuthResponse, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResponse>> call(LoginParams params) async {
    return await repository.login(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

/// ========================================
/// REGISTER USE CASE
/// ========================================
class RegisterUseCase implements UseCase<AuthResponse, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResponse>> call(RegisterParams params) async {
    return await repository.register(
      name: params.name,
      email: params.email,
      password: params.password,
      academicLevel: params.academicLevel,
    );
  }
}

class RegisterParams extends Equatable {
  final String name;
  final String email;
  final String password;
  final String academicLevel;

  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    required this.academicLevel,
  });

  @override
  List<Object> get props => [name, email, password, academicLevel];
}

/// ========================================
/// LOGOUT USE CASE
/// ========================================
class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}

/// ========================================
/// VALIDATE TOKEN USE CASE
/// ========================================
class ValidateTokenUseCase implements UseCase<User, NoParams> {
  final AuthRepository repository;

  ValidateTokenUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.validateToken();
  }
}

/// ========================================
/// GET CACHED USER USE CASE
/// ========================================
class GetCachedUserUseCase implements UseCase<User?, NoParams> {
  final AuthRepository repository;

  GetCachedUserUseCase(this.repository);

  @override
  Future<Either<Failure, User?>> call(NoParams params) async {
    return await repository.getCachedUser();
  }
}
