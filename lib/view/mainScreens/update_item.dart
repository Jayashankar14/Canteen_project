// ignore_for_file: library_private_types_in_public_api, prefer_final_fields, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateItemPage extends StatefulWidget {
  final String itemId;
  const UpdateItemPage({Key? key, required this.itemId}) : super(key: key);

  @override
  _UpdateItemPageState createState() => _UpdateItemPageState();
}

class _UpdateItemPageState extends State<UpdateItemPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  String _selectedCategory = '';
  List<String> _categories = [
    'Chocolates',
    'Snacks',
    'Starters',
    // Add more categories as needed
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _fetchItemDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _fetchItemDetails() async {
    // Fetch item details from Firestore based on widget.itemId
    // Update the controllers with fetched data
    try {
      DocumentSnapshot itemSnapshot = await FirebaseFirestore.instance.collection('items').doc(widget.itemId).get();
      Map<String, dynamic> itemData = itemSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _nameController.text = itemData['name'] ?? '';
        _descriptionController.text = itemData['description'] ?? '';
        _priceController.text = itemData['price']?.toString() ?? '';
        _selectedCategory = itemData['category'] ?? '';
      });
    } catch (error) {
      print('Error fetching item details: $error');
    }
  }

  Future<void> _updateItem() async {
    // Update item details in Firestore
    try {
      await FirebaseFirestore.instance.collection('items').doc(widget.itemId).update({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.tryParse(_priceController.text),
        'category': _selectedCategory,
        // Update other fields as needed
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Item updated successfully'),
      ));
    } catch (error) {
      print('Error updating item: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
              items: _categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateItem,
              child: const Text('Update Item'),
            ),
          ],
        ),
      ),
    );
  }
}
