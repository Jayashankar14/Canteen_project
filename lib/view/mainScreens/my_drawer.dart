import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sellers_app/global/global.dart';
import 'package:sellers_app/global/global_instance.dart';
import 'package:sellers_app/global/global_var.dart';
import 'package:sellers_app/view/authScreens/auth_screen.dart';
import 'package:sellers_app/view/mainScreens/admin_home.dart';
import 'package:sellers_app/view/mainScreens/adminhome2.dart';
import 'package:sellers_app/view/mainScreens/home_screen.dart';
import 'package:sellers_app/view/mainScreens/orderlistadmin.dart';
import 'package:sellers_app/view/mainScreens/theme_notifier.dart';
import 'package:sellers_app/view/splashScreen/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final prefs = snapshot.data!;
        bool isAdminLoggedIn = prefs.getBool("isAdminLoggedIn") ?? false;
        String? adminImageUrl = prefs.getString("adminImageUrl");
        String? adminName = prefs.getString("adminName");
        bool areOrdersEnabled = prefs.getBool("areOrdersEnabled") ?? true;

        return Drawer(
          child: ListView(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 25, bottom: 10),
                child: Column(
                  children: [
                    if (isAdminLoggedIn && adminImageUrl != null)
                      Material(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(81)),
                        elevation: 8,
                        child: SizedBox(
                          height: 158,
                          width: 158,
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(adminImageUrl),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    if (isAdminLoggedIn && adminName != null)
                      Text(
                        adminName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  const Divider(height: 10, color: Colors.grey, thickness: 2),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text("Home"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (c) => const HomeScreen1()),
                      );
                    },
                  ),
                  const Divider(height: 10, color: Colors.grey, thickness: 2),
                  ListTile(
                    leading: const Icon(Icons.reorder),
                    title: const Text("New orders"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (c) => OrdersListPage()),
                      );
                    },
                  ),
                  const Divider(height: 10, color: Colors.grey, thickness: 2),
                  ListTile(
                    leading: const Icon(Icons.local_shipping),
                    title: const Text("History Orders"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => const HistoryOrdersPage()),
                      );
                    },
                  ),
                  const Divider(height: 10, color: Colors.grey, thickness: 2),
                  ListTile(
                    leading: const Icon(Icons.share_location),
                    title: const Text("Update My Address"),
                    onTap: () {
                      commonViewModel.updateLocationInDatabase();
                      commonViewModel.ShowSnackBar(
                          "Your address updated", context);
                    },
                  ),
                  const Divider(height: 10, color: Colors.grey, thickness: 2),
                  Consumer<ThemeNotifier>(
                    builder: (context, themeNotifier, child) {
                      return SwitchListTile(
                        title: const Text("Theme"),
                        secondary: const Icon(Icons.brightness_6),
                        value: themeNotifier.darkTheme,
                        onChanged: (newValue) {
                          themeNotifier.toggleTheme();
                        },
                      );
                    },
                  ),
                  const Divider(height: 10, color: Colors.grey, thickness: 2),
                  ListTile(
                    leading: const Icon(Icons.local_activity),
                    title: areOrdersEnabled
                        ? const Text("Stop Orders")
                        : const Text("Resume Orders"),
                    onTap: () async {
                      bool newOrderStatus = !areOrdersEnabled;

                      // Update the order status in SharedPreferences
                      prefs.setBool("areOrdersEnabled", newOrderStatus);

                      // Update the order status in Firestore
                      await FirebaseFirestore.instance
                          .collection('admin')
                          .doc('orderStatus')
                          .set({'areOrdersEnabled': newOrderStatus});

                      // Show a snackbar notification
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            newOrderStatus
                                ? "Orders resumed"
                                : "Orders stopped",
                          ),
                        ),
                      );

                      // Optionally, refresh the state to reflect changes
                      setState(() {});
                    },
                  ),
                  const Divider(height: 10, color: Colors.grey, thickness: 2),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app),
                    title: const Text("Sign Out"),
                    onTap: () async {
                      AuthViewModel().signOut(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void setState(Null Function() param0) {}
}
