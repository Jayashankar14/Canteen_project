import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:sellers_app/view/authScreens/userhome.dart';
import 'package:sellers_app/view/mainScreens/home_screen.dart';
import 'package:sellers_app/view/mainScreens/payment.dart';
import 'package:sellers_app/view/mainScreens/theme_notifier.dart';

class QuantitySelector extends StatefulWidget {
  final int initialQuantity;
  final ValueChanged<int> onChanged;

  const QuantitySelector({
    Key? key,
    required this.initialQuantity,
    required this.onChanged,
  }) : super(key: key);

  @override
  _QuantitySelectorState createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late int _selectedQuantity;

  @override
  void initState() {
    super.initState();
    _selectedQuantity = widget.initialQuantity;
  }

  void _openQuantitySelectorModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: MediaQuery.of(context).size.height / 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Select Quantity',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 1.2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  padding: const EdgeInsets.all(10),
                  itemCount: 10,
                  itemBuilder: (BuildContext context, int index) {
                    final quantity = index + 1;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedQuantity = quantity;
                        });
                        widget.onChanged(quantity);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedQuantity == quantity
                              ? Colors.white
                              : Colors.grey[300],
                          border: Border.all(
                            color: _selectedQuantity == quantity
                                ? Colors.blue
                                : Colors.white,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            quantity.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedQuantity == quantity
                                  ? Colors.blue
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return GestureDetector(
      onTap: () {
        _openQuantitySelectorModal(context);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: themeNotifier.darkTheme ? Colors.black : Colors.white,
          border: Border.all(
            color: themeNotifier.darkTheme ? Colors.white : Colors.black,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Qty: $_selectedQuantity',
              style: TextStyle(
                fontSize: 16,
                color: themeNotifier.darkTheme ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(width: 5),
            Icon(
              Icons.keyboard_arrow_down,
              color: themeNotifier.darkTheme ? Colors.white : Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

class OrderListPage extends StatefulWidget {
  final Map<String, int> itemCounts;

  const OrderListPage({Key? key, required this.itemCounts}) : super(key: key);

  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  double totalAmount = 0.0;
  late Map<String, int> itemCounts;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final departmentController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Form key for validation

  // Define year options
  List<String> yearOptions = ['1', '2', '3', '4'];
  String selectedYear = '1'; // Initial selected year
  bool _areOrdersEnabled = true; // Variable to store the order status

  @override
  void initState() {
    super.initState();
    itemCounts = Map.from(widget.itemCounts);
    calculateTotalAmount();
    _listenToOrderStatus(); // Listen to order status changes
  }

  void _listenToOrderStatus() {
    FirebaseFirestore.instance
        .collection('admin')
        .doc('orderStatus')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          _areOrdersEnabled = snapshot.data()!['areOrdersEnabled'];
        });
      }
    });
  }

  void calculateTotalAmount() {
    if (itemCounts.isEmpty) {
      setState(() {
        totalAmount = 0.0;
      });
      return;
    }

    FirebaseFirestore.instance
        .collection('items')
        .where(FieldPath.documentId, whereIn: itemCounts.keys.toList())
        .get()
        .then((snapshot) {
      double newTotalAmount = 0.0;
      for (var doc in snapshot.docs) {
        var itemId = doc.id;
        var itemCount = itemCounts[itemId] ?? 0;
        if (doc.data().containsKey('price')) {
          var priceField = doc['price'];
          double itemPrice;

          if (priceField is num) {
            itemPrice = priceField.toDouble();
          } else if (priceField is String) {
            itemPrice = double.tryParse(priceField) ?? 0.0;
          } else {
            itemPrice = 0.0;
          }

          newTotalAmount += itemPrice * itemCount;
        }
      }
      setState(() {
        totalAmount = newTotalAmount;
      });
    }).catchError((error) {
      print('Error fetching prices: $error');
    });
  }

  void _removeItem(String itemId) {
    setState(() {
      if (widget.itemCounts[itemId] != null && widget.itemCounts[itemId]! > 0) {
        widget.itemCounts[itemId] = widget.itemCounts[itemId]! - 1;
      }
      if (widget.itemCounts[itemId] == 0) {
        itemCounts.remove(itemId);
      }
      calculateTotalAmount();
    });
  }

  void _incrementItemCount(String itemId) {
    setState(() {
      itemCounts[itemId] = itemCounts[itemId]! + 1;
      calculateTotalAmount();
    });
  }

  void _decrementItemCount(String itemId) {
    setState(() {
      if (itemCounts[itemId]! > 0) {
        itemCounts[itemId] = itemCounts[itemId]! - 1;
        if (itemCounts[itemId] == 0) {
          itemCounts.remove(itemId);
        }
        calculateTotalAmount();
      }
    });
  }

  void _processPayment() async {
    if (!_areOrdersEnabled) {
      // Notify the user that orders are disabled
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Orders are currently disabled.'),
        ),
      );
      return;
    }
    if (itemCounts.isEmpty || itemCounts.values.every((count) => count == 0)) {
      // Notify the user that the cart is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cart is empty. Please add items to place an order.'),
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    String orderId = 'professional_${DateTime.now().millisecondsSinceEpoch}';

    final userDetails = {
      'userId': userId,
      'name': nameController.text,
      'phone': phoneController.text,
      'department': departmentController.text,
      'year': selectedYear,
      'totalAmount': totalAmount,
    };

    final orderDetails = await Future.wait(
        itemCounts.entries.where((entry) => entry.value > 0).map((entry) async {
      var itemDoc = await FirebaseFirestore.instance
          .collection('items')
          .doc(entry.key)
          .get();
      return {
        'itemId': entry.key,
        'itemName': itemDoc['heading'],
        'itemPrice': itemDoc['price'],
        'count': entry.value,
      };
    }).toList());

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          orderId: orderId,
          totalAmount: totalAmount,
          userDetails: userDetails,
          orderDetails: orderDetails,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        final orderedItemIds = itemCounts.entries
            .where((entry) => entry.value > 0)
            .map((entry) => entry.key)
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Order List'),
          ),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: orderedItemIds.isEmpty
                      ? const Center(child: Text('No items in the cart'))
                      : FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('items')
                              .where(FieldPath.documentId,
                                  whereIn: orderedItemIds)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const Center(
                                  child: Text('No items found'));
                            }

                            return ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                var item = snapshot.data!.docs[index];
                                var itemId = item.id;
                                return Card(
                                  color: themeNotifier.darkTheme
                                      ? Colors.black
                                      : Colors.white,
                                  margin: const EdgeInsets.all(10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            item['image'] != null
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Image.network(
                                                      item['image'],
                                                      width: 80,
                                                      height: 80,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : const Placeholder(
                                                    fallbackWidth: 80,
                                                    fallbackHeight: 80,
                                                  ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        item['heading'],
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.red,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: const Icon(
                                                            Icons.delete,
                                                            color: Colors.white,
                                                            size: 20,
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          _removeItem(itemId);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                      'Price: ₹${item['price']}'),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const SizedBox(width: 5),
                                                      QuantitySelector(
                                                        initialQuantity:
                                                            itemCounts[
                                                                    itemId] ??
                                                                1,
                                                        onChanged:
                                                            (newQuantity) {
                                                          setState(() {
                                                            itemCounts[itemId] =
                                                                newQuantity;
                                                            calculateTotalAmount();
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
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
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 3),
                        TextFormField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Phone number is required';
                            }
                            final RegExp phoneRegex = RegExp(r'^[0-9]{10}$');
                            if (!phoneRegex.hasMatch(value)) {
                              return 'Enter a valid 10-digit phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 3),
                        TextFormField(
                          controller: departmentController,
                          decoration: const InputDecoration(
                            labelText: 'Department',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Department is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 3),
                        // DropdownButtonFormField for selecting year
                        DropdownButtonFormField<String>(
                          value: selectedYear,
                          onChanged: (newValue) {
                            setState(() {
                              selectedYear = newValue!;
                            });
                          },
                          items: yearOptions.map((year) {
                            return DropdownMenuItem<String>(
                              value: year,
                              child: Text('Year $year'),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Year',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Year is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Total Amount: ₹$totalAmount',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        ElevatedButton(
                          onPressed: _processPayment,
                          child: const Text('Process Payment'),
                        ),
                      ],
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
}
