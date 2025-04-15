import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/story_model.dart';

class CreateHighlightPage extends StatefulWidget {
  const CreateHighlightPage({super.key});

  @override
  State<CreateHighlightPage> createState() => _CreateHighlightPageState();
}

class _CreateHighlightPageState extends State<CreateHighlightPage> {
  final TextEditingController _nameController = TextEditingController();
  File? _coverImage;
  final Set<String> _selectedStoryIds = {};

  Future<List<StoryModel>> _fetchUserStories() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('stories')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return StoryModel.fromMap(doc.id, doc.data());
      }).toList();
    } catch (e) {
      debugPrint("🔥 Erreur de récupération des stories : $e");
      rethrow;
    }
  }

  Future<void> _pickCoverImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final directory = await getApplicationDocumentsDirectory();
      final copied = await File(picked.path)
          .copy('${directory.path}/${path.basename(picked.path)}');
      setState(() => _coverImage = copied);
    }
  }

  Future<void> _saveHighlight() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null ||
        _nameController.text.trim().isEmpty ||
        _coverImage == null ||
        _selectedStoryIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Remplis tous les champs.")),
      );
      return;
    }

    final highlightData = {
      'userId': userId,
      'name': _nameController.text.trim(),
      'coverPath': _coverImage!.path,
      'storyIds': _selectedStoryIds.toList(),
    };

    await FirebaseFirestore.instance
        .collection('highlights')
        .add(highlightData);

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final bool coverExists = _coverImage != null && _coverImage!.existsSync();

    return Scaffold(
      appBar: AppBar(title: const Text("Créer un Highlight")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickCoverImage,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: coverExists ? FileImage(_coverImage!) : null,
                child: !coverExists
                    ? const Icon(Icons.add_a_photo, size: 30)
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Nom du groupe"),
            ),
            const SizedBox(height: 20),
            const Text("Sélectionne les stories à inclure :"),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<StoryModel>>(
                future: _fetchUserStories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Erreur : ${snapshot.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final stories = snapshot.data ?? [];

                  if (stories.isEmpty) {
                    return const Center(
                        child: Text("Aucune story disponible."));
                  }

                  return ListView.builder(
                    itemCount: stories.length,
                    itemBuilder: (context, index) {
                      final story = stories[index];
                      final selected = _selectedStoryIds.contains(story.id);

                      return ListTile(
                        leading: Image.file(
                          File(story.mediaPath),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported),
                        ),
                        title: Text("Story ${index + 1}"),
                        trailing: Checkbox(
                          value: selected,
                          onChanged: (_) {
                            setState(() {
                              selected
                                  ? _selectedStoryIds.remove(story.id)
                                  : _selectedStoryIds.add(story.id);
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: _saveHighlight,
              icon: const Icon(Icons.check),
              label: const Text("Créer"),
            ),
          ],
        ),
      ),
    );
  }
}
