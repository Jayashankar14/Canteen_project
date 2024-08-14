// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, sized_box_for_whitespace, avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sellers_app/view/mainScreens/my_drawer.dart';

class UploaditemApp extends StatelessWidget {
  const UploaditemApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'New Item',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const UploadPage(),
    );
  }
}

class UploadPage extends StatefulWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final TextEditingController _headingController = TextEditingController();
  final TextEditingController _newsController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _selectedImage;
  String? _selectedCategory;
  final picker = ImagePicker();
  final List<String> _categories = [
    'Chocolates',
    'Biscuits',
    'Starters',
    'Snacks',
    'Soft Drinks',
    'Popular',
    'Special Items'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey, Colors.blueGrey],
            ),
          ),
          child: const Align(
            alignment: Alignment.center,
            child: Text(
              'Upload Item',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      drawer: const MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildSelectImageButton(),
              const SizedBox(height: 5.0),
              if (_selectedImage != null) _buildSelectedImage(),
              const SizedBox(height: 20.0),
              _buildHeadingTextField(),
              const SizedBox(height: 20.0),
              _buildPriceTextField(),
              const SizedBox(height: 20.0),
              _buildCategoryDropdown(),
              const SizedBox(height: 20.0),
              _buildNewsTextField(),
              const SizedBox(height: 20.0),
              _buildPublishButton(),
              const SizedBox(
                  height: 20.0), // Add additional spacing at the bottom
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectImageButton() {
    return ElevatedButton(
      onPressed: _selectImage,
      child: const Text('Select Image'),
    );
  }

  Widget _buildSelectedImage() {
    return Container(
      height: 200, // Adjust the height as needed
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.file(_selectedImage!),
      ),
    );
  }

  Widget _buildHeadingTextField() {
    return TextField(
      controller: _headingController,
      decoration: const InputDecoration(
        hintText: 'Product Name',
        border: OutlineInputBorder(), // Adjust the height as needed
      ),
    );
  }

  Widget _buildPriceTextField() {
    return TextField(
      controller: _priceController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        hintText: 'Price',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey, // Adjust border color as needed
          width: 1.0, // Adjust border width as needed
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        hint: const Text('Select Category'),
        onChanged: (newValue) {
          setState(() {
            _selectedCategory = newValue;
          });
        },
        items: _categories.map((category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNewsTextField() {
    return TextField(
      controller: _newsController,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      decoration: const InputDecoration(
        hintText: 'Write your description',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildPublishButton() {
    return ElevatedButton(
      onPressed: _publishNews,
      child: const Text('Upload'),
    );
  }

  Future<void> _selectImage() async {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  void _publishNews() async {
    String heading = _headingController.text;
    int price = int.tryParse(_priceController.text) ?? 0;
    String category = _selectedCategory ?? ''; // Ensure category is not null
    String news = _newsController.text;

    // Upload the selected image to Firebase Storage
    String imageUrl = '';
    if (_selectedImage != null) {
      try {
        firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('images')
            .child(
                '$_selectedCategory/${DateTime.now().millisecondsSinceEpoch}');
        await ref.putFile(_selectedImage!);
        imageUrl = await ref.getDownloadURL();
      } catch (e) {
        print('Error uploading image: $e');
      }
    }

    try {
      // Upload item data to Firestore
      await FirebaseFirestore.instance.collection('items').add({
        'heading': heading,
        'price': price,
        'category': category,
        'news': news,
        'image': imageUrl, // Store the download URL of the image
      });

      // Clear all text fields and selected image
      _headingController.clear();
      _priceController.clear();
      _selectedCategory = null;
      _newsController.clear();
      setState(() {
        _selectedImage = null;
      });

      // Show a success message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item uploaded successfully')),
      );
    } catch (e) {
      // Show an error message if uploading fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload item: $e')),
      );
    }
  }

  @override
  void dispose() {
    _headingController.dispose();
    _newsController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
