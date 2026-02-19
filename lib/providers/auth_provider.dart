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

// Mock user data - FIXED: Parsed String to DateTime
static final User _mockUser = User(
id: '1',
name: 'Allan Paterson',
email: 'allan@example.com',
profileImage: 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
bio: 'Flutter Developer | UI/UX Designer | Coffee Lover',
followers: 1247,
following: 892,
posts: 156,
isVerified: true,
createdAt: DateTime.parse('2024-01-01T10:00:00Z'), // Line 25
lastActive: DateTime.parse('2024-01-15T14:30:00Z'), // Line 26
);

// Mock users database
final Map<String, Map<String, String>> _mockUsers = {
'user1': {
'id': '1',
'name': 'Allan Paterson',
'email': 'allan@example.com',
'password': 'password123',
'profileImage': 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
},
'user2': {
'id': '2',
'name': 'Emma Watson',
'email': 'emma@example.com',
'password': 'password123',
'profileImage': 'https://randomuser.me/api/portraits/women/44.jpg',
},
'user3': {
'id': '3',
'name': 'Tom Holland',
'email': 'tom@example.com',
'password': 'password123',
'profileImage': 'https://randomuser.me/api/portraits/men/32.jpg',
},
};

// Sign In
Future<bool> signIn({
required String email,
required String password,
}) async {
final validationError = _validateEmail(email) ?? _validatePassword(password);
if (validationError != null) {
_setError(validationError);
return false;
}

_setLoading();  

try {  
  await Future.delayed(const Duration(seconds: 1));   
    
  final userEntry = _mockUsers.values.firstWhere(  
    (u) => u['email'] == email && u['password'] == password,  
    orElse: () => {},  
  );  
    
  if (userEntry.isEmpty) {  
    _setError('Invalid email or password');  
    return false;  
  }  
    
  // FIXED: Use DateTime.now() instead of String  
  final user = User(  
    id: userEntry['id']!,  
    name: userEntry['name']!,  
    email: userEntry['email']!,  
    profileImage: userEntry['profileImage']!,  
    bio: 'Hello, I\'m using Socio Network!',  
    followers: 1247,  
    following: 892,  
    posts: 156,  
    isVerified: userEntry['id'] == '1',  
    createdAt: DateTime.now(), // Line 95  
    lastActive: DateTime.now(), // Line 96  
  );  
    
  _setAuthenticated(user);  
  return true;  
    
} catch (e) {  
  _setError(_getErrorMessage(e));  
  return false;  
}

}

// Sign Up
Future<bool> signUp({
required String name,
required String email,
required String password,
}) async {
final validationError = _validateName(name) ??
_validateEmail(email) ??
_validatePassword(password);
if (validationError != null) {
_setError(validationError);
return false;
}

_setLoading();  

try {  
  await Future.delayed(const Duration(seconds: 1));  
    
  if (_mockUsers.values.any((u) => u['email'] == email)) {  
    _setError('Email already registered');  
    return false;  
  }  
    
  final newUserId = (int.parse(_mockUsers.keys.last.replaceAll('user', '')) + 1).toString();  
    
  // FIXED: Use DateTime.now() instead of String  
  final newUser = User(  
    id: newUserId,  
    name: name,  
    email: email,  
    profileImage: 'https://via.placeholder.com/150',  
    bio: 'Hello, I\'m new here!',  
    followers: 0,  
    following: 0,  
    posts: 0,  
    isVerified: false,  
    createdAt: DateTime.now(), // Line 146  
    lastActive: DateTime.now(), // Line 147  
  );  
    
  _setAuthenticated(newUser);  
  return true;  
    
} catch (e) {  
  _setError('Sign up failed. Please try again.');  
  return false;  
}

}

// Reset Password
Future<bool> resetPassword({required String email}) async {
final validationError = _validateEmail(email);
if (validationError != null) {
_setError(validationError);
return false;
}

_setLoading();  

try {  
  await Future.delayed(const Duration(seconds: 1));  
    
  if (!_mockUsers.values.any((u) => u['email'] == email)) {  
    _setError('Email not found');  
    return false;  
  }  
    
  _status = AuthStatus.unauthenticated;  
  _errorMessage = null;  
  notifyListeners();  
  return true;  
    
} catch (e) {  
  _setError('Password reset failed. Please try again.');  
  return false;  
}

}

// Sign Out
Future<void> signOut() async {
_setLoading();

try {  
  await Future.delayed(const Duration(seconds: 1));  
    
  _currentUser = null;  
  _status = AuthStatus.unauthenticated;  
  _errorMessage = null;  
  notifyListeners();  
    
} catch (e) {  
  _setError('Failed to sign out. Please try again.');  
}

}

// Update Profile
Future<bool> updateProfile({
String? name,
String? bio,
String? profileImage,
}) async {
if (_currentUser == null) {
_setError('No user logged in');
return false;
}

_setLoading();  

try {  
  await Future.delayed(const Duration(seconds: 1));  
    
  // FIXED: Use DateTime.now() instead of String  
  _currentUser = _currentUser!.copyWith(  
    name: name,  
    bio: bio,  
    profileImage: profileImage,  
    lastActive: DateTime.now(), // Line 229  
  );  
    
  _status = AuthStatus.authenticated;  
  notifyListeners();  
  return true;  
    
} catch (e) {  
  _setError('Failed to update profile');  
  return false;  
}

}

// Update last active
void updateLastActive() {
if (_currentUser == null) return;

// FIXED: Use DateTime.now() instead of String  
_currentUser = _currentUser!.copyWith(  
  lastActive: DateTime.now(), // Line 250  
);  
notifyListeners();

}

// Clear error
void clearError() {
if (_status == AuthStatus.error) {
_errorMessage = null;
_status = AuthStatus.unauthenticated;
notifyListeners();
}
}

// Reset
void reset() {
_currentUser = null;
_status = AuthStatus.initial;
_errorMessage = null;
notifyListeners();
}

// --- Private Helpers ---

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

void _setAuthenticated(User user) {
_currentUser = user;
_status = AuthStatus.authenticated;
_errorMessage = null;
notifyListeners();
}

String? _validateName(String? name) {
if (name == null || name.isEmpty) return 'Name is required';
if (name.length < 2) return 'Name too short';
return null;
}

String? _validateEmail(String? email) {
if (email == null || email.isEmpty) return 'Email is required';
if (!RegExp(r'^[\w-.]+@([\w-]+.)+[\w-]{2,4}$').hasMatch(email)) {
return 'Invalid email address';
}
return null;
}

String? _validatePassword(String? password) {
if (password == null || password.isEmpty) return 'Password is required';
if (password.length < 6) return 'Password must be at least 6 characters';
return null;
}

String _getErrorMessage(Object error) {
final msg = error.toString().toLowerCase();
if (msg.contains('network')) return 'Network error. Check connection.';
if (msg.contains('timeout')) return 'Request timed out. Try again.';
if (msg.contains('invalid credentials')) return 'Invalid email or password.';
if (msg.contains('not found')) return 'No account found with this email.';
return 'Something went wrong. Please try again.';
}
}