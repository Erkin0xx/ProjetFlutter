import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_project_app/pages/post_card.dart';
import 'package:flutter_project_app/pages/story_bar.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../models/post_provider.dart';
import '../models/user_model.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  Future<UserModel?> _fetchUser(String userId) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Colegram")),
      body: Column(
        children: [
          const StoryBar(), // ✅ Toujours affiché en haut
          Expanded(
            child: FutureBuilder<List<PostModel>>(
              future: postProvider.fetchAllPosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Erreur : ${snapshot.error}"));
                }

                final posts = snapshot.data ?? [];

                if (posts.isEmpty) {
                  return const Center(
                      child: Text("Aucune publication disponible."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return FutureBuilder<UserModel?>(
                      future: _fetchUser(post.userId),
                      builder: (context, userSnap) {
                        if (!userSnap.hasData) return const SizedBox.shrink();
                        return PostCard(post: post, user: userSnap.data!);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
