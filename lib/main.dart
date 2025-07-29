
import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'bottom_nav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        drawerTheme: DrawerThemeData(
          backgroundColor: Colors.blue[800],
          scrimColor: Colors.transparent,

          surfaceTintColor: Colors.red,
        ),
      ),

      home: splashScreen(),
    );
  }
}