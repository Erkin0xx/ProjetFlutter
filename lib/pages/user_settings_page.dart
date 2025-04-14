import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/user_provider.dart';
import '../models/user_model.dart';
import '../main.dart';
import 'package:flutter/services.dart'; // pour HapticFeedback

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

    // Init mode sombre
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
      const SnackBar(content: Text("Profil mis à jour !")),
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
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Réglages")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (user != null)
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text("Email"),
                      subtitle: Text(user.email ?? "Inconnu"),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _prenomController,
                    decoration: const InputDecoration(labelText: "Prénom"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nomController,
                    decoration: const InputDecoration(labelText: "Nom"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Âge"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: "Bio"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _saveChanges,
                    icon: const Icon(Icons.save),
                    label: const Text("Enregistrer les modifications"),
                  ),
                  const Divider(height: 40),

                  // 🌗 Switch mode sombre
                  SwitchListTile(
                    secondary: const Icon(Icons.brightness_6),
                    title: const Text("Mode sombre"),
                    value: _darkMode,
                    onChanged: _toggleDarkMode,
                  ),

                  const Divider(height: 40),
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
