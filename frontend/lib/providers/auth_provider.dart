import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/dio_client.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DioClient _dioClient = DioClient();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  bool get isUploader => _user?.isUploader ?? false;

  AuthProvider() {
    _dioClient.onTokenExpired = _handleTokenExpired;
  }

  void _handleTokenExpired() {
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    try {
      final hasToken = await _dioClient.hasToken();
      if (!hasToken) return false;

      final token = await _dioClient.getToken();
      if (token == null) return false;

      final storedName = await _secureStorage.read(key: 'user_name');
      final storedEmail = await _secureStorage.read(key: 'user_email');
      final storedRole = await _secureStorage.read(key: 'user_role');

      if (storedName != null && storedEmail != null && storedRole != null) {
        _user = User(
          fullName: storedName,
          email: storedEmail,
          role: storedRole,
          token: token,
        );
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.login(email, password);
      _user = user;
      _isAuthenticated = true;

      if (user.token != null) {
        await _dioClient.setToken(user.token!);
        await _secureStorage.write(key: 'user_name', value: user.fullName);
        await _secureStorage.write(key: 'user_email', value: user.email);
        await _secureStorage.write(key: 'user_role', value: user.role);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.register(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _dioClient.clearToken();
    await _secureStorage.deleteAll();
    _user = null;
    _isAuthenticated = false;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
