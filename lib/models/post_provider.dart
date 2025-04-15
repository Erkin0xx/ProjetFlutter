import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class PostProvider extends ChangeNotifier {
  final CollectionReference _postRef =
      FirebaseFirestore.instance.collection('posts');

  /// 🔥 Création d’un post avec ou sans utilisateur tagué
  Future<void> addPost(PostModel post) async {
    final docRef = _postRef.doc();

    await docRef.set({
      'userId': post.userId,
      'imagePath': post.imagePath,
      'caption': post.caption,
      'createdAt': FieldValue.serverTimestamp(),
      'taggedUserId': post.taggedUserId, // 🆕
    });

    await Future.delayed(const Duration(milliseconds: 500));
    notifyListeners();
  }

  /// 🔁 Stream live des posts d’un utilisateur
  Stream<List<PostModel>> getUserPosts(String userId) {
    return _postRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PostModel.fromMap(doc.id, data);
      }).toList();
    });
  }

  /// ✅ Récupération unique des posts d’un utilisateur
  Future<List<PostModel>> fetchUserPosts(String userId) async {
    final querySnapshot = await _postRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return PostModel.fromMap(doc.id, data);
    }).toList();
  }

  /// 🆕 Récupération de tous les posts récents
  Future<List<PostModel>> fetchAllPosts() async {
    final querySnapshot =
        await _postRef.orderBy('createdAt', descending: true).get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return PostModel.fromMap(doc.id, data);
    }).toList();
  }
}
