import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/bookmark.dart';
import 'dio_client.dart';

class BookmarkService {
  final Dio _dio = DioClient().dio;

  Future<void> addBookmark(int materialId) async {
    try {
      await _dio.post(ApiConstants.bookmarkById(materialId));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> removeBookmark(int materialId) async {
    try {
      await _dio.delete(ApiConstants.bookmarkById(materialId));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Bookmark>> getBookmarks() async {
    try {
      final response = await _dio.get(ApiConstants.bookmarks);

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Bookmark.fromJson(json))
            .toList();
      }
      return [];
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
