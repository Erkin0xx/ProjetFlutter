import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Chargement
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Redirection
        if (snapshot.hasData) {
          // Déjà connecté → home
          Future.microtask(() => context.go('/home'));
        } else {
          // Pas connecté → login
          Future.microtask(() => context.go('/login'));
        }

        // Retourne widget vide temporaire
        return const SizedBox.shrink();
      },
    );
  }
}
