import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/highlight_group_model.dart';
import '../models/story_model.dart';
import '../models/user_model.dart';
import '../pages/story_viewer_page.dart';

class HighlightGroupBar extends StatefulWidget {
  final String userId;
  final VoidCallback? onAddTap;

  const HighlightGroupBar({
    super.key,
    required this.userId,
    this.onAddTap,
  });

  @override
  State<HighlightGroupBar> createState() => HighlightGroupBarState();
}

class HighlightGroupBarState extends State<HighlightGroupBar> {
  List<Map<String, dynamic>> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    try {
      setState(() => _isLoading = true);

      final groupsSnapshot = await FirebaseFirestore.instance
          .collection('highlights')
          .where('userId', isEqualTo: widget.userId)
          .get();

      final List<Map<String, dynamic>> result = [];

      for (final doc in groupsSnapshot.docs) {
        final group = HighlightGroup.fromMap(doc.id, doc.data());

        final storiesSnapshot = await FirebaseFirestore.instance
            .collection('stories')
            .where(FieldPath.documentId, whereIn: group.storyIds)
            .get();

        final stories = storiesSnapshot.docs.map((s) {
          return StoryModel.fromMap(s.id, s.data());
        }).toList();

        result.add({
          'group': group,
          'stories': stories,
        });
      }

      if (mounted) {
        setState(() {
          _groups = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("\uD83D\uDD25 Erreur chargement highlights : $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> refresh() async {
    debugPrint("\uD83D\uDD04 Appel de refresh() async");
    await _loadGroups();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _groups.length + 1,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            // Bouton Ajouter
            return GestureDetector(
              onTap: widget.onAddTap,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      padding: const EdgeInsets.all(2.5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFE1306C),
                            Color(0xFFF56040),
                            Color(0xFFFCAF45),
                          ],
                        ),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text("Moi", style: TextStyle(fontSize: 12))
                  ],
                ),
              ),
            );
          }

          final group = _groups[index - 1]['group'] as HighlightGroup;
          final stories = _groups[index - 1]['stories'] as List<StoryModel>;

          return GestureDetector(
            onTap: () {
              final user = UserModel(
                id: widget.userId,
                email: '',
                username: group.name,
                avatarUrl: group.coverPath,
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StoryViewerPage(
                    stories: stories
                        .map((story) => {
                              'story': story,
                              'user': user,
                            })
                        .toList(),
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    padding: const EdgeInsets.all(2.5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFE1306C),
                          Color(0xFFF56040),
                          Color(0xFFFCAF45),
                        ],
                      ),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: ClipOval(
                        child: File(group.coverPath).existsSync()
                            ? Image.file(File(group.coverPath),
                                fit: BoxFit.cover)
                            : Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.image,
                                    color: Colors.black38),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    group.name,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
