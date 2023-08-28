import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:travel_places/screen/selection_screen.dart';
import 'package:travel_places/widget/image_input.dart';
import 'package:travel_places/model/place.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseStorage _storage = FirebaseStorage.instance;

class AddPlaceScreen extends StatefulWidget{
  const AddPlaceScreen({super.key});

  @override
  State<AddPlaceScreen> createState() {
    return _AddPlaceScreenState();
  }
}

class _AddPlaceScreenState extends State<AddPlaceScreen>{
  //this is not a form, so we directly use titleController here.
  final _titleController=TextEditingController();
  final _descrioptionController=TextEditingController();
  File? _selectedImage;
  var _isUploading=false;
  String nickname='';
  String profileImage='';

  @override
  void dispose() {
    _descrioptionController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _savePlace() async{
    if( _titleController.text.isEmpty||_selectedImage==null||_descrioptionController.text.isEmpty){
      return;
    }
    setState(() {
      _isUploading=true;
    });
    
    try{
      Reference ref=_storage.ref().child('users_posts').child(_auth.currentUser!.uid).child(const Uuid().v1());
      await ref.putFile(_selectedImage!);
      final postImgUrl=await ref.getDownloadURL();

    Place post=Place(
       nickname: nickname,
       uid: _auth.currentUser!.uid,
       title: _titleController.text,
       text:_descrioptionController.text,
       postImage: postImgUrl, 
       profileImage: profileImage,
       likes: [],
       datePublished: DateTime.now(),
       postId: const Uuid().v4(),
    );
    
    await _firestore.collection('posts').doc(post.postId).set(post.toMap());
    if(mounted){
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => const SelectionScreen()));
    }
    }catch(errr){
      ScaffoldMessenger.of(context).clearSnackBars();
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text(errr.toString() ?? 'Adding place failed.'),
         ),
       );
    }
  }

  void getNickNameAndProfileUrl() async{
    DocumentSnapshot userSnapshot= await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
    setState(() {
      nickname=(userSnapshot.data() as Map<String,dynamic>)['nickname'];
      profileImage=(userSnapshot.data() as Map<String,dynamic>)['profileImage'];
    });
  }

  @override
  void initState() {
    getNickNameAndProfileUrl();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 16,),
          Text(nickname,style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onBackground),),
          const SizedBox(height: 16,),
          TextField(decoration: const InputDecoration(labelText:'Title'),
          controller: _titleController,),
          const SizedBox(height: 16,),
          ImageInput(onPickImage: (img){
            _selectedImage=img;
            },
          ),
          const SizedBox(height: 16,),
          TextField(decoration: const InputDecoration(labelText: 'Description'),
          controller:_descrioptionController,),
          const SizedBox(height: 16,),
          _isUploading
                  ? const CircularProgressIndicator() 
                  : ElevatedButton.icon(
                      onPressed: _savePlace,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Place'),
                    ),
        ],
        ),
      ),
    )
    );
  }
}