import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_project_app/pages/post_gallery_page.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/user_provider.dart';
import '../models/post_model.dart';
import '../models/post_provider.dart';
import 'user_settings_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Mon profil")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Utilisateur non connecté"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.go('/login');
                },
                child: const Text("Se connecter"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon profil"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserSettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Profil header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: user.avatarUrl != null
                      ? (user.avatarUrl!.startsWith('http')
                          ? NetworkImage(user.avatarUrl!)
                          : FileImage(File(user.avatarUrl!)) as ImageProvider)
                      : null,
                  child: user.avatarUrl == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${user.prenom ?? ''} ${user.nom ?? ''}".trim(),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(user.email,
                          style: const TextStyle(color: Colors.grey)),
                      if (user.age != null)
                        Text("Âge : ${user.age}",
                            style: const TextStyle(color: Colors.grey)),
                      if (user.bio != null && user.bio!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            user.bio!,
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black87,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // Liste des posts utilisateur en grille
          Expanded(
            child: FutureBuilder<List<PostModel>>(
              future: context.read<PostProvider>().fetchUserPosts(user.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print("🔥 Firestore Error: ${snapshot.error}");
                  return Center(child: Text("Erreur : ${snapshot.error}"));
                }

                final posts = snapshot.data ?? [];

                if (posts.isEmpty) {
                  return const Center(child: Text("Aucune publication"));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PostGalleryPage(
                              posts: posts,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.file(
                          File(post.imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
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
