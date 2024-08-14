import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:googleapis_auth/auth_io.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const String firebaseScope =
    'https://www.googleapis.com/auth/firebase.messaging';

const String serviceAccountJson = '''
{
  "type": "service_account",
  "project_id": "sellersapp-efbe5",
  "private_key_id": "90a051bb25a01b610de496d1f32bd06b0fb9f098",
  "private_key": "-----BEGIN PRIVATE KEY-----\\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCK2J5AGiYLaos0\\nU0i0DUsuS3FDilLef0+MksoGNTTjSDVogILOe9DhWlAvfTMlhm9NrlP36beDAw7a\\ng76A349/2WmF6BxN2XXwz4ps/MUxYNSchAajBGCbyH7bDUSA2/v7n+cbBBxMfKp8\\nFLP5NvAJbyU9NcLrStUn5p31kCay0ZCh4gvF2/kHMNtC3Shxt2Efqw/MU6Fvd1de\\nOgacMfxaANa3VNoPT5Asz+ufY7cqMoSYNqVeJwFIhdQAP2Gie449BQPBnAPbxNY+\\ngcIhHL4+LxSpMgSY2myHWQNQwI3qrl2iz5NWzKu9Ex7cx9M9mdsECnuUNRJzhXHD\\nmAKyshMxAgMBAAECggEACdsOgKZahPzvHKu8wWsgJw0b4Rt0fm6zCttwk7g7JNb/\\nU4erwVRwo05x2q0ccFF2nSD+vN5ONHKHH2Oyphs4aG7aWrL7L1t8T7err8jRhovF\\nC8cjYXbyFJzKxGnQrwTughH7qaNFDvjacSxXCh2oNEM7dXjXeTQ6pTZth/zPgmnb\\nAlvZS58DrAWUMUHJiVTTiscnPYNO8oRwbLHJnwScjEf7fMvsILh/t/9WuFeofj/k\\n3gkBVH25Jt0UUvx3lcrozH+NKw0zILVDL4cKrykyuU7eyWiVQVX8njA1CYYDylYX\\n2p0aTzgMUpDUBewy1WHX21GgmvS3dMieZ36Won6xMQKBgQC9KMVdEuhc3mB+qxNT\\nBthd3g40kkPXVRgCVvmmrFRJkhs9Q83k/7f7nycOZ0+vw1cnPRQ2/2SU1+f408JR\\nQL0HeU/vWOZLctDCFOtbYGCZLU6CJaTv0TpZt3DVpf09H+tAOok1hlkB7ehbvtOS\\ncxVWV+hGFLfg5esF3qM012DHjwKBgQC76I5Il6O+xXiFmXDAVZwMTZIt9JVgkJxd\\nHELjhk40KZnkB3sFGCRu4q2Op1QJt9cCx8Va6s7hSqIVSC4ekLZ1oLBdkNyPzYbn\\np5gKZrZRZG9s26JJSG/6zzOAjqPEHaTWfVqRFaj1Kqx9oLGD1z9VD/ySk6rYirzO\\nD9M6iVwZPwKBgAWWfr4RIOwdZZxYUWnSefHL7X+AEqD50ou/JgDWdmb1+fgFWL+7\\nDiRQv0adpqz6iEiQdVhqkv4SorenCcZ8sxjVbJcVeTghXClflNRONIxR2k/d7NFo\\nzOB5msu065YyqzBqikMahOaZsJOFP5rD641xa1smoYfzQs4ZlZiqBCHhAoGBAJrm\\nrYwn/SMBVEYF5E2ZBQebVpqtmgo9i7ix2G4JRCR5+tNgW0gqy7XhBSOoyn0sYIF5\\nPzaghCRySsTyeJpXvyGecmTfSwL8cW472PkSDM9x1OzO7awtm6oM7q7WZyf/K+ho\\n86TQTzSzlfgF5PADG8E6aYJHWrohPF097Gm/2/0vAoGBALdhw6jKOUa6fRv+2LvQ\\nl6T83igPjAQXqvM1BoC7me88EqGnvqXQFrx2cLqZR6O6jyoJOfDab38COWy8Hhvn\\n0mhX16QbalyuAGsj6qDmDQhXiCuj7CiRA5LJylkqwW0ZWd1x4EuQeEierQFOiA78\\nLXUdLKgcZYFzNxVgKWNSbNib\\n-----END PRIVATE KEY-----\\n",
  "client_email": "firebase-adminsdk-19xek@sellersapp-efbe5.iam.gserviceaccount.com",
  "client_id": "105499506637080311969",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-19xek%40sellersapp-efbe5.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
''';

Future<String> getAccessToken(String serviceAccountJson) async {
  final accountCredentials =
      ServiceAccountCredentials.fromJson(serviceAccountJson);
  final client = http.Client();

  AccessCredentials credentials =
      await obtainAccessCredentialsViaServiceAccount(
          accountCredentials, [firebaseScope], client);

  client.close();
  return credentials.accessToken.data;
}

class OrdersListPage extends StatefulWidget {
  const OrdersListPage({Key? key}) : super(key: key);

  @override
  _OrdersListPageState createState() => _OrdersListPageState();
}

class _OrdersListPageState extends State<OrdersListPage> {
  final Map<String, String> _orderStatuses = {};

  bool _firstLoad = true;

  Future<void> _showDeclineReasonDialog(String orderId, String userId) async {
    TextEditingController reasonController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Decline Order'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Please enter the reason for declining this order:'),
                const SizedBox(height: 10),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Reason',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Decline'),
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isNotEmpty) {
                  Navigator.of(context).pop();
                  await _handleOrderDecline(orderId, userId, reason);
                } else {
                  // Optionally show an error if no reason is provided
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please provide a reason')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleOrderDecline(
      String orderId, String userId, String reason) async {
    try {
      // Send the decline notification with reason
      await _sendNotification(
          userId,
          'Order Declined',
          'Your order is $orderId eclined due to $reason.',
          orderId,
          'declined');

      // Move the order to history
      await _moveOrderToHistory(orderId);

      // Update the UI
      setState(() {
        _orderStatuses[orderId] = 'declined';
      });
    } catch (e) {
      print('Error handling order decline: $e');
    }
  }

  late FirebaseMessaging messaging;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();

    // Initialize Firebase Messaging
    messaging = FirebaseMessaging.instance;

    // Initialize Flutter Local Notifications Plugin
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          'Received a message in the foreground: ${message.notification?.title}');

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel', // channel ID
              'High Importance Notifications', // channel name
              channelDescription:
                  'This channel is used for important notifications.',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });
  }

  Future<void> _sendNotification(String userId, String title, String message,
      String orderId, String status) async {
    try {
      // Fetch the FCM token for the user from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(userId)
          .get();
      if (!userDoc.exists) {
        print('User does not exist');
        return;
      }
      final userData = userDoc.data();
      String fcmToken = userDoc['fcmToken'];
      if (fcmToken == null) {
        print('User does not have an FCM token');
        return;
      }

      // Define the notification payload
      Map<String, dynamic> notificationPayload = {
        'message': {
          'token': fcmToken,
          'notification': {
            'title': title,
            'body': message,
          },
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': status,
          },
        },
      };

      // Send the notification via HTTP POST request
      final accessToken = await getAccessToken(serviceAccountJson);
      final response = await http.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/sellersapp-efbe5/messages:send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(notificationPayload),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
        // Update order status in Firestore
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .update({'status': status});
        setState(() {
          _orderStatuses[orderId] = status;
        });
        if (status == 'declined') {
          await _moveOrderToHistory(orderId);
        }
      } else {
        print(
            'Failed to send notification. Status code: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
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

  Future<void> _markAsReady(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'status': 'ready'});

      final orderDoc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .get();
      final userData = orderDoc.data();
      if (userData != null) {
        final userId = userData['userDetails']['userId'];
        await _sendNotification(userId, 'Order Ready',
            'Your order is ready for pickup.', orderId, 'ready');
      }

      setState(() {
        _orderStatuses[orderId] = 'ready'; // Ensure this reflects in UI
      });
    } catch (e) {
      print('Error marking order as ready: $e');
    }
  }

  Future<void> _deliverOrder(String orderId) async {
    try {
      await _moveOrderToHistory(orderId);
      setState(() {
        _orderStatuses[orderId] = 'delivered'; // Update status to delivered
      });
    } catch (e) {
      print('Error delivering order: $e');
    }
  }

  Future<void> _pickupOrder(String orderId) async {
    try {
      await _moveOrderToHistory(orderId);
      setState(() {
        _orderStatuses[orderId] = 'picked up'; // Update status to picked up
      });
    } catch (e) {
      print('Error picking up order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context); // Get current theme

    return Scaffold(
      appBar: AppBar(title: const Text('Orders List')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<DocumentSnapshot> documents = snapshot.data!.docs;
          if (_firstLoad && documents.isNotEmpty) {
            // Trigger notification on the first load
            // _sendNotificationToOwner();
            _firstLoad = false;
          }

          if (documents.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final orderData = documents[index].data() as Map<String, dynamic>;
              final userDetails =
                  orderData['userDetails'] as Map<String, dynamic>;
              final orderDetails = orderData['orderDetails'] as List<dynamic>;
              final orderId = documents[index].id;
              final transactionId = orderData['transactionId'] ?? 'N/A';
              final orderStatus =
                  _orderStatuses[orderId] ?? orderData['status'] ?? 'pending';

              Color cardColor =
                  orderStatus == 'ready' ? Colors.grey : theme.cardColor;

              return Card(
                margin: const EdgeInsets.all(10.0),
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order ID: $orderId',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text('Name: ${userDetails['name']}'),
                      Text('Phone: ${userDetails['phone']}'),
                      Text('Department: ${userDetails['department']}'),
                      Text('Year: ${userDetails['year']}'),
                      const SizedBox(height: 10),
                      const Text('Ordered Items:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      ...orderDetails.map((item) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Item Name: ${item['itemName']}'),
                            Text('Item Price: ₹${item['itemPrice']}'),
                            Text('Quantity: ${item['count']}'),
                            const Divider(),
                          ],
                        );
                      }).toList(),
                      Text('Total Amount: ₹${userDetails['totalAmount']}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Transaction ID: $transactionId',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      if (orderStatus == 'pending')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                await _sendNotification(
                                    userDetails['userId'],
                                    'Order Accepted',
                                    'Your order has been accepted.',
                                    orderId,
                                    'accepted');
                              },
                              child: const Text('Accept'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () async {
                                await _showDeclineReasonDialog(
                                    orderId, userDetails['userId']);
                              },
                              child: const Text('Decline'),
                            ),
                          ],
                        ),
                      if (orderStatus == 'accepted' ||
                          orderStatus == 'preparing')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: orderStatus == 'accepted'
                                  ? () async {
                                      await _markAsReady(orderId);
                                    }
                                  : null,
                              child: const Text('Mark as Ready'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: orderStatus == 'ready'
                                  ? () async {
                                      await _deliverOrder(orderId);
                                    }
                                  : null,
                              child: const Text('Deliver Order'),
                            ),
                          ],
                        ),
                      if (orderStatus == 'ready')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                await _deliverOrder(orderId);
                              },
                              child: const Text('Deliver Order'),
                            ),
                          ],
                        ),
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

  // Future<void> _sendNotificationToOwner() async {
  //   const String ownerId =
  //       'opk8N8cmzIRSKZjeCnap7wyaNwi1'; // Replace with actual owner ID
  //   print('Attempting to send notification to owner with ID: $ownerId');

  //   try {
  //     await _sendNotification(
  //         ownerId,
  //         'New Order Received',
  //         'A new order has been placed.',
  //         '', // You can pass additional data if needed
  //         'new_order');

  //     print('Notification sent successfully to ownerId: $ownerId');
  //   } catch (e) {
  //     print('Failed to send notification to ownerId: $ownerId. Error: $e');
  //   }
  // }
}

class HistoryOrdersPage extends StatefulWidget {
  const HistoryOrdersPage({Key? key}) : super(key: key);

  @override
  _HistoryOrdersPageState createState() => _HistoryOrdersPageState();
}

class _HistoryOrdersPageState extends State<HistoryOrdersPage> {
  bool _isSelectionMode = false;
  final Set<String> _selectedOrderIds = {};

  Future<void> _clearAllOrders() async {
    bool confirm = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Clear All Orders'),
              content: const Text(
                  'Are you sure you want to clear all orders? This action cannot be undone.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('Clear All'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirm) {
      final collection = FirebaseFirestore.instance.collection('historyOrders');
      final querySnapshot = await collection.get();
      final batch = FirebaseFirestore.instance.batch();

      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    }
  }

  Future<void> _clearSelectedOrders() async {
    if (_selectedOrderIds.isEmpty) return;

    bool confirm = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Selected Orders'),
              content: const Text(
                  'Are you sure you want to delete the selected orders? This action cannot be undone.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirm) {
      final collection = FirebaseFirestore.instance.collection('historyOrders');
      final batch = FirebaseFirestore.instance.batch();

      for (var orderId in _selectedOrderIds) {
        final docRef = collection.doc(orderId);
        batch.delete(docRef);
      }

      await batch.commit();

      setState(() {
        _isSelectionMode = false;
        _selectedOrderIds.clear();
      });
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedOrderIds.clear();
      }
    });
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('EEE, d MMM yyyy');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.colorScheme.background;
    final containerColor = theme.brightness == Brightness.dark
        ? Colors.grey[700]
        : Colors.grey[300];
    final textColor = theme.textTheme.bodyText1?.color ?? Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History', style: TextStyle(fontSize: 23)),
        actions: <Widget>[
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete_forever, size: 20),
              onPressed: _clearSelectedOrders,
              tooltip: 'Delete Selected Orders',
            ),
          IconButton(
            icon: Icon(
              _isSelectionMode ? Icons.cancel : Icons.select_all,
              size: 20,
            ),
            onPressed: _toggleSelectionMode,
            tooltip: _isSelectionMode ? 'Cancel Selection' : 'Select Orders',
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, size: 20),
            onPressed: _clearAllOrders,
            tooltip: 'Clear All Orders',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('historyOrders')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<DocumentSnapshot> documents = snapshot.data!.docs;

          if (documents.isEmpty) {
            return const Center(child: Text('No history found.'));
          }

          final Map<String, List<DocumentSnapshot>> groupedOrders = {};
          for (var doc in documents) {
            final orderData = doc.data() as Map<String, dynamic>;
            final timestamp = (orderData['timestamp'] as Timestamp).toDate();
            final formattedDate = _formatDate(timestamp);

            if (!groupedOrders.containsKey(formattedDate)) {
              groupedOrders[formattedDate] = [];
            }
            groupedOrders[formattedDate]!.add(doc);
          }

          int totalOrders = 0;
          double totalAmount = 0;

          for (var doc in documents) {
            final orderData = doc.data() as Map<String, dynamic>;
            final orderStatus = orderData['status'] ?? 'pending';

            if (orderStatus != 'declined') {
              final userDetails =
                  orderData['userDetails'] as Map<String, dynamic>;
              totalOrders++;
              totalAmount += (userDetails['totalAmount'] ?? 0);
            }
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: groupedOrders.entries.map((entry) {
                    final date = entry.key;
                    final orders = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            date,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                            ),
                          ),
                        ),
                        ...orders.map((doc) {
                          final orderData = doc.data() as Map<String, dynamic>;
                          final userDetails =
                              orderData['userDetails'] as Map<String, dynamic>;
                          final orderDetails =
                              orderData['orderDetails'] as List<dynamic>;
                          final orderId = doc.id;
                          final transactionId =
                              orderData['transactionId'] ?? 'N/A';
                          final orderStatus = orderData['status'] ?? 'pending';

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 8.0),
                            child: ListTile(
                              leading: _isSelectionMode
                                  ? Checkbox(
                                      value:
                                          _selectedOrderIds.contains(orderId),
                                      onChanged: (isSelected) {
                                        setState(() {
                                          if (isSelected == true) {
                                            _selectedOrderIds.add(orderId);
                                          } else {
                                            _selectedOrderIds.remove(orderId);
                                          }
                                        });
                                      },
                                    )
                                  : null,
                              title: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Order ID: $orderId',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    const SizedBox(height: 5),
                                    Text('Name: ${userDetails['name']}',
                                        style: const TextStyle(fontSize: 15)),
                                    Text('Phone: ${userDetails['phone']}',
                                        style: const TextStyle(fontSize: 15)),
                                    Text(
                                        'Department: ${userDetails['department']}',
                                        style: const TextStyle(fontSize: 15)),
                                    Text('Year: ${userDetails['year']}',
                                        style: const TextStyle(fontSize: 15)),
                                    const SizedBox(height: 5),
                                    const Text('Ordered Items:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    const SizedBox(height: 3),
                                    ...orderDetails.map((item) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Item Name: ${item['itemName']}',
                                              style: const TextStyle(
                                                  fontSize: 15)),
                                          Text(
                                              'Item Price: ₹${item['itemPrice']}',
                                              style: const TextStyle(
                                                  fontSize: 15)),
                                          Text('Quantity: ${item['count']}',
                                              style: const TextStyle(
                                                  fontSize: 15)),
                                          const Divider(),
                                        ],
                                      );
                                    }).toList(),
                                    Text(
                                        'Total Amount: ₹${userDetails['totalAmount']}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    Text('Transaction ID: $transactionId',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    Text('Status: $orderStatus',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: orderStatus == 'declined'
                                                ? Colors.red
                                                : textColor)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),
                ),
              ),
              Container(
                color: containerColor,
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Orders: $totalOrders',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('Total Amount: ₹$totalAmount',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
