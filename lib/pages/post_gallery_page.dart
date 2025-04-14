import 'dart:io';
import 'package:flutter/material.dart';
import '../models/post_model.dart';

class PostGalleryPage extends StatelessWidget {
  final List<PostModel> posts;
  final int initialIndex;

  const PostGalleryPage({
    super.key,
    required this.posts,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: initialIndex);

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: controller,
        scrollDirection: Axis.vertical,
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];

          return Stack(
            children: [
              // Image en carré centré
              Center(
                child: AspectRatio(
                  aspectRatio: 1, // carré
                  child: Image.file(
                    File(post.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Caption en bas
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black.withOpacity(0.7),
                  child: Text(
                    post.caption,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // Bouton retour
              Positioned(
                top: 40,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
