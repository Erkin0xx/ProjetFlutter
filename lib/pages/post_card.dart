import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final UserModel user;

  const PostCard({
    super.key,
    required this.post,
    required this.user,
  });

  Future<UserModel?> _fetchTaggedUser() async {
    if (post.taggedUserId == null) return null;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(post.taggedUserId!)
        .get();
    if (doc.exists) {
      return UserModel.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = "${post.createdAt.toLocal()}".split(' ')[0];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📷 Image avec superposition du header
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Image.file(
                  File(post.imagePath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
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
                                fontSize: 13,
                                color: Colors.white),
                          ),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 📝 Caption
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Text(post.caption),
            ),

          // 🧑‍🤝‍🧑 Tagged user
          if (post.taggedUserId != null)
            FutureBuilder<UserModel?>(
              future: _fetchTaggedUser(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                final tagged = snapshot.data!;
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
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
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
