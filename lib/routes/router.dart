import 'package:flutter/material.dart';
import 'package:flutter_project_app/pages/feed_pages.dart';
import 'package:flutter_project_app/pages/post_pages.dart';
import 'package:flutter_project_app/pages/account_page.dart';
import 'package:flutter_project_app/pages/auth_wrapper.dart';
import 'package:flutter_project_app/pages/complete_profil_page.dart';
import 'package:flutter_project_app/pages/home_page.dart';
import 'package:flutter_project_app/pages/login_page.dart';
import 'package:flutter_project_app/pages/register_page.dart';
import 'package:go_router/go_router.dart';

GoRouter createAppRouter(ValueNotifier<ThemeMode> themeNotifier) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthWrapper(),
      ),
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
        builder: (context, state) => HomePage(),
      ),
      GoRoute(
        path: '/complete-profile',
        builder: (context, state) => const CompleteProfilePage(),
      ),
      GoRoute(
        path: '/post',
        builder: (context, state) => const PostPage(),
      ),
    ],
  );
}
