import 'package:flutter/material.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fil d'actualité"),
      ),
      body: const Center(
        child: Text("Voici le fil d'actualité"),
      ),
    );
  }
}
