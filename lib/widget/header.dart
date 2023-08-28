import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_places/screen/login_screen.dart';

AppBar header(BuildContext context, String activeScreen) {
  String titleText = "";
  TextStyle titleTextStyle;
  List<Widget> appBarActions = [];

  void signOut() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  Widget? leadingWidget;

  switch (activeScreen) {
    case "profile-screen":
      titleText = "Profile";
      titleTextStyle = Theme.of(context).textTheme.headlineMedium!;
      break;
    case "home-screen":
      titleText = "Travel Places";
      titleTextStyle = Theme.of(context).textTheme.headlineLarge!;
      leadingWidget = IconButton(
        onPressed: signOut,
        icon: const Icon(Icons.exit_to_app),
      );
      break;
    case "community-screen":
      titleText = "Community";
      titleTextStyle = Theme.of(context).textTheme.headlineMedium!;
      break;
    default:
      titleTextStyle = const TextStyle(); // Default style when none of the conditions are met
      break;
  }

  return AppBar(
    title: Text(titleText, style: titleTextStyle),
    centerTitle: true,
    toolbarHeight: 70,
    leading: leadingWidget,
    actions: appBarActions,
  );
}