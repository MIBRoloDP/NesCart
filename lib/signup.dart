import 'dart:ffi';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:neskart/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController EmailController = TextEditingController();
  TextEditingController PasswordController = TextEditingController();
  TextEditingController NameController = TextEditingController();
  TextEditingController ConfirmPasswordController = TextEditingController();

  bool _obscureP = true;
  bool _obscureCP = true;

  Future<void> registerUser(String email,String password, String name) async {
    try {

      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set(
            {
              'uid': user.uid,
              'email': user.email,
              'name': name,
              'role': user,

            });

        Fluttertoast.showToast(msg: "User registered and added to Firestore");
      }
    } catch (e, stacktrace) {
      print("Registration Error: $e");
      print("StackTrace: $stacktrace");
    }
  }

  void _Validationb(){
    if (PasswordController.text!=ConfirmPasswordController.text)
    {
      Fluttertoast.showToast(msg: "Passwords are not same ");

    }
    else if (EmailController.text.isEmpty)
    {
      Fluttertoast.showToast(msg: "Please Enter your Email");
    }
    else if (NameController.text.isEmpty)
    {
      Fluttertoast.showToast(msg: "Please Enter your Full Name ");

    }
    else if (PasswordController.text.isEmpty)
    {
      Fluttertoast.showToast(msg: "Please enter the password ");

    }
    else if (ConfirmPasswordController.text.isEmpty)
    {
      Fluttertoast.showToast(msg: "Please enter the password ");

    }
    else
    {
      registerUser(EmailController.text,PasswordController.text,NameController.text);
      Fluttertoast.showToast(msg: "Welcome");
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [

            Padding(
              padding: const EdgeInsets.only(top: 20,left: 190),
              child: Container(

                child: Image.asset("asset/dragon.png",
                  height: 100,
                  width: 100,
                ),

              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 120,top: 55),
              child: Text(
                "NesCart",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.80,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Create your account!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),

                      Padding(
                        padding: EdgeInsets.only(left: 20, top: 10),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Full Name",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      TextFormField(
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        controller: NameController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person, color: Colors.white),
                          hintText: 'Full Name',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(left: 20, top: 10),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Email",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      TextFormField(
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        controller: EmailController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.mail, color: Colors.white),
                          hintText: 'Email',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(left: 20, top: 10),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Password",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      TextFormField(
                        controller: PasswordController,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.key, color: Colors.white),
                          hintText: 'Password',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20, top: 10),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Confirm Password",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: ConfirmPasswordController,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.key, color: Colors.white),
                          hintText: 'Confirm Password',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),

                      // CustButton(text: 'Signup', onPressed: (){}, backgroundColor: Colors.white, textColor: Colors.black,
                      // ),
                      // SizedBox(height: 8),
                      //
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                          onPressed: () {
                            _Validationb();
                          },
                          child: Text(
                            "Signup",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: Divider(indent: 20, endIndent: 20)),
                          Text(
                            "Or",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Expanded(child: Divider(indent: 20, endIndent: 20)),
                        ],
                      ),
                      SizedBox(height: 20),

                      Center(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          label: Text(
                            "Sign Up with Google",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 24,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 50),
                      Row(
                        children: [
                          SizedBox(width: 80),
                          Text(
                            "Already have an account?",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> LoginScreen()));},
                            child: Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
