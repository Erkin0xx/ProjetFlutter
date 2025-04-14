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
          () => _error = "Tous les champs sont requis, y compris la photo.");
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
    return Scaffold(
      appBar: AppBar(title: const Text("Compléter mon profil")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : null,
                  child: _selectedImage == null
                      ? const Icon(Icons.add_a_photo, size: 30)
                      : null,
                ),
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
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.check),
                      label: const Text("Valider mon profil"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
