import 'package:integrador/core/network/models/upload_file.dart';
import 'package:integrador/features/home/domain/entities/upload_result_entity.dart';

abstract class HomeRepository {
  Future<UploadResultEntity> uploadDocument({
    required UploadFile file,
    required String userId,
    Function(int, int)? onProgress,
  });
}
