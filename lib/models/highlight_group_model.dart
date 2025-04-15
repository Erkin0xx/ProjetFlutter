class HighlightGroup {
  final String id;
  final String userId;
  final String name;
  final String coverPath;
  final List<String> storyIds;

  HighlightGroup({
    required this.id,
    required this.userId,
    required this.name,
    required this.coverPath,
    required this.storyIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'coverPath': coverPath,
      'storyIds': storyIds,
    };
  }

  static HighlightGroup fromMap(String id, Map<String, dynamic> data) {
    return HighlightGroup(
      id: id,
      userId: data['userId'],
      name: data['name'],
      coverPath: data['coverPath'],
      storyIds: List<String>.from(data['storyIds'] ?? []),
    );
  }
}
