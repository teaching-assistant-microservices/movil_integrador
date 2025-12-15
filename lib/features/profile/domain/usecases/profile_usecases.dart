// lib/features/profile/domain/usecases/profile_usecases.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

// ============================================
// GET PROFILE
// ============================================
class GetProfileUseCase implements UseCase<UserProfile, NoParams> {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(NoParams params) async {
    return await repository.getProfile();
  }
}

// ============================================
// UPDATE PROFILE
// ============================================
class UpdateProfileUseCase
    implements UseCase<UserProfile, UpdateProfileParams> {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      name: params.name,
      academicLevel: params.academicLevel,
      bio: params.bio,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String? name;
  final String? academicLevel;
  final String? bio;

  const UpdateProfileParams({this.name, this.academicLevel, this.bio});

  @override
  List<Object?> get props => [name, academicLevel, bio];
}

// ============================================
// CHANGE PASSWORD
// ============================================
class ChangePasswordUseCase implements UseCase<void, ChangePasswordParams> {
  final ProfileRepository repository;

  ChangePasswordUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ChangePasswordParams params) async {
    return await repository.changePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
    );
  }
}

class ChangePasswordParams extends Equatable {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword];
}

// ============================================
// UPDATE PREFERENCES
// ============================================
class UpdatePreferencesUseCase
    implements UseCase<UserProfile, PreferencesParams> {
  final ProfileRepository repository;

  UpdatePreferencesUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(PreferencesParams params) async {
    return await repository.updatePreferences(params.preferences);
  }
}

class PreferencesParams extends Equatable {
  final Map<String, dynamic> preferences;

  const PreferencesParams(this.preferences);

  @override
  List<Object> get props => [preferences];
}

// ============================================
// GET CACHED PROFILE
// ============================================
class GetCachedProfileUseCase implements UseCase<UserProfile?, NoParams> {
  final ProfileRepository repository;

  GetCachedProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfile?>> call(NoParams params) async {
    return await repository.getCachedProfile();
  }
}

// ============================================
// DELETE ACCOUNT
// ============================================
class DeleteAccountUseCase implements UseCase<void, NoParams> {
  final ProfileRepository repository;

  DeleteAccountUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.deleteAccount();
  }
}
