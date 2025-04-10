import 'package:flutter/material.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
  });
}

class UserProvider extends ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  void login(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void updateProfile({
    String? username,
    String? email,
    String? avatarUrl,
  }) {
    if (_currentUser == null) return;

    _currentUser = User(
      id: _currentUser!.id,
      username: username ?? _currentUser!.username,
      email: email ?? _currentUser!.email,
      avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
    );

    notifyListeners();
  }
}
