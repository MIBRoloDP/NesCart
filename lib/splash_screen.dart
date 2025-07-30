import 'dart:async';

import 'package:flutter/material.dart';
import 'package:neskart/login_page.dart';
import 'package:neskart/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';

class splashScreen extends StatefulWidget {
  const splashScreen({super.key});

  @override
  State<splashScreen> createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {
bool? remember_me;
bool? onboarding;
void checkAuth()async{
  SharedPreferences preferences = await SharedPreferences.getInstance();
  setState(() {
    remember_me= preferences.getBool("remember_me")??false;
    onboarding= preferences.getBool("onboarding_done")??false;
  });

}
  @override
  void initState() {
    super.initState();
    checkAuth();
    Timer(Duration(seconds: 3),() {
   if(onboarding== true){

     if(remember_me==false){
       Navigator.pushReplacement(context,
           MaterialPageRoute(builder: (context)=> LoginScreen()));
     }
     else
     {
       Navigator.pushReplacement(context,
           MaterialPageRoute(builder: (context)=> homepage()));
     }

   }else{
     Navigator.pushReplacement(context,
         MaterialPageRoute(builder: (context)=> OnboardingPage()));
   }

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