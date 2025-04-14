import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  void setUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> loadUserFromFirestore(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      _currentUser = UserModel.fromMap(doc.id, doc.data()!);
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? username,
    String? avatarUrl,
    String? prenom,
    String? nom,
    int? age,
    String? bio, // ✅ Ajout ici
  }) async {
    if (_currentUser == null) return;

    final updatedUser = UserModel(
      id: _currentUser!.id,
      email: _currentUser!.email,
      username: username ?? _currentUser!.username,
      avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
      prenom: prenom ?? _currentUser!.prenom,
      nom: nom ?? _currentUser!.nom,
      age: age ?? _currentUser!.age,
      bio: bio ?? _currentUser!.bio,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(updatedUser.id)
        .set(updatedUser.toMap(), SetOptions(merge: true));

    _currentUser = updatedUser;
    notifyListeners();
  }
}
