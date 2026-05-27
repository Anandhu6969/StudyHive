import 'package:flutter/material.dart';
import '../models/rating.dart';
import '../services/rating_service.dart';

class RatingProvider extends ChangeNotifier {
  final RatingService _ratingService = RatingService();

  List<Rating> _ratings = [];
  bool _isLoading = false;
  String? _error;
  double _averageRating = 0.0;
  int _userRating = 0;

  List<Rating> get ratings => _ratings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get averageRating => _averageRating;
  int get userRating => _userRating;

  Future<void> fetchRatings(int materialId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _ratings = await _ratingService.getRatings(materialId);
      _calculateAverage();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitRating(int materialId, int stars) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _ratingService.postRating(materialId, stars);
      await fetchRatings(materialId);
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void _calculateAverage() {
    if (_ratings.isEmpty) {
      _averageRating = 0.0;
      return;
    }
    final total = _ratings.fold<int>(0, (sum, r) => sum + r.stars);
    _averageRating = total / _ratings.length;
  }

  void clearRatings() {
    _ratings = [];
    _averageRating = 0.0;
    _userRating = 0;
    notifyListeners();
  }

  void setUserRating(String? userId) {
    if (userId == null) {
      _userRating = 0;
      return;
    }

    final userRatingObj = _ratings.firstWhere(
      (r) => r.userId == userId,
      orElse: () => Rating(materialId: 0, stars: 0),
    );

    _userRating = userRatingObj.stars;
    notifyListeners();
  }
}
