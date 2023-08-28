import 'package:flutter/material.dart';
import 'package:travel_places/widget/header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  String nickname = '';
  String profileImage = '';
  var postCount = 0;
  var givenLikesCount = 0;
  var givenCommentsCount = 0;
  bool loading=false;

  void getUserAndDetails() async {
    setState(() {
      loading=true;
    });

    DocumentSnapshot userSnap =
        await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
    
    var postSnap = await _firestore
        .collection('posts')
        .where('uid', isEqualTo: _auth.currentUser!.uid)
        .get();

    var totalLikes = await _firestore
        .collection('posts')
        .where('likes', arrayContains: _auth.currentUser!.uid)
        .get();

    var postQuerySnapp = await _firestore.collection('posts').get();
    int totalComments = 0;
    for (var postDoc in postQuerySnapp.docs) {
      var commentsSnap = await _firestore
          .collection('posts')
          .doc(postDoc.id) 
          .collection('comments')
          .where('uid', isEqualTo: _auth.currentUser!.uid)
          .get();
      totalComments += commentsSnap.docs.length;
    }

    

    setState(() {
      postCount = postSnap.docs.length;
      givenLikesCount = totalLikes.docs.length;
      givenCommentsCount = totalComments;

      nickname = userSnap['nickname'];
      profileImage = userSnap['profileImage'];
    });

    setState(() {
      loading=false;
    });
  }

  @override
  void initState() {
    getUserAndDetails();
    super.initState();
  }

  var activeScreen = "profile-screen";
  @override
  Widget build(BuildContext context) {

    stats(int num, String col) {
      return Column(children: [
        Text(col,
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(color: Colors.black)),
        Text(num.toString(),
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(color: Colors.black)),
      ]);
    }

    return loading 
    ? const Center(child: CircularProgressIndicator(),)
    :Scaffold(
      appBar: header(context, activeScreen),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(profileImage),
                radius: 70,
              ),
              const SizedBox(
                height: 12,
              ),
              Text('@$nickname',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(color: Colors.black)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  stats(postCount, 'posts'),
                  stats(givenLikesCount, 'likes'),
                  stats(givenCommentsCount, 'comments'),
                ],
              ),
               const Divider(thickness: 0.25,),
              FutureBuilder(
                future:FirebaseFirestore.instance
                       .collection('posts')
                       .where('uid', isEqualTo: _auth.currentUser!.uid)
                       .get(),
                builder:(context,snapshot){
                    if(snapshot.connectionState==ConnectionState.waiting){
                      return const Center(child: CircularProgressIndicator(),);
                    }

                     return GridView.builder(
                       shrinkWrap: true,
                       itemCount: (snapshot.data as dynamic).docs.length,
                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,crossAxisSpacing: 5), 
                       itemBuilder: (context,index){
                        DocumentSnapshot snap=(snapshot.data as dynamic).docs[index];
                        return SizedBox(
                          child: Image(
                            image: NetworkImage(snap['postImage']),
                            fit: BoxFit.cover,
                          ),
                        );
                       }
                     );

                }
              ),
            ],
          ),
        ),
      )  
    );
  }
}
