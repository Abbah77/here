import 'package:flutter/material.dart';
import '../models/user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider with ChangeNotifier {
  // Private variables
  User? _currentUser;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  
  // Getters
  User? get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get hasError => _status == AuthStatus.error;

  // Mock user data - now using const since User model supports const
  static const User _mockUser = User(
    id: '1',
    name: 'Allan Paterson',
    email: 'allan@example.com',
    profileImage: 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
    bio: 'Flutter Developer | UI/UX Designer | Coffee Lover',
    followers: 1247,
    following: 892,
    posts: 156,
    isVerified: true,
    createdAt: null, // You can add actual dates if needed
    lastActive: null,
  );

  // Sign In with better error handling
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    // Input validation
    if (email.isEmpty || password.isEmpty) {
      _updateState(
        status: AuthStatus.error,
        errorMessage: 'Email and password cannot be empty',
      );
      return false;
    }

    if (!_isValidEmail(email)) {
      _updateState(
        status: AuthStatus.error,
        errorMessage: 'Please enter a valid email address',
      );
      return false;
    }

    if (password.length < 6) {
      _updateState(
        status: AuthStatus.error,
        errorMessage: 'Password must be at least 6 characters',
      );
      return false;
    }

    _updateState(status: AuthStatus.loading);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock authentication logic
      if (email == 'test@error.com') {
        throw Exception('Invalid credentials');
      }
      
      // Success case - you could create different users based on email
      final user = email.contains('admin') 
          ? _mockUser.copyWith(name: 'Admin User', isVerified: true)
          : _mockUser;
      
      _updateState(
        status: AuthStatus.authenticated,
        currentUser: user,
      );
      
      return true;
      
    } catch (e) {
      _updateState(
        status: AuthStatus.error,
        errorMessage: _getFriendlyErrorMessage(e),
      );
      return false;
    }
  }

  // Sign Up method (new)
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    // Input validation
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _updateState(
        status: AuthStatus.error,
        errorMessage: 'All fields are required',
      );
      return false;
    }

    if (!_isValidEmail(email)) {
      _updateState(
        status: AuthStatus.error,
        errorMessage: 'Please enter a valid email address',
      );
      return false;
    }

    if (password.length < 6) {
      _updateState(
        status: AuthStatus.error,
        errorMessage: 'Password must be at least 6 characters',
      );
      return false;
    }

    _updateState(status: AuthStatus.loading);

    try {
      await Future.delayed(const Duration(seconds: 2));
      
      // Create new user
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        profileImage: 'https://via.placeholder.com/150', // Default avatar
        bio: 'Hello, I\'m new here!',
        followers: 0,
        following: 0,
        posts: 0,
        isVerified: false,
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );
      
      _updateState(
        status: AuthStatus.authenticated,
        currentUser: newUser,
      );
      
      return true;
      
    } catch (e) {
      _updateState(
        status: AuthStatus.error,
        errorMessage: 'Sign up failed. Please try again.',
      );
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    _updateState(status: AuthStatus.loading);

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      _updateState(
        status: AuthStatus.unauthenticated,
        currentUser: null,
      );
      
    } catch (e) {
      _updateState(
        status: AuthStatus.error,
        errorMessage: 'Failed to sign out. Please try again.',
      );
    }
  }

  // Update Profile using copyWith
  Future<bool> updateProfile({
    String? name,
    String? bio,
    String? profileImage,
  }) async {
    if (_currentUser == null) {
      _updateState(
        status: AuthStatus.error,
        errorMessage: 'No user logged in',
      );
      return false;
    }

    _updateState(status: AuthStatus.loading);

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      // Use copyWith for immutable update
      final updatedUser = _currentUser!.copyWith(
        name: name,
        bio: bio,
        profileImage: profileImage,
        lastActive: DateTime.now(),
      );
      
      _updateState(
        status: AuthStatus.authenticated,
        currentUser: updatedUser,
      );
      
      return true;
      
    } catch (e) {
      _updateState(
        status: AuthStatus.error,
        errorMessage: 'Failed to update profile. Please try again.',
      );
      return false;
    }
  }

  // Update last active timestamp
  Future<void> updateLastActive() async {
    if (_currentUser == null) return;
    
    final updatedUser = _currentUser!.copyWith(
      lastActive: DateTime.now(),
    );
    
    _currentUser = updatedUser;
    notifyListeners();
  }

  // Clear error state
  void clearError() {
    if (_status == AuthStatus.error) {
      _updateState(status: AuthStatus.unauthenticated, errorMessage: null);
    }
  }

  // Helper method to update state
  void _updateState({
    required AuthStatus status,
    User? currentUser,
    String? errorMessage,
  }) {
    _status = status;
    if (currentUser != null) _currentUser = currentUser;
    _errorMessage = errorMessage;
    
    notifyListeners();
  }

  // Email validation helper
  bool _isValidEmail(String email) {
    return RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(email);
  }

  // Convert exceptions to user-friendly messages
  String _getFriendlyErrorMessage(Object error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network')) {
      return 'Network error. Please check your connection.';
    }
    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    if (errorString.contains('invalid credentials')) {
      return 'Invalid email or password.';
    }
    if (errorString.contains('user not found')) {
      return 'No account found with this email.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }

  // Reset auth state
  void reset() {
    _currentUser = null;
    _status = AuthStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
