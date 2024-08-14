import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sellers_app/view/authScreens/PopularItemDetailsPage.dart';
import 'package:sellers_app/view/authScreens/quantity_control.dart';
import 'package:sellers_app/view/mainScreens/cartpage.dart';
import 'package:sellers_app/view/mainScreens/theme_notifier.dart';
import 'package:sellers_app/view/mainScreens/user_drawer.dart';

class CategoryPage extends StatefulWidget {
  final String category;
  final Map<String, int> itemCounts;
  final void Function(String) incrementItemCount;

  const CategoryPage({
    Key? key,
    required this.category,
    required this.itemCounts,
    required this.incrementItemCount,
  }) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  bool _areOrdersEnabled = true;

  @override
  void initState() {
    super.initState();
    _listenToOrderStatus();
  }

  void _listenToOrderStatus() {
    FirebaseFirestore.instance
        .collection('admin')
        .doc('orderStatus')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          _areOrdersEnabled = snapshot.data()?['areOrdersEnabled'] ?? true;
        });
      }
    });
  }

  void incrementItem(String itemId) {
    if (_areOrdersEnabled) {
      setState(() {
        widget.itemCounts[itemId] = (widget.itemCounts[itemId] ?? 0) + 1;
      });
    }
  }

  void decrementItem(String itemId) {
    if (_areOrdersEnabled) {
      setState(() {
        if (widget.itemCounts[itemId] != null && widget.itemCounts[itemId]! > 0) {
          widget.itemCounts[itemId] = widget.itemCounts[itemId]! - 1;
        }
      });
    }
  }

  @override
Widget build(BuildContext context) {
  final themeNotifier = Provider.of<ThemeNotifier>(context);

  return Scaffold(
    appBar: AppBar(
      title: Text(widget.category),
      backgroundColor: themeNotifier.darkTheme ? Colors.black : Colors.white,
      titleTextStyle: TextStyle(
        color: themeNotifier.darkTheme ? Colors.white : Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      iconTheme: IconThemeData(
        color: themeNotifier.darkTheme ? Colors.white : Colors.black,
      ),
    ),
    body: _areOrdersEnabled
        ? StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('items')
                .where('category', isEqualTo: widget.category)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No items found for ${widget.category}'));
              }

              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.6,
                ),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var item = snapshot.data!.docs[index];
                  var itemId = item.id;
                  var itemCount = widget.itemCounts[itemId] ?? 0;
                  bool isAvailable = false;

                  if (item.data() != null) {
                    final data = item.data() as Map<String, dynamic>;
                    isAvailable = data.containsKey('isAvailable') ? data['isAvailable'] ?? true : true;
                  } else {
                    isAvailable = true;
                  }

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    color: themeNotifier.darkTheme ? Colors.grey[900] : Colors.white,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: themeNotifier.darkTheme
                              ? [Colors.black, Colors.black]
                              : [Colors.white, Colors.grey[100]!],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            item['image'] != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      item['image'],
                                      width: double.infinity,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Placeholder(
                                    fallbackWidth: double.infinity,
                                    fallbackHeight: 100,
                                  ),
                            const SizedBox(height: 10),
                            Text(
                              item['heading'] ?? 'No Heading',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: themeNotifier.darkTheme
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              item['news'] ?? 'No Description',
                              style: TextStyle(
                                fontSize: 13,
                                color: themeNotifier.darkTheme
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '₹${item['price'] ?? '0'}',
                              style: const TextStyle(
                                  color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            isAvailable
                                ? QuantityControl(
                                    quantity: itemCount,
                                    onIncrement: () => incrementItem(itemId),
                                    onDecrement: () => decrementItem(itemId),
                                  )
                                : Center(
                                    child: Text(
                                      'Not Available',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          )
        : Center(
            child: Container(
              color: Colors.black54,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info,
                    size: 50,
                    color: Colors.red,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Orders are currently disabled. Please try again later.',
                    style: TextStyle(fontSize: 20, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
    floatingActionButton: _areOrdersEnabled
        ? FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderListPage(itemCounts: widget.itemCounts),
                ),
              ).then((_) {
                setState(() {}); // To update the UI after returning from OrderListPage
              });
            },
            child: const Icon(Icons.shopping_cart),
            backgroundColor: themeNotifier.darkTheme ? Colors.white : Colors.black,
            foregroundColor: themeNotifier.darkTheme ? Colors.black : Colors.white,
          )
        : null,
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
  );
}
}
class HomeScreen2 extends StatefulWidget {
  HomeScreen2({Key? key}) : super(key: key);

  @override
  _HomeScreen2State createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2> {
  final List<Map<String, String>> categories = [
    {'name': 'Chocolates', 'image': 'images/dairymilk.jpg'},
    {'name': 'Biscuits', 'image': 'images/biscuit.jpg'},
    {'name': 'Starters', 'image': 'images/starters.jpg'},
    {'name': 'Snacks', 'image': 'images/puff.jpeg'},
    {'name': 'Soft Drinks', 'image': 'images/drink.jpg'},
    {'name': 'Popular', 'image': 'images/seco.jpg'},
    {'name': 'Special Items', 'image': 'images/sp.jpg'},
  ];

  final Map<String, int> _itemCounts = {};
  bool _areOrdersEnabled = true;

  void _incrementItemCount(String itemId) {
    setState(() {
      _itemCounts[itemId] = (_itemCounts[itemId] ?? 0) + 1;
    });
  }

  @override
  void initState() {
    super.initState();
    _listenToOrderStatus();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            onPressed: _areOrdersEnabled
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderListPage(itemCounts: _itemCounts),
                      ),
                    ).then((_) {
                      setState(() {}); // Update UI after returning from OrderListPage
                    });
                  }
                : null,
            icon: Icon(Icons.shopping_cart),
          ),
        ],
      ),
      drawer: const MyDrawer2(),
      body: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return CategoryCard(
                          category: categories[index]['name']!,
                          imageUrl: categories[index]['image']!,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryPage(
                                  category: categories[index]['name']!,
                                  itemCounts: _itemCounts,
                                  incrementItemCount: _incrementItemCount,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 4.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Popular Items',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0), // Add space between heading and widgets
                  Container(
                    height: 200,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('items')
                          .where('category', isEqualTo: 'Popular')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No popular items found'));
                        }

                        var items = snapshot.data!.docs.where((item) {
      var itemData = item.data() as Map<String, dynamic>?; // Ensure item.data() is casted
      if (itemData != null) {
        return itemData.containsKey('isAvailable') ? itemData['isAvailable'] : true;
      }
      return true;
    }).toList();

                        return ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length,
                          separatorBuilder: (context, index) => SizedBox(width: 16.0), // Add space between items
                          itemBuilder: (context, index) {
                            var item = items[index];
                            var itemId = item.id;
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PopularItemDetailsPage(
                                      item: item,
                                      itemCounts: _itemCounts,
                                      itemId: '',
                                    ),
                                  ),
                                );
                              },
                              child: SizedBox(
                                width: 150,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (item['image'] != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(15),
                                        ),
                                        child: Image.network(
                                          item['image'],
                                          height: 110,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    else
                                      Container(
                                        height: 80,
                                        color: Colors.grey,
                                        child: Center(
                                          child: Text('No Image'),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['heading'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: themeNotifier.darkTheme
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '₹${item['price']}',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
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
                  const SizedBox(height: 1.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Special Items',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
               StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('items')
      .where('category', isEqualTo: 'Special Items')
      .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }
    if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
      return Center(child: Text('No items found for Special Items'));
    }

    var items = snapshot.data!.docs.where((item) {
      var itemData = item.data() as Map<String, dynamic>?; // Ensure item.data() is casted
      if (itemData != null) {
        return itemData.containsKey('isAvailable') ? itemData['isAvailable'] : true;
      }
      return true;
    }).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        var item = items[index];
        var itemId = item.id;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: themeNotifier.darkTheme ? Colors.black : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              item['heading'],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeNotifier.darkTheme ? Colors.white : Colors.black,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  item['news'],
                  style: TextStyle(
                    fontSize: 14,
                    color: themeNotifier.darkTheme ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${item['price']}',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            leading: item['image'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      item['image'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  )
                : Placeholder(
                    fallbackWidth: 80,
                    fallbackHeight: 80,
                  ),
            trailing: IconButton(
              icon: Icon(
                Icons.add_shopping_cart,
                color: themeNotifier.darkTheme ? Colors.white : Colors.black87,
              ),
              onPressed: () {
                _incrementItemCount(item.id); // Increment item count
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderListPage(itemCounts: _itemCounts),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  },
)
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


  Widget buildOrderDisabledContent() {
    return Center(
      child: Container(
        color: Colors.black54,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info,
              size: 50,
              color: Colors.red,
            ),
            SizedBox(height: 10),
            Text(
              'Orders are currently disabled. Please try again later.',
              style: TextStyle(fontSize: 20, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

class CategoryCard extends StatelessWidget {
  final String category;
  final String imageUrl;
  final VoidCallback onTap;

  const CategoryCard({
    required this.category,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            ClipOval(
              child: Image.asset(
                imageUrl,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(category),
          ],
        ),
      ),
    );
  }
}
class SpecialItemDetailsPage extends StatelessWidget {
  final DocumentSnapshot item;
  final Map<String, int> itemCounts;
  final String itemId;

  SpecialItemDetailsPage({
    required this.item,
    required this.itemCounts,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    // Your details page code here
    return Scaffold(
      appBar: AppBar(
        title: Text(item['heading'] ?? 'Special Item'),
      ),
      body: Center(
        child: Text('Details for ${item['heading']}'),
      ),
    );
  }
}

