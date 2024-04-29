// ignore_for_file: prefer_const_constructors, unnecessary_new, sort_child_properties_last, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:sellers/screens/signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: Image.asset("assets/dazzles.png"),
          ),
          Text(
            "DAZZLES",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                //Password
                SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          // Email

          SizedBox(height: 20),

          //log in button
          SizedBox(
            width: 350,
            child: ElevatedButton(
              onPressed: () {},
              child: Text(
                'Log in',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // <-- Radius
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          //GOOGLE LOG IN
          SizedBox(
            height: 50,
            width: 350,
            child: ElevatedButton(
              onPressed: () {
                // Action when the button is pressed
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.grey.shade200),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/google.png',
                    height: 24,
                    width: 24,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Sign In with Google",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          //forgot Password
          TextButton(
            onPressed: null,
            child:
                Text('forgot password', style: TextStyle(color: Colors.blue)),
          ),
          // SIGN UP
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account?"),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignupScreen(),
                    ),
                  );
                },
                child: Text('Sign up', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
