import 'package:flutter/material.dart';
import '../models/material_item.dart';
import '../models/user.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  User? _profile;
  List<MaterialItem> _myUploads = [];
  List<MaterialItem> _myDownloads = [];
  bool _isLoading = false;
  String? _error;

  User? get profile => _profile;
  List<MaterialItem> get myUploads => _myUploads;
  List<MaterialItem> get myDownloads => _myDownloads;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _profileService.getProfile();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyUploads() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myUploads = await _profileService.getMyUploads();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyDownloads() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myDownloads = await _profileService.getMyDownloads();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _profileService.getProfile(),
        _profileService.getMyUploads(),
        _profileService.getMyDownloads(),
      ]);

      _profile = results[0] as User;
      _myUploads = results[1] as List<MaterialItem>;
      _myDownloads = results[2] as List<MaterialItem>;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearProfile() {
    _profile = null;
    _myUploads = [];
    _myDownloads = [];
    notifyListeners();
  }

  Future<bool> deleteMaterial(int id) async {
    try {
      await _profileService.deleteMaterial(id);
      _myUploads.removeWhere((m) => m.id == id);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
