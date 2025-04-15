class StoryModel {
  final String id;
  final String userId;
  final String mediaPath;
  final DateTime createdAt;
  final bool isHighlight;
  final Map<String, dynamic>? spotifyTrack; // 👈 Musique optionnelle

  StoryModel({
    required this.id,
    required this.userId,
    required this.mediaPath,
    required this.createdAt,
    this.isHighlight = false,
    this.spotifyTrack,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'mediaPath': mediaPath,
      'createdAt': createdAt.toIso8601String(),
      'isHighlight': isHighlight,
      'spotifyTrack': spotifyTrack,
    };
  }

  static StoryModel fromMap(String id, Map<String, dynamic> data) {
    return StoryModel(
      id: id,
      userId: data['userId'] ?? '',
      mediaPath: data['mediaPath'] ?? '',
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
      isHighlight: data['isHighlight'] ?? false,
      spotifyTrack: data['spotifyTrack'],
    );
  }
}
