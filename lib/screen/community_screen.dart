import 'package:flutter/material.dart';
import 'package:travel_places/widget/header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_places/model/user_model.dart';
import 'package:travel_places/screen/community_screen_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_places/widget/email_sender.dart';

 final _firestore=FirebaseFirestore.instance;
 final _auth = FirebaseAuth.instance;

 class CommunityScreen extends StatefulWidget {
   const CommunityScreen({Key? key}) : super(key: key);

   @override
   _CommunityScreenState createState() => _CommunityScreenState();
 }

class _CommunityScreenState extends State<CommunityScreen> {
  var activeScreen = "community-screen";


    Future<List<Map<String, dynamic>>> getUsers() async {
      try {
        QuerySnapshot querySnapshot = await _firestore.collection('users').get();
        return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      } catch (e) {
        print('Error fetching users: $e');
        return [];
      }
    }

  deleteCommentsAndPosts(String userId) async{

    try {
      QuerySnapshot postsSnapshot = await _firestore
        .collection('posts')
        .where('uid', isEqualTo: userId)
        .get();

      for (QueryDocumentSnapshot postDoc in postsSnapshot.docs) {
      String postId = postDoc.id;
      // Query comments associated with the current post
      QuerySnapshot commentsSnapshot = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .get();

      // Delete comments associated with the post
      for (QueryDocumentSnapshot commentDoc in commentsSnapshot.docs) {
        await commentDoc.reference.delete();
      }
      // Delete the post
      await postDoc.reference.delete();
    }

    }catch (e) {
      print(e.toString());
    }
  } 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, activeScreen),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            List<Map<String, dynamic>> usersList = snapshot.data!;
             int currentUserIndex = usersList.indexWhere((userData) => userData['uid'] == _auth.currentUser!.uid);
             if (currentUserIndex != -1) {
               Map<String, dynamic> currentUserData = usersList.removeAt(currentUserIndex);
               usersList.insert(0, currentUserData);
            }
            return ListView.builder(
              itemCount: usersList.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> userData = usersList[index];
                UserModel user = UserModel.fromMap(userData);
                if (userData['uid'] != _auth.currentUser!.uid) {
                  return Dismissible(
                    key: Key(userData['uid']),
                    onDismissed: (DismissDirection direction) {
                      setState(() {
                        usersList.removeAt(index); 
                        _firestore.collection('users').doc(userData['uid']).delete();
                        deleteCommentsAndPosts(userData['uid']);   
                        EmailSender(userData['nickname'],'admin', _auth.currentUser!.email!, userData['email']).sendEmail();
                      });
                    },
                    child: CommunityScreenItem(user),
                  );
                } else {
                  return CommunityScreenItem(user);
                }
              },
            );
          } else {
            return const Text('No data available.');
          }
        },
      ),
    );
  }
}
