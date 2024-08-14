// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryPage extends StatelessWidget {
  final List<String> categories = [
    'Chocolates',
    'Biscuits',
    'Starters',
    'Snacks',
    'Soft Drinks',
    'Popular',
    'Special Items',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: DefaultTabController(
        length: categories.length,
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              indicatorPadding: EdgeInsets.zero,
              tabs: categories.map((category) => Tab(text: category)).toList(),
            ),
            Expanded(
              child: TabBarView(
                children: categories.map((category) {
                  return _buildCategoryItems(context, category);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItems(BuildContext context, String category) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('items')
          .where('category', isEqualTo: category)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No items found for $category'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var item = snapshot.data!.docs[index];
            var itemData = item.data() as Map<String, dynamic>;

            // Safely handle the case where 'isAvailable' might not exist
            bool isAvailable = itemData.containsKey('isAvailable')
                ? itemData['isAvailable']
                : true; // Default to true if field doesn't exist

            var price = itemData['price'] is int
                ? itemData['price']
                : int.tryParse(itemData['price']) ?? 0;

            print('Building item: ${itemData['heading']} with availability: $isAvailable');

            return ListTile(
              title: Text(itemData['heading']),
              subtitle: Text('₹$price'), // Display the price in Indian Rupees
              leading: itemData['image'] != null
                  ? Image.network(
                      itemData['image'], // Assuming 'image' field contains image URL
                      width: 80, // Adjust width as needed
                      height: 80, // Adjust height as needed
                      fit: BoxFit.cover, // Adjust the fit as needed
                    )
                  : const Placeholder(), // Placeholder if image is not available
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      isAvailable ? 'Available' : 'Not Available',
                      style: TextStyle(
                        color: isAvailable ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Switch(
                    value: isAvailable,
                    onChanged: (value) {
                      _toggleAvailability(item.id, value);
                    },
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                  ),
                ],
              ),
              // Add more item details as needed
            );
          },
        );
      },
    );
  }

  void _toggleAvailability(String itemId, bool isAvailable) {
    FirebaseFirestore.instance
        .collection('items')
        .doc(itemId)
        .update({'isAvailable': isAvailable})
        .then((_) {
      print('Item availability updated successfully');
    }).catchError((error) {
      print('Failed to update item availability: $error');
    });
  }
}
