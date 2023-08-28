import 'package:flutter/material.dart';
import 'package:travel_places/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';


 final _auth = FirebaseAuth.instance;

class CommunityScreenItem extends StatefulWidget {
  const CommunityScreenItem(this.user, {Key? key}) : super(key: key);
  final UserModel user;
  @override
  _CommunityScreenItemState createState() => _CommunityScreenItemState();
}

class _CommunityScreenItemState extends State<CommunityScreenItem> {
  bool _isOnline = false; 

  @override
  void initState(){
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    User? user = _auth.currentUser;
    setState(() {
      _isOnline = user != null && user.uid == widget.user.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: Icon(
                Icons.person,
                color: _isOnline 
                  ?  Colors.green
                  : Colors.red,
                size: 30,
              ),
            ),
            const SizedBox(width: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email:    ' + widget.user.email!,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(color: Colors.black)),
                Text('Nickname: ' + widget.user.nickname!,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(color: Colors.black)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
