import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models/story_model.dart';
import '../widget/spotify_search_field.dart';

class AddStoryPage extends StatefulWidget {
  const AddStoryPage({super.key});

  @override
  State<AddStoryPage> createState() => _AddStoryPageState();
}

class _AddStoryPageState extends State<AddStoryPage> {
  File? _selectedMedia;
  bool _isUploading = false;
  String? _error;
  Map<String, String>? _selectedTrack;

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(pickedFile.path);
      final savedFile =
          await File(pickedFile.path).copy('${dir.path}/$fileName');

      setState(() => _selectedMedia = savedFile);
    }
  }

  Future<void> _uploadStory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedMedia == null) {
      setState(() => _error = "Media manquant.");
      return;
    }

    setState(() {
      _isUploading = true;
      _error = null;
    });

    final story = StoryModel(
      id: '',
      userId: user.uid,
      mediaPath: _selectedMedia!.path,
      createdAt: DateTime.now(),
      spotifyTrack: _selectedTrack,
    );

    await FirebaseFirestore.instance.collection('stories').add(story.toMap());

    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Story publiée avec musique 🎶 !")),
      );
    }
  }

  Future<void> _playPreview(String url) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      debugPrint("❌ Erreur lecture audio : $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[900] : Colors.grey[200];
    final borderColor = isDark ? Colors.white12 : Colors.black12;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter une story"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              onPressed: _isUploading ? null : _uploadStory,
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
            if (_error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error!,
                          style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),

            GestureDetector(
              onTap: _pickImage,
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(16),
                    image: _selectedMedia != null
                        ? DecorationImage(
                            image: FileImage(_selectedMedia!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selectedMedia == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate,
                                size: 40, color: Colors.grey.shade500),
                            const SizedBox(height: 8),
                            Text("Ajouter une image",
                                style: TextStyle(color: Colors.grey.shade500)),
                          ],
                        )
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 24),

            SpotifySearchField(
              onTrackSelected: (track) {
                setState(() => _selectedTrack = track);
                final previewUrl = track['previewUrl'];
                if (previewUrl != null && previewUrl.isNotEmpty) {
                  _playPreview(previewUrl);
                }
              },
            ),

            const SizedBox(height: 32),

            if (_isUploading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
