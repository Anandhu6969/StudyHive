import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../constants/api_constants.dart';
import '../models/material_item.dart';
import 'dio_client.dart';

class MaterialService {
  final Dio _dio = DioClient().dio;

  Future<List<MaterialItem>> getMaterials({
    String? subject,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };
      if (subject != null && subject.isNotEmpty) {
        queryParams['subject'] = subject;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get(
        ApiConstants.materials,
        queryParameters: queryParams,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => MaterialItem.fromJson(json))
            .toList();
      }

      // Handle paginated response
      if (response.data is Map) {
        final list = response.data['data'] ?? response.data['items'];
        if (list is List) {
          return list
              .map((json) => MaterialItem.fromJson(json))
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<MaterialItem> getMaterialById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.materialById(id));
      return MaterialItem.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> uploadMaterial({
    required String title,
    required String description,
    required String subject,
    required String course,
    required String tags,
    required PlatformFile file,
  }) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        'description': description,
        'subject': subject,
        'course': course,
        'tags': tags,
        'file': MultipartFile.fromBytes(
          file.bytes!,
          filename: file.name,
        ),
      });

      await _dio.post(
        ApiConstants.materialUpload,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateMaterial(int id, Map<String, dynamic> data) async {
    try {
      await _dio.put(ApiConstants.materialById(id), data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteMaterial(int id) async {
    try {
      await _dio.delete(ApiConstants.materialById(id));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> downloadMaterial(int id) async {
    try {
      final response = await _dio.get(
        ApiConstants.materialDownload(id),
        options: Options(responseType: ResponseType.bytes),
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      }
      return 'Server error: ${e.response!.statusCode}';
    }
    return e.message ?? 'Network error. Please check your connection.';
  }
}
