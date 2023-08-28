class UserModel {
  String? uid;
  String? nickname;
  String? email;
  String? profileImage;
  String? role;

  UserModel({this.uid, this.nickname, this.email,this.profileImage,this.role});

  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      nickname: map['nickname'],
      email: map['email'],
      profileImage:map['profileImage'],
      role:map['role'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nickname':nickname,
      'email': email,
      'profileImage': profileImage,
      'role':role,
    };
  }

}
