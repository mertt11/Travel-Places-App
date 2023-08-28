import 'package:travel_places/screen/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_places/screen/selection_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firebase = FirebaseAuth.instance;
 final firestoreInstance=FirebaseFirestore.instance;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  var _enteredEmail = '';
  var _enteredPassword = '';
  var _showSignUpCard = false;

  void _toggleSignUpCard() {
    setState(() {
      _showSignUpCard = !_showSignUpCard;
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    //it also calls the variables in OnSaved function
    _formKey.currentState!.save();

    try {
       await _firebase.signInWithEmailAndPassword(email: _enteredEmail, password: _enteredPassword);   

      if(mounted){
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => const SelectionScreen()));
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed.'),
        ),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    Widget? card;
    //First it goes to else and open up the
    if (_showSignUpCard) {
      card = const SignUpScreen();
    } else {
      card = Card(
        margin: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Email Address'),
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
                      _enteredEmail = value!;
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
                    onSaved: (value) {
                      _enteredPassword = value!;
                    },
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                        ),
                        onPressed: _submit,
                        child: const Text('Submit'),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                        ),
                        onPressed: _toggleSignUpCard,
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 49, 151, 235),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    top: 20, bottom: 20, left: 20, right: 20),
                width: 250,
                child: Image.asset('assets/images/tra.png'),
              ),
              card
            ],
          ),
        ),
      ),
    );
  }
}