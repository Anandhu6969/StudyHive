import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/rating.dart';
import 'dio_client.dart';

class RatingService {
  final Dio _dio = DioClient().dio;

  Future<void> postRating(int materialId, int stars) async {
    try {
      await _dio.post(
        ApiConstants.ratings,
        data: {
          'materialId': materialId,
          'stars': stars,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Rating>> getRatings(int materialId) async {
    try {
      final response = await _dio.get(
        ApiConstants.ratingsByMaterial(materialId),
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Rating.fromJson(json))
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
