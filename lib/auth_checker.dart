// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  
  User? _currentUser;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;

  // --- Getters ---
  User? get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get hasError => _status == AuthStatus.error;

  AuthProvider() {
    _autoLogin();
  }

  // --- Auto-login ---
Future<void> _autoLogin() async {
  try {
    // Start a timer and the API call at the same time
    final results = await Future.wait([
      _api.loadAuthToken(),
      _api.get('auth/me').catchError((e) => null), // Fail gracefully
      Future.delayed(const Duration(seconds: 2)), // Minimum splash time
    ]);

    final response = results[1]; // Result of the API call

    if (response != null && response['user'] != null) {
      _currentUser = User.fromJson(response['user']);
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
  } catch (e) {
    debugPrint("Auto-login error: $e");
    _status = AuthStatus.unauthenticated;
  } finally {
    notifyListeners(); // This will now trigger after at least 2 seconds
  }
}



  // --- Sign In ---
  Future<bool> signIn({required String email, required String password}) async {
    _setLoading();
    try {
      final response = await _api.post('auth/login', {
        'email': email,
        'password': password,
      }, requiresAuth: false);
      
      await _api.setAuthToken(response['token']);
      _currentUser = User.fromJson(response['user']);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  // --- Sign Up ---
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      final response = await _api.post('auth/register', {
        'name': name,
        'email': email,
        'password': password,
      }, requiresAuth: false);
      
      await _api.setAuthToken(response['token']);
      _currentUser = User.fromJson(response['user']);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  // --- Sign Out ---
  Future<void> signOut() async {
    _setLoading();
    try {
      await _api.post('auth/logout', {});
      await _api.clearAuthToken();
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      _setError('Failed to sign out correctly');
    }
  }

  // --- Reset Password ---
  Future<bool> resetPassword({required String email}) async {
    _setLoading();
    try {
      await _api.post('auth/reset-password', {
        'email': email,
      }, requiresAuth: false);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  // --- Update Profile ---
  Future<bool> updateProfile({String? name, String? bio, String? profileImage}) async {
    if (_currentUser == null) return false;
    _setLoading();
    try {
      final response = await _api.patch('users/${_currentUser!.id}', {
        if (name != null) 'name': name,
        if (bio != null) 'bio': bio,
        if (profileImage != null) 'profileImage': profileImage,
      });
      
      _currentUser = User.fromJson(response['user']);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile');
      return false;
    }
  }

  // --- Update last active ---
  void updateLastActive() {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(lastActive: DateTime.now());
    _api.post('users/${_currentUser!.id}/active', {});
    notifyListeners();
  }

  // --- Clear error ---
  void clearError() {
    if (_status == AuthStatus.error) {
      _errorMessage = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  // --- Helpers ---
  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
