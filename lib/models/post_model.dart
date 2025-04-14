import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String imagePath; // chemin local de l'image
  final String caption;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.userId,
    required this.imagePath,
    required this.caption,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'imagePath': imagePath,
      'caption': caption,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static PostModel fromMap(String id, Map<String, dynamic> data) {
    final timestamp = data['createdAt'];
    final createdAt = timestamp is Timestamp
        ? timestamp.toDate()
        : DateTime.tryParse(timestamp?.toString() ?? '') ?? DateTime.now();

    return PostModel(
      id: id,
      userId: data['userId'],
      imagePath: data['imagePath'],
      caption: data['caption'],
      createdAt: createdAt,
    );
  }
}
