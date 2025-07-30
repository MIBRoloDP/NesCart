
import 'package:flutter/material.dart';
import 'package:khalti_flutter/khalti_flutter.dart';
import 'splash_screen.dart';
import 'bottom_nav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return KhaltiScope(
      publicKey: 'test_public_key_5c5fa086bb704a54b1efd924a2acb036',
      builder: (context, e) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: splashScreen(
          ),
          navigatorKey: e,
          supportedLocales: const[
            Locale('en', 'US'),
            Locale('ne', 'NP'),

          ],
          localizationsDelegates: const[
            KhaltiLocalizations.delegate
          ],
        );
      },
    );
  }
}