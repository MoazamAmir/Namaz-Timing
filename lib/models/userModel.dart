class UserModel {
  String uid;
  String email;
  String name;
  String photoUrl;
  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.photoUrl,
  });
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
    };
  }
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      photoUrl: map['photoUrl'],
    );
  }
}