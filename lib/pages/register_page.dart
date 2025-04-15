import 'package:flutter/material.dart';
import 'package:flutter_project_app/services/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();

  bool _isLoading = false;
  String? _error;

  void _register() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final user = await _authService.registerWithEmailPassword(email, password);

    if (user == null) {
      setState(() {
        _isLoading = false;
        _error = "Échec de la création du compte.";
      });
      return;
    }

    // 🔥 Crée un document Firestore pour le nouvel utilisateur
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'email': email,
      'username': email.split('@')[0],
      'prenom': null,
      'nom': null,
      'age': null,
      'avatarUrl': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
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
                Icon(Icons.app_registration, size: 80, color: iconColor),
                const SizedBox(height: 16),
                Text(
                  "Créer un compte",
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
                          onPressed: _register,
                          icon: const Icon(Icons.check),
                          label: const Text("Créer le compte"),
                        ),
                      ),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    "Déjà un compte ? Se connecter",
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
