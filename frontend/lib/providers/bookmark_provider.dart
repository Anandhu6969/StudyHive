import 'package:flutter/material.dart';
import '../models/bookmark.dart';
import '../services/bookmark_service.dart';

class BookmarkProvider extends ChangeNotifier {
  final BookmarkService _bookmarkService = BookmarkService();

  List<Bookmark> _bookmarks = [];
  bool _isLoading = false;
  String? _error;

  List<Bookmark> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Set<int> get bookmarkedMaterialIds =>
      _bookmarks.map((b) => b.materialId).toSet();

  bool isMaterialBookmarked(int materialId) =>
      bookmarkedMaterialIds.contains(materialId);

  Future<void> fetchBookmarks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookmarks = await _bookmarkService.getBookmarks();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleBookmark(int materialId) async {
    _error = null;

    try {
      if (isMaterialBookmarked(materialId)) {
        await _bookmarkService.removeBookmark(materialId);
        _bookmarks.removeWhere((b) => b.materialId == materialId);
      } else {
        await _bookmarkService.addBookmark(materialId);
        // Refetch bookmarks after adding to get material data
        await fetchBookmarks();
        return true;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearBookmarks() {
    _bookmarks = [];
    notifyListeners();
  }
}
