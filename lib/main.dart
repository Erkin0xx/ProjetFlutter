import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'services/spotify_service.dart';
import 'models/post_provider.dart';
import 'models/user_provider.dart';
import 'routes/router.dart';
import 'theme/theme.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: false);
  await SpotifyService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider()
            ..loadUserFromFirestore(
                FirebaseAuth.instance.currentUser?.uid ?? ''),
        ),
        ChangeNotifierProvider<PostProvider>(
          create: (_) => PostProvider(),
        ),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, mode, _) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: MaterialApp.router(
              key: ValueKey(mode),
              debugShowCheckedModeBanner: false,
              title: 'Colegram',
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
