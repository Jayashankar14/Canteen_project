// ignore_for_file: unused_import

import 'dart:convert';

// ignore: depend_on_referenced_packages
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sellers_app/view/mainScreens/category_page.dart';
import 'package:sellers_app/view/mainScreens/delte_item.dart';
import 'package:sellers_app/view/mainScreens/orderlistadmin.dart';
import 'package:sellers_app/view/mainScreens/update_item.dart';
import 'package:sellers_app/view/mainScreens/upload.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Change background color as needed
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: Image.asset(
                    'images/admin.jpeg', // Add your image path
                    width: 300, // Adjust image width as needed
                    height: 500, // Adjust image height as needed
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // SizedBox(height: 40),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => UpdateItemPage(
              //                 itemId: '',
              //               )),
              //     );
              //   },
              // child: const Padding(
              //   padding: EdgeInsets.symmetric(vertical: 16.0),
              //   child: Text(
              //     'Update Items',
              //     style: TextStyle(fontSize: 18), // Adjust button text size
              //   ),
              // ),
              // ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to upload item page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UploadPage()),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Upload New Item',
                    style: TextStyle(fontSize: 18), // Adjust button text size
                  ),
                ),
              ),
              // SizedBox(height: 20),r
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DeleteProductsPage()),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Delete Products',
                    style: TextStyle(fontSize: 18), // Adjust button text size
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OrdersListPage()),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Orders List',
                    style: TextStyle(fontSize: 18), // Adjust button text size
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CategoryPage()),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Category',
                    style: TextStyle(fontSize: 18), // Adjust button text size
                  ),
                ),
              ),

              // Add padding at the bottom
            ],
          ),
        ),
      ),
    );
  }
}

// class OrdersListPage extends StatelessWidget {
//   const OrdersListPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Orders List')),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance.collection('orders').snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final List<DocumentSnapshot> documents = snapshot.data!.docs;

//           if (documents.isEmpty) {
//             return const Center(child: Text('No orders found.'));
//           }

//           return ListView.builder(
//             itemCount: documents.length,
//             itemBuilder: (context, index) {
//               final orderData = documents[index].data() as Map<String, dynamic>;
//               final userDetails =
//                   orderData['userDetails'] as Map<String, dynamic>;
//               final orderDetails = orderData['orderDetails'] as List<dynamic>;

//               return Card(
//                 margin: const EdgeInsets.all(10.0),
//                 child: Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Order ID: ${documents[index].id}',
//                           style: const TextStyle(fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 10),
//                       Text('Name: ${userDetails['name']}'),
//                       Text('Phone: ${userDetails['phone']}'),
//                       Text('Department: ${userDetails['department']}'),
//                       Text('Year: ${userDetails['year']}'),
//                       const SizedBox(height: 10),
//                       const Text('Ordered Items:',
//                           style: TextStyle(fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 5),
//                       ...orderDetails.map((item) {
//                         return Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Item Name: ${item['itemName']}'),
//                             Text('Item Price: ₹${item['itemPrice']}'),
//                             Text('Quantity: ${item['count']}'),
//                             const Divider(),
//                           ],
//                         );
//                       }).toList(),
//                       Text('Total Amount: ₹${userDetails['totalAmount']}',
//                           style: const TextStyle(fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 10),
//                       ElevatedButton(
//                         onPressed: () {
//                           _sendNotification(userDetails['userId']);
//                         },
//                         child: const Text('Mark as Ready'),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Future<void> _sendNotification(String userId) async {
//     final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//     final token = await _getUserToken(userId);

//     if (token != null) {
//       final response = await http.post(
//         Uri.parse('https://fcm.googleapis.com/fcm/send'),
//         headers: <String, String>{
//           'Content-Type': 'application/json',
//           'Authorization': 'key=YOUR_SERVER_KEY',
//         },
//         body: jsonEncode(
//           <String, dynamic>{
//             'notification': <String, dynamic>{
//               'body': 'Your order is ready!',
//               'title': 'Order Update',
//             },
//             'priority': 'high',
//             'data': <String, dynamic>{
//               'click_action': 'FLUTTER_NOTIFICATION_CLICK',
//               'id': '1',
//               'status': 'done',
//             },
//             'to': token,
//           },
//         ),
//       );

//       if (response.statusCode == 200) {
//         print('Notification sent successfully');
//       } else {
//         print('Failed to send notification');
//       }
//     }
//   }

//   Future<String?> _getUserToken(String userId) async {
//     final userDoc =
//         await FirebaseFirestore.instance.collection('users').doc(userId).get();
//     return userDoc['fcmToken'];
//   }
// }