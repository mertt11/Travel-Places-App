import 'package:firebase_storage/firebase_storage.dart';
import 'package:travel_places/model/user_model.dart';
import 'package:travel_places/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_places/screen/selection_screen.dart';
import 'package:travel_places/widget/user_image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseStorage _firebaseStorage=FirebaseStorage.instance;

class SignUpScreen extends StatefulWidget{
  const SignUpScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _SignUpScreenState();
  }
}

class _SignUpScreenState extends State<SignUpScreen>{
   final _signUpKey = GlobalKey<FormState>();

  var _enteredSignUpEmail = '';
  var _enteredSignUpNickname = '';
  final TextEditingController _passwordController = TextEditingController();
  var _isAuthenticating=false;
  File? _profileImg;


  void _signUp(BuildContext context) async {
     if (!_signUpKey.currentState!.validate()) {
       return;
     }
    _signUpKey.currentState!.save();

    final valid=await nicknameCheck(_enteredSignUpNickname);
    if(!valid){
          ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
            content: Text('Nickname is already taken. Please choose a different one.'),
           ),
          );
        return;
    }
   
    try {
      setState(() {
        _isAuthenticating=true;
      });

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
           email: _enteredSignUpEmail, password: _passwordController.text);
      
      Reference ref=_firebaseStorage.ref().child('profile_imgs').child(_auth.currentUser!.uid).child(const Uuid().v1());
      await ref.putFile(_profileImg!);
      var profileUrl=await ref.getDownloadURL();
     

      UserModel user = UserModel(
        email: _enteredSignUpEmail,
        nickname: _enteredSignUpNickname,
        uid: userCredential.user!.uid,
        profileImage: profileUrl,
        role:'user',
      );

      _firestore.collection('users').doc(userCredential.user!.uid).set(user.toMap());
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SelectionScreen()));

     } on FirebaseAuthException catch (error) {
       ScaffoldMessenger.of(context).clearSnackBars();
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text(error.message ?? 'Authentication failed.'),
         ),
       );
        setState(() {
          _isAuthenticating=false;
        });
     }
  }

  Future<bool> nicknameCheck(String nickname) async {
    final result = await _firestore
        .collection('users')
        .where('nickname', isEqualTo: nickname)
        .get();

    return result.docs.isEmpty;
  }

 @override
   Widget build(BuildContext context) {
     return Stack(
      children: [
        Card(
         margin: const EdgeInsets.all(20),
         child: SingleChildScrollView(
           child: Padding(
             padding: const EdgeInsets.all(16),
             child: Form(
               key: _signUpKey,
               child: Column(
                 children: [
                  //userImkage in içerisinde fonksiyon gibi birşey tanımladık.
                  //user_image_picker da widget.onProfileImg(_pickedImageFile!); diyerek
                  // oradan buraya pickedImage 'ı _profileImg a yolladık
                   UserImagePicker(onProfileImg: (pickedImage){
                       _profileImg=pickedImage;
                    }),
                   TextFormField(
                     decoration: const InputDecoration(labelText: 'Email Address'),
                     keyboardType: TextInputType.emailAddress,
                     autocorrect: false,
                     textCapitalization: TextCapitalization.none,
                     validator: (value) {
                       if (value == null ||
                           value.trim().isEmpty ||
                           !value.contains('@')) {
                         return 'Enter email address';
                     }
                       return null;
                     },
                     onSaved: (value) {
                       _enteredSignUpEmail = value!;
                     },
                   ),
                   TextFormField(
                     decoration: const InputDecoration(labelText: 'Nickname'),
                    keyboardType: TextInputType.text,
                     textCapitalization: TextCapitalization.none,
                    validator: (value) {
                       if (value == null ||
                           value.trim().isEmpty ||
                           value.trim().length < 4) {
                         return 'Enter a nickname min 4 char long.';
                       }

                       return null;
                     },
                     onSaved: (value) {     
                      _enteredSignUpNickname = value!;
                      // _enteredSignUpNicknameController.text=value;
                     },
                   ),
                   TextFormField(
                     decoration: const InputDecoration(labelText: 'Password'),
                     obscureText: true,
                     validator: (value) {
                       if (value == null || value.trim().length < 6) {
                         return 'Password must be atleast 6 characters long.';
                       }
                       return null;
                     },
                     controller: _passwordController,
                   ),
                   TextFormField(
                     decoration:
                         const InputDecoration(labelText: 'Password Again'),
                     obscureText: true,
                     validator: (value) {
                       if (value == null || value != _passwordController.text) {
                         return 'Passwords doesnt match';
                       }
                       return null;
                     },
                   ),
                   const SizedBox(
                     height: 16,
                   ),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if(_isAuthenticating)
                        const CircularProgressIndicator(),
                      if(!_isAuthenticating)
                        ElevatedButton(
                         style: ElevatedButton.styleFrom(
                           backgroundColor:
                               Theme.of(context).colorScheme.primaryContainer,
                         ),
                         onPressed: () {
                            Navigator.of(context).pushReplacement(
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    const LoginScreen(),
                              ),
                            );
                        },
                        child: const Text('Back'),
                       ),
                       const SizedBox(
                         width: 12,
                       ),
                       if(_isAuthenticating)
                        const CircularProgressIndicator(),
                       if(!_isAuthenticating)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          onPressed: (){
                            _signUp(context);  
                          },
                          child: const Text('Sign Up'),
                        ),
                     ],
                   )
                 ],
               ),
             ),
           ),
         ),
       ),
       ],
     );
  }
}
