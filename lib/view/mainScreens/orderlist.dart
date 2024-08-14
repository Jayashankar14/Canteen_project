import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewOrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Orders'),
      ),
      body: FutureBuilder(
        future: _fetchOrders(),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No orders found.'));
          } else {
            final orders = snapshot.data!;
            final currencyFormat = NumberFormat.currency(symbol: '₹');

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final userDetails =
                    order['userDetails'] as Map<String, dynamic>;
                final orderDetails = order['orderDetails'] as List<dynamic>;
                final totalAmount = order['totalAmount'];
                final status = order['status'] ?? 'pending';

                // Format totalAmount based on its type
                String formattedTotalAmount;
                if (totalAmount is num) {
                  // Ensure totalAmount is a numeric type
                  formattedTotalAmount =
                      currencyFormat.format(totalAmount.toDouble());
                } else {
                  formattedTotalAmount =
                      '₹0.00'; // Default value if totalAmount is not numeric
                }

                return Card(
                  margin: EdgeInsets.all(10),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order ID: ${order['orderId']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        ...orderDetails.map((item) {
                          return ListTile(
                            title: Text(item['itemName']),
                            subtitle: Text('Quantity: ${item['count']}'),
                          );
                        }).toList(),
                        Divider(),
                        Text(
                          'Total Amount: ₹${userDetails['totalAmount']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Status: $status',
                          style: TextStyle(
                            color: status == 'ready'
                                ? Colors.green
                                : status == 'preparing'
                                    ? Colors.orange
                                    : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }


Future<void> markOrderAsDelivered(String orderId) async {
  try {
    // Get the order document from the 'orders' collection
    final orderDoc = await FirebaseFirestore.instance.collection('orders').doc(orderId).get();

    if (orderDoc.exists) {
      final orderData = orderDoc.data() as Map<String, dynamic>;

      // Update the order status to 'delivered'
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': 'delivered',
      });

      // Move the order to 'historyOrders'
      await FirebaseFirestore.instance.collection('historyOrders').doc(orderId).set(orderData);

      // Optionally, delete the order from 'orders' collection if no longer needed
      await FirebaseFirestore.instance.collection('orders').doc(orderId).delete();
    } else {
      print('Order not found');
    }
  } catch (e) {
    print('Error marking order as delivered: $e');
  }
}


  Future<void> _moveOrderToHistory(String orderId) async {
    try {
      final orderDoc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .get();
      if (orderDoc.exists) {
        final orderData = orderDoc.data() as Map<String, dynamic>?;

        if (orderData != null) {
          await FirebaseFirestore.instance
              .collection('historyOrders')
              .doc(orderId)
              .set(orderData);
          await FirebaseFirestore.instance
              .collection('orders')
              .doc(orderId)
              .delete();
        } else {
          print('Order data is null');
        }
      } else {
        print('Order not found');
      }
    } catch (e) {
      print('Error moving order to history: $e');
    }
  }
  
  // Example function to update order status
Future<void> updateOrderStatus(String orderId, String status) async {
  await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
    'status': status, // e.g., 'delivered', 'declined'
  });
}


  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw 'User not logged in';
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['orderId'] = doc.id; // Add the document ID to the data
      return data;
    }).toList();
  }
}

class HistoryOrdersPage extends StatelessWidget {
  const HistoryOrdersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('historyOrders') // Collection for historical orders
            .where('status', whereIn: ['delivered', 'declined']) // Filter for delivered and declined
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid) // Filter by user
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No orders found."));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              final orderId = orders[index].id;
              final status = order['status'] ?? 'Unknown';
              final orderDetails = order['orderDetails'] as List<dynamic>?;
             
              final currencyFormat = NumberFormat.currency(symbol: '₹');
              

              return Card(
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ID: $orderId',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      
                      SizedBox(height: 5),
                      Text(
                        'Status: $status',
                        style: TextStyle(
                          color: status == 'delivered'
                              ? Colors.green
                              : status == 'declined'
                                  ? Colors.red
                                  : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      if (orderDetails != null && orderDetails.isNotEmpty) ...[
                        Text(
                          'Items:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...orderDetails.map((item) {
                          final itemName = item['itemName'] ?? 'Unknown Item';
                          final quantity = item['count'] ?? 0;
                          return ListTile(
                            title: Text(itemName),
                            subtitle: Text('Quantity: $quantity'),
                          );
                        }).toList(),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}