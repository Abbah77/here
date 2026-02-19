import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider with ChangeNotifier {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    _setLoading();
    final fbUser = _auth.currentUser;
    if (fbUser != null) {
      await _loadUser(fbUser.uid);
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> _loadUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = User.fromJson(doc.data()!);
      }
    } catch (e) {
      _setError('Failed to load user data');
    }
  }

  // --- Sign In ---
  Future<bool> signIn({required String email, required String password}) async {
    _setLoading();
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _loadUser(cred.user!.uid);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Sign in failed');
      return false;
    } catch (e) {
      _setError('Something went wrong');
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
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = User(
        id: cred.user!.uid,
        name: name,
        email: email,
        profileImage: 'https://via.placeholder.com/150',
        bio: 'Hello, I\'m new here!',
        followers: 0,
        following: 0,
        posts: 0,
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );
      await _firestore.collection('users').doc(cred.user!.uid).set(user.toJson());
      _currentUser = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Sign up failed');
      return false;
    } catch (e) {
      _setError('Something went wrong');
      return false;
    }
  }

  // --- Sign Out ---
  Future<void> signOut() async {
    _setLoading();
    try {
      await _auth.signOut();
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      _setError('Failed to sign out');
    }
  }

  // --- Reset Password ---
  Future<bool> resetPassword({required String email}) async {
    _setLoading();
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Password reset failed');
      return false;
    } catch (e) {
      _setError('Something went wrong');
      return false;
    }
  }

  // --- Update Profile ---
  Future<bool> updateProfile({String? name, String? bio, String? profileImage}) async {
    if (_currentUser == null) return false;
    _setLoading();
    try {
      final updatedUser = _currentUser!.copyWith(
        name: name,
        bio: bio,
        profileImage: profileImage,
        lastActive: DateTime.now(),
      );
      await _firestore.collection('users').doc(updatedUser.id).update(updatedUser.toJson());
      _currentUser = updatedUser;
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
    _firestore.collection('users').doc(_currentUser!.id).update({'lastActive': DateTime.now().toIso8601String()});
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