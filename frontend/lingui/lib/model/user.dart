class User {
  final String id;
  final String username;
  final String profilePhoto;

  const User(
      {required this.id, required this.profilePhoto, required this.username});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['uid'],
        profilePhoto: json['photo'],
        username: json['username']);
  }
}
