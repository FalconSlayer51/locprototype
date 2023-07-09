class UserModel {
  final String username;
  final String uid;
  final String profilePhoto;

  UserModel({
    required this.username,
    required this.uid,
    required this.profilePhoto,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'uid': uid,
      'profilePhoto': profilePhoto,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['name'] ?? '',
      uid: map['uid'] ?? '',
      profilePhoto: map['profilePhoto'] ?? '',
    );
  }
}
