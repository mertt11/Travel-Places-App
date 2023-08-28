import 'package:flutter/material.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

class WidgetRole extends StatefulWidget {
  const WidgetRole({super.key,required this.child});
  final Widget child;

  @override
  State<WidgetRole> createState() => _WidgetRoleState();
}


class _WidgetRoleState extends State<WidgetRole> {
  String? role;

  @override
  void initState() {
    getUserRole();
    super.initState();
  }

  void getUserRole() async{
    DocumentSnapshot userSnapshot= await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
    setState(() {
      role=(userSnapshot.data() as Map<String,dynamic>)['role'];
    });
  }

  @override
  Widget build(BuildContext context) {
    if(role=='admin'){
      return widget.child;
    }
    return const Center(child:Text('You are not authorized to see this screen!',style: TextStyle(color: Colors.black),));
  }
}