import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_project_app/models/user_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../models/user_model.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _ageController = TextEditingController();

  File? _selectedImage;
  bool _loading = false;
  String? _error;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(pickedFile.path);
      final savedImage =
          await File(pickedFile.path).copy('${appDir.path}/$fileName');

      setState(() {
        _selectedImage = savedImage;
      });
    }
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final prenom = _prenomController.text.trim();
    final nom = _nomController.text.trim();
    final age = int.tryParse(_ageController.text.trim());

    if (user == null ||
        prenom.isEmpty ||
        nom.isEmpty ||
        age == null ||
        _selectedImage == null) {
      setState(
        () => _error = "Tous les champs sont requis, y compris la photo.",
      );
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final avatarUrl = _selectedImage!.path;

    final userData = UserModel(
      id: user.uid,
      email: user.email ?? '',
      username: prenom.toLowerCase(),
      avatarUrl: avatarUrl,
      prenom: prenom,
      nom: nom,
      age: age,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(userData.toMap());

    userProvider.setUser(userData);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseTextColor = isDark ? Colors.white : Colors.black87;
    final iconColor = isDark ? Colors.white : Colors.black54;

    return Scaffold(
      appBar: AppBar(title: const Text("Compléter mon profil")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
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
                      const Icon(Icons.error_outline, color: Colors.redAccent),
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
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : null,
                  child: _selectedImage == null
                      ? Icon(Icons.add_a_photo, size: 30, color: iconColor)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _prenomController,
                style: TextStyle(color: baseTextColor),
                decoration: InputDecoration(
                  labelText: "Prénom",
                  labelStyle: TextStyle(color: baseTextColor),
                  prefixIcon: Icon(Icons.person, color: iconColor),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nomController,
                style: TextStyle(color: baseTextColor),
                decoration: InputDecoration(
                  labelText: "Nom",
                  labelStyle: TextStyle(color: baseTextColor),
                  prefixIcon: Icon(Icons.person_outline, color: iconColor),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: baseTextColor),
                decoration: InputDecoration(
                  labelText: "Âge",
                  labelStyle: TextStyle(color: baseTextColor),
                  prefixIcon: Icon(Icons.cake, color: iconColor),
                ),
              ),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveProfile,
                        icon: const Icon(Icons.check),
                        label: const Text("Valider mon profil"),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
