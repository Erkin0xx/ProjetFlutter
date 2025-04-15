import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_app/pages/add_story_page.dart';
import 'package:flutter_project_app/pages/create_highlight_page.dart';
import 'package:flutter_project_app/pages/feed_pages.dart';
import 'package:flutter_project_app/pages/post_pages.dart';
import 'package:flutter_project_app/pages/account_page.dart';
import 'package:flutter_project_app/pages/complete_profil_page.dart';
import 'package:flutter_project_app/pages/home_page.dart';
import 'package:flutter_project_app/pages/login_page.dart';
import 'package:flutter_project_app/pages/register_page.dart';
import 'package:flutter_project_app/pages/story_viewer_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

GoRouter createAppRouter(ValueNotifier<ThemeMode> themeNotifier) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) async {
      final user = FirebaseAuth.instance.currentUser;
      final location = state.uri.path;
      final isAuthPage = location == '/login' || location == '/register';

      // 🔐 Si non connecté
      if (user == null) {
        return isAuthPage ? null : '/login';
      }

      // 🔄 Récupère les infos du Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();
      final isProfileIncomplete = data == null ||
          data['prenom'] == null ||
          data['nom'] == null ||
          data['age'] == null;

      // 🔁 Redirige vers /complete-profile si profil incomplet
      if (isProfileIncomplete && location != '/complete-profile') {
        return '/complete-profile';
      }

      // 🔁 Si déjà connecté, empêche retour à /login ou /register
      if (!isProfileIncomplete && isAuthPage) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/complete-profile',
        builder: (context, state) => const CompleteProfilePage(),
      ),
      GoRoute(
        path: '/post',
        builder: (context, state) => const PostPage(),
      ),
      GoRoute(
        path: '/add-story',
        builder: (context, state) => const AddStoryPage(),
      ),
      GoRoute(
        path: '/create-highlight',
        builder: (context, state) => const CreateHighlightPage(),
      ),
      GoRoute(
        path: '/account',
        builder: (context, state) => const AccountPage(),
      ),
      GoRoute(
        path: '/story-viewer',
        pageBuilder: (context, state) {
          final stories = state.extra as List<Map<String, dynamic>>;
          final index =
              int.tryParse(state.uri.queryParameters['index'] ?? '0') ?? 0;

          return CustomTransitionPage(
            child: StoryViewerPage(stories: stories, initialIndex: index),
            transitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (context, animation, _, child) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale:
                      Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
          );
        },
      ),
    ],
  );
}
