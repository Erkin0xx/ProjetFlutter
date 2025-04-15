import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

class PostGalleryPage extends StatelessWidget {
  final List<PostModel> posts;
  final int initialIndex;

  const PostGalleryPage({
    super.key,
    required this.posts,
    required this.initialIndex,
  });

  Future<UserModel?> _fetchUser(String userId) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  Future<UserModel?> _fetchTaggedUser(String taggedUserId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(taggedUserId)
        .get();
    if (doc.exists) {
      return UserModel.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = PageController(initialPage: initialIndex);

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: controller,
        scrollDirection: Axis.vertical,
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          final formattedDate = "${post.createdAt.toLocal()}".split(' ')[0];

          return FutureBuilder<UserModel?>(
            future: _fetchUser(post.userId),
            builder: (context, userSnapshot) {
              final user = userSnapshot.data;
              return Stack(
                children: [
                  // 📷 Image au centre (carrée)
                  Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.file(
                        File(post.imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // 👤 Overlay header (avatar + pseudo + date)
                  if (user != null)
                    Positioned(
                      top: 50,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: user.avatarUrl != null
                                  ? FileImage(File(user.avatarUrl!))
                                  : null,
                              backgroundColor: Colors.grey.shade800,
                              child: user.avatarUrl == null
                                  ? const Icon(Icons.person, size: 16)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.username,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 🔙 Bouton retour
                  Positioned(
                    top: 50,
                    right: 20,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ),

                  // 📄 Caption + tagged user dans un container flouté
                  Positioned(
                    bottom: 30,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (post.caption.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                post.caption,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          if (post.taggedUserId != null)
                            FutureBuilder<UserModel?>(
                              future: _fetchTaggedUser(post.taggedUserId!),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return const SizedBox();
                                final tagged = snapshot.data!;
                                return Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundImage: tagged.avatarUrl != null
                                          ? FileImage(File(tagged.avatarUrl!))
                                          : null,
                                      backgroundColor: Colors.grey.shade700,
                                      child: tagged.avatarUrl == null
                                          ? const Icon(Icons.person, size: 14)
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "avec @${tagged.username}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.white70,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
