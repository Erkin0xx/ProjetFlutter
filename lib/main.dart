import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'package:flutter_project_app/models/post_provider.dart';
import 'package:flutter_project_app/models/user_provider.dart';
import 'package:flutter_project_app/routes/router.dart';
import 'package:flutter_project_app/theme/theme.dart';
import 'firebase_options.dart';

/// 🌗 Notifier global pour changer de thème dynamiquement
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: false);

  final currentUser = FirebaseAuth.instance.currentUser;

  runApp(MyApp(currentUser: currentUser));
}

class MyApp extends StatelessWidget {
  final User? currentUser;

  const MyApp({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(
          create: (_) =>
              UserProvider()..loadUserFromFirestore(currentUser?.uid ?? ''),
        ),
        ChangeNotifierProvider<PostProvider>(
          create: (_) => PostProvider(),
        ),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, mode, _) {
          final themeData = mode == ThemeMode.dark ? darkTheme : lightTheme;

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: MaterialApp.router(
              key: ValueKey(mode), // Important pour déclencher l'animation
              title: 'Social App',
              debugShowCheckedModeBanner: false,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: mode,
              routerConfig: createAppRouter(themeNotifier),
            ),
          );
        },
      ),
    );
  }
}
