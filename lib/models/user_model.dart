class UserModel {
  final String id;
  final String email;
  final String username;
  final String? avatarUrl;
  final String? prenom;
  final String? nom;
  final int? age;
  final String? bio;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.avatarUrl,
    this.prenom,
    this.nom,
    this.age,
    this.bio,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      avatarUrl: data['avatarUrl'],
      prenom: data['prenom'],
      nom: data['nom'],
      age: data['age'],
      bio: data['bio'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'avatarUrl': avatarUrl,
      'prenom': prenom,
      'nom': nom,
      'age': age,
      'bio': bio,
    };
  }

  UserModel copyWith({
    String? avatarUrl,
    String? prenom,
    String? nom,
    int? age,
    String? bio,
    String? username,
  }) {
    return UserModel(
      id: id,
      email: email,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      prenom: prenom ?? this.prenom,
      nom: nom ?? this.nom,
      age: age ?? this.age,
      bio: bio ?? this.bio,
    );
  }
}
