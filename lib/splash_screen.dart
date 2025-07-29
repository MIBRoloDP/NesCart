import 'dart:async';

import 'package:flutter/material.dart';
import 'package:neskart/onboarding_screen.dart';

import 'home_page.dart';

class splashScreen extends StatefulWidget {
  const splashScreen({super.key});

  @override
  State<splashScreen> createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {


  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 7),() {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context)=> OnboardingPage()));
    });

  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [


          Center(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 100),
              child: Padding(
                padding: const EdgeInsets.all(50),
                child: Image.asset("asset/dragon.png"),
              ),
            ),


          ),

          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text('NesCart',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,

                color: Colors.black,
              ),),
          ) ,
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text('© 2025 All rights reserved.',
              style: TextStyle(
                color: Colors.black,
              ),),
          )


        ],
      ),
    );
  }
}