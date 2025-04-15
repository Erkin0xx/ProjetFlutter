import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../models/user_provider.dart';
import '../main.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _ageController = TextEditingController();
  final _bioController = TextEditingController();

  bool _loading = false;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().currentUser;
    if (user != null) {
      _prenomController.text = user.prenom ?? '';
      _nomController.text = user.nom ?? '';
      _ageController.text = user.age?.toString() ?? '';
      _bioController.text = user.bio ?? '';
    }

    _darkMode = themeNotifier.value == ThemeMode.dark;
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    context.go('/login');
  }

  Future<void> _saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    final userProvider = context.read<UserProvider>();

    if (user == null) return;

    final prenom = _prenomController.text.trim();
    final nom = _nomController.text.trim();
    final age = int.tryParse(_ageController.text.trim());
    final bio = _bioController.text.trim();

    setState(() => _loading = true);

    final updatedUser = userProvider.currentUser!.copyWith(
      prenom: prenom,
      nom: nom,
      age: age,
      bio: bio,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update(updatedUser.toMap());

    userProvider.setUser(updatedUser);

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Profil mis à jour")),
    );
  }

  void _toggleDarkMode(bool value) {
    HapticFeedback.lightImpact();
    setState(() {
      _darkMode = value;
      themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final appUser = context.watch<UserProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Réglages")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 👤 Carte Profil
                  if (appUser != null)
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: appUser.avatarUrl != null &&
                                      File(appUser.avatarUrl!).existsSync()
                                  ? FileImage(File(appUser.avatarUrl!))
                                  : null,
                              child: appUser.avatarUrl == null
                                  ? const Icon(Icons.person, size: 30)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${appUser.prenom ?? ''} ${appUser.nom ?? ''}"
                                        .trim(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    firebaseUser?.email ?? '',
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  /// ✏️ Formulaires
                  TextField(
                    controller: _prenomController,
                    decoration: const InputDecoration(
                      labelText: "Prénom",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nomController,
                    decoration: const InputDecoration(
                      labelText: "Nom",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Âge",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Bio",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 💾 Bouton Enregistrer
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveChanges,
                      icon: const Icon(Icons.save),
                      label: const Text("Enregistrer"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.deepOrangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Divider(),

                  /// 🌙 Dark mode toggle
                  SwitchListTile(
                    value: _darkMode,
                    onChanged: _toggleDarkMode,
                    title: const Text("Mode sombre"),
                    secondary: const Icon(Icons.dark_mode),
                  ),

                  const Divider(),

                  /// 🚪 Déconnexion
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text("Se déconnecter"),
                    onTap: _signOut,
                  ),
                ],
              ),
            ),
    );
  }
}
