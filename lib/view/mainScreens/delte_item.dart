import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteProductsPage extends StatelessWidget {
  const DeleteProductsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Products'),
        backgroundColor: Colors.blue, // Change background color
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('items').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<DocumentSnapshot> documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final itemData = documents[index].data() as Map<String, dynamic>;
              final imageUrl = itemData['image']; // Retrieve image URL
              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 4.0,
                child: ListTile(
                  leading: imageUrl != null
                      ? Image.network(imageUrl)
                      : null, // Display image if available
                  title: Text(
                    itemData['heading'],
                    style: const TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Price: ${itemData['price']}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // Implement delete functionality
                      _deleteProduct(documents[index].id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _deleteProduct(String productId) {
    FirebaseFirestore.instance.collection('items').doc(productId).delete();
  }
}
