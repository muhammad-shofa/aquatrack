import 'package:flutter/material.dart';

import '../../../data/models/user_model.dart';
import '../data/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthRepository repository}) : _repository = repository;

  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> initialize() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final String? token = await _repository.getStoredToken();
      if (token == null || token.isEmpty) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }

      _user = await _repository.me();
      _status = AuthStatus.authenticated;
      _errorMessage = null;
    } catch (_) {
      await _repository.clearStoredToken();
      _user = null;
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final payload = await _repository.login(email: email, password: password);
      _user = payload.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = 'Login gagal. Periksa kredensial Anda.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await _repository.logout();
    } catch (_) {}

    _user = null;
    _errorMessage = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void handleUnauthorized() {
    _user = null;
    _errorMessage = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
