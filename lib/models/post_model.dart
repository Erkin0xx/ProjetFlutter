import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String imagePath;
  final String caption;
  final DateTime createdAt;
  final String? taggedUserId;

  PostModel({
    required this.id,
    required this.userId,
    required this.imagePath,
    required this.caption,
    required this.createdAt,
    this.taggedUserId,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'imagePath': imagePath,
      'caption': caption,
      'createdAt': createdAt.toIso8601String(),
      'taggedUserId': taggedUserId,
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
      taggedUserId: data['taggedUserId'],
    );
  }
}
