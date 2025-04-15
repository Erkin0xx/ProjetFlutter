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
      context.go('/complete-profile');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseTextColor = isDark ? Colors.white : Colors.black87;
    final iconColor = isDark ? Colors.white : Colors.black54;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.blur_on_rounded, size: 80, color: iconColor),
                const SizedBox(height: 16),
                Text(
                  "Connexion",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: baseTextColor,
                  ),
                ),
                const SizedBox(height: 32),
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.redAccent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                TextField(
                  controller: _emailController,
                  style: TextStyle(color: baseTextColor),
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: baseTextColor),
                    prefixIcon: Icon(Icons.mail_outline, color: iconColor),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(color: baseTextColor),
                  decoration: InputDecoration(
                    labelText: "Mot de passe",
                    labelStyle: TextStyle(color: baseTextColor),
                    prefixIcon: Icon(Icons.lock_outline, color: iconColor),
                  ),
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _login,
                          icon: const Icon(Icons.login),
                          label: const Text("Se connecter"),
                        ),
                      ),
                TextButton(
                  onPressed: () => context.go('/register'),
                  child: Text(
                    "Pas encore de compte ? S’inscrire",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
