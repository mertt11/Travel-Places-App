import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_places/screen/post/comment_screen.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class PostCard extends StatefulWidget {
  const PostCard({super.key, required this.snap});
  //post's snap
  final snap;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  String nickname='';
  String profileImage='';
  int commentLength=0;

  likePost() async {
    String uid = _auth.currentUser!.uid;
    String postId = widget.snap['postId'];
    List likes = widget.snap['likes'];
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    getNickNameAndProfileUrlAndCommentLength();
    super.initState();
  }

  void deletePost(String postId) async{
      DocumentReference ref= _firestore.collection('posts').doc(postId);
      DocumentSnapshot postSnapshot=await ref.get();
      String uid=(postSnapshot.data() as Map<String,dynamic>)['uid'];
    if(uid==_auth.currentUser!.uid){
      DocumentSnapshot commentsSnapshot = await ref.collection('comments').doc(postId).get();
      if(commentsSnapshot.exists){
        //deleting each comment in the posts
        QuerySnapshot commentsSnapshot = await ref.collection('comments').get();
        for (QueryDocumentSnapshot commentDoc in commentsSnapshot.docs) {
          await commentDoc.reference.delete();
        }
      }
      await _firestore.collection('posts').doc(postId).delete();
    }else{
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are not the owner of the post.'),
        ),
      );
    }
  }

  void getNickNameAndProfileUrlAndCommentLength() async{

    QuerySnapshot commentSnapshot= await _firestore.collection('posts').doc(widget.snap['postId']).collection('comments').get();
    commentLength = commentSnapshot.docs.length;

    DocumentSnapshot userSnapshot= await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
      setState(() {
        nickname=(userSnapshot.data() as Map<String,dynamic>)['nickname'];
        profileImage=(userSnapshot.data() as Map<String,dynamic>)['profileImage'];
      });

  }


  @override
  Widget build(BuildContext context) {
    //snap denilen şey post tan alıyor bilgileri
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              child: Row(
                children: [
                  CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(widget.snap['profileImage'])),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(widget.snap['nickname'],
                      style: const TextStyle(color: Colors.black54)),
                  const Spacer(),
                  IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => Dialog(
                                  child: ListView(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shrinkWrap: true,
                                    children: [
                                      'Delete',
                                    ]
                                        .map((e) => InkWell(
                                              onTap: () async{deletePost(widget.snap['postId']);Navigator.of(context).pop();},
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                        horizontal: 16),
                                                child: Text(
                                                  e,
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ));
                      },
                      icon: const Icon(Icons.more_vert))
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              child: Image.network(
                widget.snap['postImage'],
                fit: BoxFit.cover,
              ),
            ),
            Row(
              children: [
                IconButton(
                    onPressed: () {
                      likePost();
                    },
                    icon: widget.snap['likes'].contains(_auth.currentUser!.uid)
                        ? const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          )
                        : const Icon(
                            Icons.favorite_border,
                            color: Colors.red,
                          ),),
                IconButton(onPressed: () {}, icon: const Icon(Icons.comment)),
              ],
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.snap['likes'].length} likes',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onBackground),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 8),
                      child: RichText(
                        text: TextSpan(
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onBackground),
                            children: [
                              TextSpan(
                                text: widget.snap['title'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: '  ${widget.snap['text']}'),
                            ]),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CommentScreen(
                                postId: widget.snap['postId'],
                            ),
                        ),);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '$commentLength comments',
                          style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context).colorScheme.onBackground),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
  }
}
