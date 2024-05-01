// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sellers/widgets/bottom_navbar.dart';
import 'package:sellers/widgets/custom_button.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({Key? key}) : super(key: key);

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  String? _selectedCategory;
  File? selectedImage;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _smallVehiclePriceController = TextEditingController();
  TextEditingController _mediumVehiclePriceController = TextEditingController();
  TextEditingController _largeVehiclePriceController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

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

  Future<String> _uploadImage(File imageFile) async {
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('servicesimages/${DateTime.now().millisecondsSinceEpoch}');
    await ref.putFile(imageFile);
    String downloadURL = await ref.getDownloadURL();
    return downloadURL;
  }

  Future<void> _addToDatabase(String imageUrl) async {
    // Prepare data to store in Firebase Storage
    Map<String, dynamic> data = {
      'name': _nameController.text,
      'package': _selectedCategory,
      'small_vehicle_price': _smallVehiclePriceController.text,
      'medium_vehicle_price': _mediumVehiclePriceController.text,
      'large_vehicle_price': _largeVehiclePriceController.text,
      'description': _descriptionController.text,
      'image_url': imageUrl,
    };

    // Convert data to JSON string
    String jsonData = jsonEncode(data);

    // Create a Uint8List from the JSON string
    Uint8List bytes = Uint8List.fromList(utf8.encode(jsonData));

    // Upload data file to Firebase Storage
    firebase_storage.Reference dataRef = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('services/${DateTime.now().millisecondsSinceEpoch}.json');

    await dataRef.putData(bytes);

    // Get download URL of the uploaded data file
    String dataDownloadURL = await dataRef.getDownloadURL();

    // Store data in Firestore
    await FirebaseFirestore.instance.collection('services').add({
      'name': _nameController.text,
      'package': _selectedCategory,
      'small_vehicle_price': _smallVehiclePriceController.text,
      'medium_vehicle_price': _mediumVehiclePriceController.text,
      'large_vehicle_price': _largeVehiclePriceController.text,
      'description': _descriptionController.text,
      'image_url': imageUrl,
      'data_url': dataDownloadURL, // Store the download URL of the data file
      'timestamp': DateTime.now(),
    });

    // Now, both the image and data are stored in Firebase Storage and Cloud Firestore
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Product',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 230,
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  showImagePickerOption(context);
                },
                child: Stack(
                  children: [
                    selectedImage != null
                        ? Image.file(
                            selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : Image.network(
                            'https://images.unsplash.com/photo-1618641986557-1ecd230959aa?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                  ],
                ),
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
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name ',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10.0),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Package',
                border: OutlineInputBorder(),
              ),
              value: _selectedCategory,
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              items: [
                'Select Category',
                'Express',
                'Deluxe',
                'Ultimate',
                'Other'
              ].map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
            SizedBox(height: 10.0),
            TextFormField(
              controller: _smallVehiclePriceController,
              decoration: InputDecoration(
                labelText: "Small Vehicle Price",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10.0),
            TextFormField(
              controller: _mediumVehiclePriceController,
              decoration: InputDecoration(
                labelText: "Medium Vehicle Price",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10.0),
            TextFormField(
              controller: _largeVehiclePriceController,
              decoration: InputDecoration(
                labelText: "Large Vehicle Price",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10.0),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: "Add",
                onPressed: () async {
                  if (_selectedCategory == null ||
                      _nameController.text.isEmpty ||
                      _smallVehiclePriceController.text.isEmpty ||
                      _mediumVehiclePriceController.text.isEmpty ||
                      _largeVehiclePriceController.text.isEmpty ||
                      _descriptionController.text.isEmpty ||
                      selectedImage == null) {
                    Fluttertoast.showToast(
                      msg: "Please fill all fields and select an image",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                    return;
                  }
                  try {
                    // Show circular progress indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );
                    String imageUrl = await _uploadImage(selectedImage!);
                    await _addToDatabase(imageUrl);
                    Fluttertoast.showToast(
                      msg: "Product added successfully",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BottomNavBar(),
                      ),
                    );
                  } catch (error) {
                    print("Error adding product: $error");
                    Fluttertoast.showToast(
                      msg: "Failed to add product",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
