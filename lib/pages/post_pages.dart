import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_project_app/models/post_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/post_model.dart';
import '../models/user_model.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final _captionController = TextEditingController();
  final _searchController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;
  String? _taggedUserId;
  String? _taggedUsername;

  List<UserModel> _searchResults = [];

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

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final results = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query.toLowerCase())
        .where('username', isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff')
        .get();

    setState(() {
      _searchResults = results.docs.map((doc) {
        return UserModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  void _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final caption = _captionController.text.trim();

    if (_selectedImage == null || caption.isEmpty) {
      _showErrorToast("Image et légende obligatoires.");
      return;
    }

    setState(() => _isLoading = true);

    final newPost = PostModel(
      id: '',
      userId: user.uid,
      imagePath: _selectedImage!.path,
      caption: caption,
      createdAt: DateTime.now(),
      taggedUserId: _taggedUserId,
    );

    final postProvider = Provider.of<PostProvider>(context, listen: false);
    await postProvider.addPost(newPost);

    setState(() {
      _isLoading = false;
      _captionController.clear();
      _searchController.clear();
      _selectedImage = null;
      _taggedUserId = null;
      _taggedUsername = null;
      _searchResults = [];
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Publication envoyée !")),
      );
      context.go('/home');
    }
  }

  void _showErrorToast(String message) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Colors.redAccent.shade200,
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[900] : Colors.grey[200];
    final borderColor = isDark ? Colors.white12 : Colors.black12;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer une publication"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              onPressed: _isLoading ? null : _submit,
              icon: const Icon(Icons.send_rounded,
                  color: Colors.deepOrangeAccent),
              tooltip: "Publier",
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// 🖼 Image preview carrée
            GestureDetector(
              onTap: _pickImage,
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(14),
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add_photo_alternate,
                                size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text("Ajouter une image",
                                style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// 📝 Légende
            TextField(
              controller: _captionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Légende",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            /// 🔍 Tag utilisateur
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Taguer un utilisateur",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _searchUsers,
            ),

            if (_searchResults.isNotEmpty)
              ..._searchResults.map((user) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.avatarUrl != null
                        ? FileImage(File(user.avatarUrl!))
                        : null,
                    child: user.avatarUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(user.username),
                  onTap: () {
                    setState(() {
                      _taggedUserId = user.id;
                      _taggedUsername = user.username;
                      _searchResults = [];
                      _searchController.text = "@${user.username}";
                    });
                  },
                );
              }),

            if (_taggedUsername != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "Utilisateur tagué : @$_taggedUsername",
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
