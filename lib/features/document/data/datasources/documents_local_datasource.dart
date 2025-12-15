import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/document_model.dart';

abstract class DocumentsLocalDataSource {
  Future<List<DocumentModel>> getCachedDocuments();
  Future<void> cacheDocuments(List<DocumentModel> documents);
  Future<void> clearCache();
}

class DocumentsLocalDataSourceImpl implements DocumentsLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String CACHED_DOCUMENTS_KEY = 'CACHED_DOCUMENTS';

  DocumentsLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<DocumentModel>> getCachedDocuments() async {
    try {
      final jsonString = sharedPreferences.getString(CACHED_DOCUMENTS_KEY);

      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.map((json) => DocumentModel.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      throw CacheException(message: 'Error al obtener documentos del cache');
    }
  }

  @override
  Future<void> cacheDocuments(List<DocumentModel> documents) async {
    try {
      final jsonList = documents.map((doc) => doc.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await sharedPreferences.setString(CACHED_DOCUMENTS_KEY, jsonString);
    } catch (e) {
      throw CacheException(message: 'Error al guardar documentos en cache');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(CACHED_DOCUMENTS_KEY);
    } catch (e) {
      throw CacheException(message: 'Error al limpiar cache');
    }
  }
}
