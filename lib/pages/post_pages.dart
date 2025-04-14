import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_project_app/models/post_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../models/post_model.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final _captionController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;
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

  void _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final caption = _captionController.text.trim();

    if (_selectedImage == null || caption.isEmpty) {
      setState(() => _error = "Image et légende obligatoires.");
      return;
    }

    setState(() => _isLoading = true);

    final newPost = PostModel(
      id: '',
      userId: user.uid,
      imagePath: _selectedImage!.path,
      caption: caption,
      createdAt: DateTime.now(),
    );

    final postProvider = Provider.of<PostProvider>(context, listen: false);
    await postProvider.addPost(newPost);

    setState(() {
      _isLoading = false;
      _captionController.clear();
      _selectedImage = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Publication envoyée !")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer une publication")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selectedImage == null
                      ? const Center(
                          child: Icon(Icons.add_a_photo, size: 50),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _captionController,
                decoration: const InputDecoration(labelText: "Légende"),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.send),
                      label: const Text("Publier"),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
