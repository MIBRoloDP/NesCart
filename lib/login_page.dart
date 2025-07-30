import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:neskart/home_page.dart';
import 'package:neskart/reset_password.dart';
import 'package:neskart/vendor/admin_dashboard.dart';
import 'signup.dart';
import 'bottom_nav.dart';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'dart:developer';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  List<BiometricType> _availableBiometrics = [];
  bool _canCheckBiometrics = false;
  final LocalAuthentication auth = LocalAuthentication();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController EmailController = TextEditingController();
  final TextEditingController PasswordController = TextEditingController();
  bool _Obscure = true;

  void _Validation(BuildContext context) {
    final email = EmailController.text.trim();
    final password = PasswordController.text.trim();

    if (email.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter the email");
      return;
    } else if (password.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter the password");
      return;
    } else {
      dev(context);
    }
  }

  Future<void> dev(BuildContext context) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: EmailController.text.trim(),
        password: PasswordController.text.trim(),
      );

      final User? user = userCredential.user;

      if (user != null) {
        log("User logged in: ${user.email}");

        final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();

        if (documentSnapshot.exists) {
          final data = documentSnapshot.data() as Map<String, dynamic>;

          log("Email from Firestore: ${data['email']}");

          final bool isAdmin = data['admin'] == true;
          final String isBlocked = data['status'] ?? 'Active';
             isBlocked=="Active"?
       Navigator.push(
         context,
         MaterialPageRoute(
           builder: (context) => isAdmin ? AdminDashboard() : bottomnav(),
         ),
       )
           :Fluttertoast.showToast(msg: "User blocked by admin, Contact IT Manager");
        } else {
          Fluttertoast.showToast(msg: "User document does not exist.");
          log("Document not found for user: ${user.uid}");
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Login failed: ${e.toString()}");
      log("Login error: $e");
    }
  }
  bool rememberMe = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 35,left: 90),
            child: Container(

                child: Image.asset("asset/dragon.png",
                height: 220,
                  width: 220,
                ),

            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 59,top: 137),
            child: Text(
              "NesCart",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.65,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Welcome Back!",
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
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              activeColor: Colors.black,
                              onChanged: (bool? value) async{
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                setState(() {

                                  rememberMe = value ?? false;
                                  prefs.setBool("remember_me", rememberMe);
                                  log(rememberMe.toString());
                                });
                              },
                            ),
                
                            Text(
                              "Remember me",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                
                        Padding(
                          padding: EdgeInsets.only(left: 99),
                          child: GestureDetector(
                            onTap: () {
                                log("");
                                Navigator.push(context, MaterialPageRoute(builder: (
                                    context) =>ResetPassword()));
                            },
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        onPressed: () {
                          _Validation(context);
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                
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
                      child:   ElevatedButton(
                          onPressed: _authenticateWithBiometrics, child: Icon(
                        Icons.fingerprint,
                      )
                      ),
                    ),
                
                    SizedBox(height: 50),
                    Row(
                      children: [
                        SizedBox(width: 80),
                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(
                              builder: (context) => SignupScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.orange,
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
    );
  }
  Future<void> _authenticateWithBiometrics() async {
    try {
      bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to login',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      if (didAuthenticate) {
        log("logged in");
      }
      if (didAuthenticate) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => homepage()),
        );
      } else {
        // Optional: Show error or retry
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication failed')),
        );
      }
    } on PlatformException catch (e) {
      if (e.code == 'LockedOut') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Too many failed attempts. Please try again in 30 seconds.",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        debugPrint(e.toString());
      }
    }
  }
  Future<void> _checkBiometrics() async {
    try {
      _canCheckBiometrics = await auth.canCheckBiometrics;
      _availableBiometrics = await auth.getAvailableBiometrics();
      log("Available Biometrics: $_availableBiometrics");
    } on PlatformException catch (e) {
      debugPrint("Biometric error: $e");
    }
    setState(() {});
  }
}

