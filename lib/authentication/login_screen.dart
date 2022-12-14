// ignore_for_file: camel_case_types

import 'package:driver_app/authentication/signup_screen.dart';
import 'package:driver_app/global/global.dart';
import 'package:driver_app/splashScreen/splash_screen.dart';
import 'package:driver_app/widgets/progress_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class loginScreen extends StatefulWidget {
  const loginScreen({Key? key}) : super(key: key);

  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  validateForm(){

    if (!emailTextEditingController.text.contains("@")){
      Fluttertoast.showToast(msg: "Invalid Email");
    }
    else if (passwordTextEditingController.text.isNotEmpty){
      Fluttertoast.showToast(msg: "Password is required");
    }
    else {
      loginDriverNow();
    }
  }

  loginDriverNow() async
  {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return ProgressDialog(message: "Processing, Please wait",);
        });

    //create new user
    final User? firebaseUser = (
        await firebaseAuth.signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          //trim() removes the extra spaces in emails of password.
          password: passwordTextEditingController.text.trim(),
        ).catchError((msg) {
          Navigator.pop(context);
          Fluttertoast.showToast(msg: "Error: " + msg.toString());
        })
    ).user;
    if (firebaseUser != null) {
      DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("drivers");
      driversRef.child(firebaseUser.uid).once().then((driverKey) {
        final snap = driverKey.snapshot;
        if (snap.value != null){
          currentFirebaseUser = firebaseUser;
          Fluttertoast.showToast(msg: "Login Successful");
          Navigator.push(context, MaterialPageRoute(builder: (c) => MySplashScreen()));
        }
        else{
          Fluttertoast.showToast(msg: "No record exist with this email");
          firebaseAuth.signOut();
          Navigator.push(context, MaterialPageRoute(builder: (c) => MySplashScreen()));
      }});

    }
    else {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error occurred while logging in");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff9ef5cf),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [

              const SizedBox(
                height: 30,
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset('images/logo1.png'),
              ),

              const SizedBox(
                height: 10,
              ),

              const Text(
                'Login as a Tank Driver',
                style: TextStyle(
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),

              TextField(
                controller: emailTextEditingController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                  color: Colors.grey,
                ),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'xyz@gmail.com',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10.0,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                  ),
                ),
              ),

              TextField(
                controller: passwordTextEditingController,
                keyboardType: TextInputType.text,
                obscureText: true,
                style: const TextStyle(
                  color: Colors.grey,
                ),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: '**********',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10.0,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              ElevatedButton(
                onPressed: () {
                  validateForm();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.lightGreenAccent,
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                  ),
                ),
              ),

              TextButton(
                  child: const Text(
                    "Dont have an Account? Sign Up.",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (c) => SignUpScreen()),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
