import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/material_item.dart';
import '../services/material_service.dart';

class MaterialProvider extends ChangeNotifier {
  final MaterialService _materialService = MaterialService();

  List<MaterialItem> _materials = [];
  MaterialItem? _selectedMaterial;
  bool _isLoading = false;
  bool _isUploading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedSubject;
  int _currentPage = 1;
  bool _hasMore = true;
  final int _pageSize = 20;

  List<MaterialItem> get materials => _materials;
  MaterialItem? get selectedMaterial => _selectedMaterial;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedSubject => _selectedSubject;
  bool get hasMore => _hasMore;

  static const List<String> _standardSubjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Computer Science',
    'English',
    'History',
    'Geography',
    'Economics',
    'Psychology',
    'Engineering',
    'Medicine',
    'Law',
    'Business',
    'Art',
    'Music',
  ];

  final List<String> subjects = [
    'All',
    ..._standardSubjects,
    'Other',
  ];

  Future<void> fetchMaterials({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _materials = [];
    }

    if (!_hasMore && !refresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final isOtherSubjectSelected = _selectedSubject == 'Other';
      final effectivePageSize = isOtherSubjectSelected ? 1000 : _pageSize;
      final fetchedMaterials = await _materialService.getMaterials(
        subject: _subjectQuery,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        page: _currentPage,
        pageSize: effectivePageSize,
      );
      final newMaterials = isOtherSubjectSelected
          ? fetchedMaterials.where(_isOtherSubject).toList()
          : fetchedMaterials;

      if (fetchedMaterials.length < effectivePageSize ||
          isOtherSubjectSelected) {
        _hasMore = false;
      }

      if (refresh) {
        _materials = newMaterials;
      } else {
        _materials.addAll(newMaterials);
      }

      _currentPage++;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    await fetchMaterials();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchMaterials(refresh: true);
  }

  void setSubjectFilter(String? subject) {
    _selectedSubject = subject;
    fetchMaterials(refresh: true);
  }

  Future<void> fetchMaterialById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedMaterial = await _materialService.getMaterialById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadMaterial({
    required String title,
    required String description,
    required String subject,
    required String course,
    required String tags,
    required PlatformFile file,
  }) async {
    _isUploading = true;
    _error = null;
    notifyListeners();

    try {
      await _materialService.uploadMaterial(
        title: title,
        description: description,
        subject: subject,
        course: course,
        tags: tags,
        file: file,
      );

      _isUploading = false;
      notifyListeners();
      fetchMaterials(refresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMaterial(int id) async {
    try {
      await _materialService.deleteMaterial(id);
      _materials.removeWhere((m) => m.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String? get _subjectQuery {
    if (_selectedSubject == null ||
        _selectedSubject == 'All' ||
        _selectedSubject == 'Other') {
      return null;
    }

    return _selectedSubject;
  }

  bool _isOtherSubject(MaterialItem material) {
    final subject = material.subject.trim().toLowerCase();
    return subject.isNotEmpty &&
        !_standardSubjects.any(
          (standardSubject) => standardSubject.toLowerCase() == subject,
        );
  }
}
