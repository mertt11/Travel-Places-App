import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_places/screen/post/comment_card.dart';
import 'package:uuid/uuid.dart';

final _auth = FirebaseAuth.instance;
final _firestore=FirebaseFirestore.instance;

class CommentScreen extends StatefulWidget {
  const CommentScreen({super.key,required this.postId});
  final String postId;
  
  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final _msgController=TextEditingController();
  String nickname='';
  String profileImage='';
  String uid='';
  String commentText='';

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  void _submitMsg() async{
    commentText=_msgController.text;
    
    if(commentText.trim().isEmpty){
      return;
    }
    
    _msgController.clear();
    // Focus.of(context).unfocus();

    try{
      String commentId=const Uuid().v1();
      await _firestore.collection('posts').doc(widget.postId).collection('comments').doc(commentId).set({
        'postId':widget.postId,
        'profileImage':profileImage,
        'nickname':nickname,
        'text':commentText,
        'uid':uid,
        'commentId':commentId,
        'datePublished':DateTime.now(),
      });
    }catch(e){
      print(e.toString());
    }
  }

  get() async{
    DocumentSnapshot documentSnapshot = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
    setState(() {
      nickname=(documentSnapshot.data() as Map<String,dynamic>)['nickname'];
      profileImage=(documentSnapshot.data() as Map<String,dynamic>)['profileImage'];
      uid=(documentSnapshot.data() as Map<String,dynamic>)['uid'];
    });
  }

  @override
  void initState() {
    get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Comments',style:Theme.of(context).textTheme.headlineMedium!),
        leading: IconButton(onPressed: (){Navigator.of(context).pop();},icon: const Icon(Icons.arrow_back)),
      ),
      body: Column(
        children: [
        Expanded(
          child: StreamBuilder(
            stream: _firestore.collection('posts').doc(widget.postId).collection('comments').orderBy('datePublished',descending: false).snapshots(),
            builder: (context,AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>> snapshot) {
              if(snapshot.connectionState==ConnectionState.waiting){
                return const Center(child:CircularProgressIndicator());
              }
              return ListView.builder(
                itemCount:snapshot.data!.docs.length,
                itemBuilder: (context,index){
                  return CommentCard(snap:snapshot.data!.docs[index],);
                }
              );
            },
          ),
        ),
          Padding(
              padding: const EdgeInsets.only(left: 15,right: 1,bottom: 14,top: 15),
                child: Row(
                  children:[
                    CircleAvatar( backgroundImage: NetworkImage(profileImage),radius: 18,),
                    const SizedBox(width: 12,),
                    Expanded(
                      child:TextField(
                        controller: _msgController,
                        textCapitalization: TextCapitalization.sentences,
                        autocorrect: true,
                        enableSuggestions: true,
                        decoration: InputDecoration(hintText: nickname),
                      )
                    ),
                    IconButton(onPressed: ()async{_submitMsg();}, icon: const Icon(Icons.send),color: Theme.of(context).colorScheme.primary,),
                  ],
                ),
          ),
        ],
      ), 
    );
  }
}