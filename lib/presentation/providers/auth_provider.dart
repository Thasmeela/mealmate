import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/datasources/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.signIn(email: email, password: password);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.signUp(email: email, password: password, name: name);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
