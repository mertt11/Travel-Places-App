


class Place {
  Place({
    required this.uid,
    required this.title,
    required this.text,
    required this.nickname,
    required this.postImage,
    required this.profileImage,
    required this.datePublished,
    required this.likes,
    required this.postId,
  });

  //uid is user id
  final String uid;
  final String title;
  final String text;
  final String nickname;
  final String postImage;
  final String postId;
  final String profileImage;
  final DateTime datePublished;
  final List likes;


  factory Place.fromMap(Map<String, dynamic> map) {

    return Place(
      nickname:map['nickname'],
      uid:map['uid'],
      title: map['title'],
      text: map['text'],
      postImage: map['postImage'], 
      profileImage:map['profileImage'],
      datePublished: map["datePublished"],
      likes: map["likes"],
      postId: map["postId"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid':uid,
      'title': title,
      'text': text,
      'postImage': postImage,
      'nickname':nickname, 
      'profileImage':profileImage, 
      'datePublished':datePublished, 
      'likes':likes, 
      'postId':postId, 
    };
  }

  

}
