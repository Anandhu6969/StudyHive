import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/material_item.dart';
import '../models/user.dart';
import 'dio_client.dart';

class ProfileService {
  final Dio _dio = DioClient().dio;

  Future<User> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profileMe);
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<MaterialItem>> getMyUploads() async {
    try {
      final response = await _dio.get(ApiConstants.profileUploads);

      if (response.data is List) {
        return (response.data as List)
            .map((json) => MaterialItem.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<MaterialItem>> getMyDownloads() async {
    try {
      final response = await _dio.get(ApiConstants.profileDownloads);

      if (response.data is List) {
        return (response.data as List)
            .where(
              (item) =>
                  item is Map &&
                  item.containsKey('material') &&
                  item['material'] != null,
            )
            .map(
              (item) => MaterialItem.fromJson(
                item['material'] as Map<String, dynamic>,
              ),
            )
            .toList();
      }

      return [];
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