import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_project_app/models/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../models/user_model.dart';
import '../services/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();

  bool _isLoading = false;
  String? _error;

  void _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _error = "Veuillez remplir tous les champs.";
        _isLoading = false;
      });
      return;
    }

    // Connexion uniquement (pas de création ici)
    final firebaseUser =
        await _authService.signInWithEmailPassword(email, password);

    if (firebaseUser == null) {
      setState(() {
        _error = "Identifiants incorrects ou compte inexistant.";
        _isLoading = false;
      });
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (doc.exists) {
      final userData = UserModel.fromMap(firebaseUser.uid, doc.data()!);
      userProvider.setUser(userData);

      if (userData.prenom == null ||
          userData.nom == null ||
          userData.age == null) {
        context.go('/complete-profile');
      } else {
        context.go('/home');
      }
    } else {
      // Aucun profil trouvé → compléter le profil
      context.go('/complete-profile');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Mot de passe"),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _login,
                    icon: const Icon(Icons.login),
                    label: const Text("Se connecter"),
                  ),
            TextButton(
              onPressed: () => context.go('/register'),
              child: const Text("Pas encore de compte ? S’inscrire"),
            ),
          ],
        ),
      ),
    );
  }
}
