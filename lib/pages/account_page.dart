import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_project_app/pages/post_gallery_viewer_page.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/user_provider.dart';
import '../models/post_model.dart';
import '../models/post_provider.dart';
import '../pages/highlight_group_bar.dart';
import 'user_settings_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final GlobalKey<HighlightGroupBarState> _highlightKey =
      GlobalKey<HighlightGroupBarState>();

  Future<void> _navigateToCreateHighlight(BuildContext context) async {
    final result = await context.push('/create-highlight');
    if (result == true) {
      _highlightKey.currentState?.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Mon profil")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Utilisateur non connecté",
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => context.push('/login'),
                icon: const Icon(Icons.login),
                label: const Text("Se connecter"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  foregroundColor: Colors.white,
                ),
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
            tooltip: "Modifier le profil",
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
          // 🧑🏼‍🎨 Profil header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 👤 Avatar sans bouton appareil photo
                CircleAvatar(
                  radius: 45,
                  backgroundImage: user.avatarUrl != null
                      ? (user.avatarUrl!.startsWith('http')
                          ? NetworkImage(user.avatarUrl!)
                          : FileImage(File(user.avatarUrl!)) as ImageProvider)
                      : null,
                  backgroundColor: Colors.grey[300],
                  child: user.avatarUrl == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom + Prénom (en gras)
                      Text(
                        "${user.prenom ?? ''} ${user.nom ?? ''}".trim(),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      // @username + prénom
                      if (user.username != null)
                        Text(
                          "@${user.username}",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey),
                        ),
                      // Âge
                      if (user.age != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            "${user.age} ans",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey),
                          ),
                        ),
                      // Bio
                      if (user.bio?.isNotEmpty ?? false)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            user.bio!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey.shade600,
                                    ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ⭐ Highlights
          HighlightGroupBar(
            key: _highlightKey,
            userId: user.id,
            onAddTap: () => _navigateToCreateHighlight(context),
          ),

          const Divider(height: 0),

          // 🖼️ Publications
          Expanded(
            child: FutureBuilder<List<PostModel>>(
              future: context.read<PostProvider>().fetchUserPosts(user.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Erreur : ${snapshot.error}",
                        style: const TextStyle(color: Colors.red)),
                  );
                }

                final posts = snapshot.data ?? [];

                if (posts.isEmpty) {
                  return const Center(
                    child: Text("Aucune publication",
                        style: TextStyle(color: Colors.grey)),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: posts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
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
                        borderRadius: BorderRadius.circular(8),
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
