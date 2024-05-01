// ignore_for_file: prefer_const_constructors, sort_child_properties_last, unnecessary_nullable_for_final_variable_declarations, prefer_interpolation_to_compose_strings, prefer_final_fields, use_super_parameters

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sellers/screens/details_screen.dart';
import 'package:sellers/screens/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  File? selectedImage;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    'Create an Account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    children: [
                      selectedImage != null
                          ? CircleAvatar(
                              radius: 50,
                              backgroundImage: FileImage(selectedImage!),
                            )
                          : CircleAvatar(
                              radius: 50,
                              backgroundImage: const NetworkImage(
                                  'https://t4.ftcdn.net/jpg/02/15/84/43/360_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg'),
                            ),
                      Positioned(
                        bottom: -0,
                        left: 140,
                        child: IconButton(
                          onPressed: () {
                            showImagePickerOption(context);
                          },
                          icon: const Icon(Icons.add_a_photo),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () {
                      showImagePickerOption(context);
                    },
                    child: const Text('Change Profile pic'),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone No',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: 350,
                  child: ElevatedButton(
                    onPressed: () async {
                      await signUp();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DetailsScreen()),
                      );
                    },
                    child: Text(
                      'Sign Up',
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
                const SizedBox(height: 10),
                //GOOGLE LOG IN
                SizedBox(
                  height: 50,
                  width: 350,
                  child: ElevatedButton(
                    onPressed: () {
                      // Action when the button is pressed
                    },
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.black),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.grey.shade200),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Image(
                          image: AssetImage('assets/google.png'),
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
                const SizedBox(height: 20),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      child: const Text('Sign In'),
                    ),
                    const SizedBox(width: 20),
                    TextButton(
                      onPressed: () {
                        // Add logic for forgot password
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signUp() async {
    try {
      // Create user with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Upload profile picture to Firebase Storage
      String? imageUrl;
      if (selectedImage != null) {
        imageUrl = await uploadProfilePicture(userCredential.user!.uid);
      }

      // Store user data in Cloud Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'fullName': _fullNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'profilePicture': imageUrl,
      });

      // Show success message
      // displayToastMessage('Account created successfully', context);

      // Redirect to HomeScreen
    } catch (e) {
      // Show error message
      // displayToastMessage('Error: $e', context);
    }
  }

  Future<String?> uploadProfilePicture(String userId) async {
    try {
      final Reference ref =
          _storage.ref().child('profile_pictures').child('$userId.jpg');
      await ref.putFile(selectedImage!);
      return await ref.getDownloadURL();
    } catch (e) {
      // Handle upload error
      // displayToastMessage('Error uploading profile picture: $e', context);
      return null;
    }
  }

  displayToastMessage(String message, BuildContext context) {
    Fluttertoast.showToast(
      msg: message,
    );
  }

  void showImagePickerOption(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Padding(
          padding: const EdgeInsets.all(18.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 5,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _pickImage(ImageSource.gallery);
                      Navigator.pop(context);
                    },
                    child: SizedBox(
                      child: Column(
                        children: const [
                          Icon(
                            Icons.image,
                            size: 70,
                          ),
                          Text("Gallery"),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _pickImage(ImageSource.camera);
                      Navigator.pop(context);
                    },
                    child: SizedBox(
                      child: Column(
                        children: const [
                          Icon(
                            Icons.camera_alt,
                            size: 70,
                          ),
                          Text("Camera"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? returnImage = await _picker.pickImage(source: source);
    if (returnImage == null) return;
    setState(() {
      selectedImage = File(returnImage.path);
    });
  }
}
