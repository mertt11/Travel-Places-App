import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_places/screen/login_screen.dart';
import 'package:travel_places/screen/selection_screen.dart';
import 'package:travel_places/screen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

final theme = ThemeData().copyWith(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 49, 151, 235),
  ),
  textTheme: TextTheme(
    displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    bodyLarge: const TextStyle(fontSize: 18, color: Colors.black87),
    headlineLarge: GoogleFonts.pacifico(
      textStyle: const TextStyle(fontSize: 50, color: Colors.white),
    ),
    headlineMedium: const TextStyle(fontSize: 24, color: Colors.white),
  ),
  appBarTheme: const AppBarTheme(
    color: Color.fromARGB(255, 49, 151, 235),
    iconTheme: IconThemeData(color: Colors.white),
  ),

);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Places',
      theme: theme,
      home:StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
               return const SplashScreen();
            }  
            if (snapshot.hasData) {
              return const SelectionScreen();
            }
            return const LoginScreen();
          },
      )
    );
  }
}