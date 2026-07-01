// lib/services/auth_service.dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'session_service.dart';

class AuthService extends ChangeNotifier {
  User? _user;
  // Persists the logged-in user (via shared_preferences) so a valid session
  // survives an app restart instead of forcing a fresh login every time.
  final SessionService _session = SessionService();
  bool _initialized = false;

  bool get isLoggedIn => _user != null;
  String? get userRole => _user?.role;
  String? get userId => _user?.id;
  String? get token => _user?.token; // Added token getter
  // True once the persisted session (if any) has been restored on startup.
  bool get isInitialized => _initialized;

  // Call once at app startup to restore a previously saved session.
  Future<void> restoreSession() async {
    try {
      await _session.loadUser();
      final saved = _session.currentUser;
      if (saved != null && saved.token != null && saved.token!.isNotEmpty) {
        _user = saved;
        ApiService.setAuthToken(saved.token);
      }
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    final user = await ApiService.login(username, password);
    if (user != null && user.id.isNotEmpty) {
      // FIXED: Check for non-empty ID
      _user = user;
      ApiService.setAuthToken(user.token);
      await _session.saveUser(user);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String username, String password, String role) async {
    final user = await ApiService.register(username, password, role);
    if (user != null && user.id.isNotEmpty) {
      // FIXED: Check for non-empty ID
      _user = user;
      ApiService.setAuthToken(user.token);
      await _session.saveUser(user);
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _user = null;
    _session.clearSession();
    notifyListeners();
  }
}
