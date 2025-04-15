import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_app/models/user_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/story_model.dart';
import '../models/user_model.dart';

class StoryBar extends StatefulWidget {
  const StoryBar({super.key});

  @override
  State<StoryBar> createState() => _StoryBarState();
}

class _StoryBarState extends State<StoryBar> {
  late Future<List<Map<String, dynamic>>> _storiesFuture;

  @override
  void initState() {
    super.initState();
    _storiesFuture = _fetchStories();
  }

  Future<List<Map<String, dynamic>>> _fetchStories() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('stories')
        .orderBy('createdAt', descending: true)
        .get();

    final Map<String, List<StoryModel>> groupedStories = {};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final story = StoryModel.fromMap(doc.id, data);
      groupedStories.putIfAbsent(story.userId, () => []);
      groupedStories[story.userId]!.add(story);
    }

    final List<Map<String, dynamic>> result = [];
    for (final entry in groupedStories.entries) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(entry.key)
          .get();

      if (userDoc.exists) {
        result.add({
          'stories': entry.value,
          'user': UserModel.fromMap(userDoc.id, userDoc.data()!),
        });
      }
    }

    return result;
  }

  Future<void> _handleAddStory(BuildContext context) async {
    final result = await context.push('/add-story');
    if (result == true) {
      setState(() {
        _storiesFuture = _fetchStories();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 105,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _storiesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final grouped = snapshot.data!;

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: grouped.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                final userProvider = context.read<UserProvider>();
                final avatarPath = userProvider.currentUser?.avatarUrl;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => _handleAddStory(context),
                        child: Container(
                          width: 64,
                          height: 64,
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFfeda75),
                                Color(0xFFfa7e1e),
                                Color(0xFFd62976),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ClipOval(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (avatarPath != null &&
                                    File(avatarPath).existsSync())
                                  ImageFiltered(
                                    imageFilter:
                                        ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                                    child: Image.file(
                                      File(avatarPath),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                else
                                  Container(color: Colors.grey[300]),
                                const Center(
                                  child: Icon(Icons.add,
                                      color: Colors.white, size: 28),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text("Moi", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              }

              final user = grouped[index - 1]['user'] as UserModel;
              final stories = grouped[index - 1]['stories'] as List<StoryModel>;

              final formattedStories =
                  stories.map((s) => {'story': s, 'user': user}).toList();

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.push(
                          '/story-viewer?index=0',
                          extra: formattedStories,
                        );
                      },
                      child: Container(
                        width: 64,
                        height: 64,
                        padding: const EdgeInsets.all(2.5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFfeda75),
                              Color(0xFFfa7e1e),
                              Color(0xFFd62976),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: user.avatarUrl != null
                              ? FileImage(File(user.avatarUrl!))
                              : null,
                          backgroundColor: Colors.grey[300],
                          child: user.avatarUrl == null
                              ? const Icon(Icons.person, size: 30)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.username,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
