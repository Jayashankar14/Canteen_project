import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sellers_app/global/global.dart';
import 'package:sellers_app/view/authScreens/userhome.dart';
import 'package:sellers_app/view/mainScreens/home_screen.dart';

import 'package:googleapis_auth/auth_io.dart';

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

class PaymentPage extends StatefulWidget {
  final String orderId;
  final double totalAmount;
  final Map<String, dynamic> userDetails;
  final List<Map<String, dynamic>> orderDetails;

  const PaymentPage({
    Key? key,
    required this.orderId,
    required this.totalAmount,
    required this.userDetails,
    required this.orderDetails,
  }) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _transactionIdController =
      TextEditingController();

  Future<void> _sendNotificationToOwner(
      String ownerId, String title, String message) async {
    try {
      // Fetch the FCM token for the owner from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(ownerId)
          .get();

      if (!userDoc.exists) {
        print('No document found for ownerId: $ownerId');
        return;
      }

      final fcmToken = userDoc['fcmToken'];

      if (fcmToken == null || fcmToken.isEmpty) {
        print('FCM token is missing for ownerId: $ownerId');
        return;
      }

      final url = Uri.parse(
          'https://fcm.googleapis.com/v1/projects/sellersapp-efbe5/messages:send');
      final accessToken = await getAccessToken(
          serviceAccountJson); // Implement this function to get access token

      final headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      final body = jsonEncode({
        "message": {
          "token": fcmToken,
          "notification": {
            "title": title,
            "body": message,
          },
          "data": {
            "orderId": widget.orderId,
          },
        },
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<String> getNextOrderId(String userId) async {
    final today = DateTime.now();
    final dateKey =
        "${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}";

    final userDoc = FirebaseFirestore.instance
        .collection('user_daily_order_counters')
        .doc(userId);

    try {
      final docSnapshot = await userDoc.get();
      final data = docSnapshot.data() as Map<String, dynamic>?;

      int newOrderNumber;

      if (data == null || !data.containsKey(dateKey)) {
        // Initialize counter for today if it doesn't exist
        newOrderNumber = 1;
        await userDoc.set({dateKey: newOrderNumber});
      } else {
        // Increment the order number for today
        newOrderNumber = data[dateKey] + 1;
        await userDoc.update({dateKey: newOrderNumber});
      }

      return newOrderNumber.toString();
    } catch (e) {
      print('Error getting next order ID: $e');
      return '';
    }
  }

  void _placeOrder(BuildContext context) async {
    if (ordersStopped) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Orders Stopped"),
            content: const Text("Orders are currently not being accepted."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter Transaction ID"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  "Thank you for your order! Please enter your transaction ID (23 characters):"),
              const SizedBox(height: 10),
              TextField(
                controller: _transactionIdController,
                maxLength: 23,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter Transaction ID',
                ),
                keyboardType: TextInputType.text,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_transactionIdController.text.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Error"),
                        content: const Text(
                            "Transaction ID is required. Please enter the transaction ID."),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // Check if transaction ID is unique
                  final querySnapshot = await FirebaseFirestore.instance
                      .collection('orders')
                      .where('transactionId',
                          isEqualTo: _transactionIdController.text)
                      .get();

                  if (querySnapshot.docs.isNotEmpty) {
                    // Transaction ID is not unique
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Error"),
                          content: const Text(
                              "Please enter a unique transaction ID."),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    // Show loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible:
                          false, // Prevent dismissing by tapping outside
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Processing Order"),
                          content: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 20),
                              Text('Placing your order...'),
                            ],
                          ),
                        );
                      },
                    );

                    try {
                      // Get next order ID and place the order
                      String orderId = await getNextOrderId(
                          'user1'); // Adjust the user ID as needed
                      String prefixedOrderId =
                          'SVEC_10$orderId'; // Add the prefix

                      await FirebaseFirestore.instance
                          .collection('orders')
                          .doc(
                              prefixedOrderId) // Use prefixedOrderId instead of newOrderId
                          .set({
                        'userId': widget.userDetails['userId'],
                        'userDetails': widget.userDetails,
                        'orderDetails': widget.orderDetails,
                        'transactionId': _transactionIdController.text,
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      // Send notification to owner
                      const String ownerId =
                          'opk8N8cmzIRSKZjeCnap7wyaNwi1'; // Replace with actual owner ID
                      await _sendNotificationToOwner(
                        ownerId,
                        'New Order Received',
                        'A new order with ID $prefixedOrderId has been placed.',
                      );

                      // Close the loading dialog
                      Navigator.of(context).pop();

                      // Navigate to HomeScreen2
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen2(),
                        ),
                        (route) => false,
                      );
                    } catch (e) {
                      print('Error placing order: $e');
                      Navigator.of(context).pop(); // Close the loading dialog

                      // Show error dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Error"),
                            content: const Text(
                                "There was an error placing your order. Please try again."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }
                }
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Image.asset(
                          'images/phonepay.jpg', // Path to your PhonePe QR code image
                          width:
                              double.infinity, // Take up full width available
                          height: 400, // Adjust height as needed
                          fit: BoxFit.contain, // Fit the image to the screen
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Scan the QR code above and complete the payment process using PhonePe.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (ordersStopped) // Display message if orders are stopped
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Orders are currently not being accepted.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ElevatedButton(
            onPressed: ordersStopped
                ? null
                : () {
                    _placeOrder(context); // Place order when button is pressed
                  },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
              child: Text('Order Now'),
            ),
          ),
        ],
      ),
    );
  }
}
