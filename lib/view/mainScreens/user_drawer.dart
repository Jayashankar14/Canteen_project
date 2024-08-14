import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sellers_app/global/global_instance.dart';
import 'package:sellers_app/global/global_var.dart';
import 'package:sellers_app/view/authScreens/auth_screen.dart';
import 'package:sellers_app/view/mainScreens/home_screen.dart';
import 'package:sellers_app/view/mainScreens/orderlist.dart'; // Import your order list pages
import 'package:sellers_app/view/splashScreen/splash_screen.dart';
import 'theme_notifier.dart'; // Import your ThemeNotifier class

class MyDrawer2 extends StatelessWidget {
  const MyDrawer2({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 25, bottom: 10),
            child: Column(
              children: [
                Material(
                  borderRadius: const BorderRadius.all(Radius.circular(81)),
                  elevation: 8,
                  child: SizedBox(
                    height: 158,
                    width: 158,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        sharedPreferences!.getString("imageUrl").toString(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(sharedPreferences!.getString("name").toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ))
              ],
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              const Divider(
                height: 10,
                color: Colors.grey,
                thickness: 2,
              ),
              ListTile(
                leading: const Icon(
                  Icons.home,
                ),
                title: const Text(
                  "Home",
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => const HomeScreen()));
                },
              ),
              const Divider(
                height: 10,
                color: Colors.grey,
                thickness: 2,
              ),
              ListTile(
                leading: const Icon(
                  Icons.reorder,
                ),
                title: const Text(
                  "New Orders",
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => NewOrdersPage()));
                },
              ),
              const Divider(
                height: 10,
                color: Colors.grey,
                thickness: 2,
              ),
              ListTile(
                leading: const Icon(
                  Icons.history,
                ),
                title: const Text(
                  "History Orders",
                ),
                onTap: () {
Navigator.push(context,
                      MaterialPageRoute(builder: (c) => HistoryOrdersPage()));
                },
              ),
              const Divider(
                height: 10,
                color: Colors.grey,
                thickness: 2,
              ),
              ListTile(
                leading: const Icon(
                  Icons.share_location,
                ),
                title: const Text(
                  "Update My Address",
                ),
                onTap: () {
                  commonViewModel.updateLocationInDatabase();
                  commonViewModel.ShowSnackBar("Your address updated", context);
                },
              ),
              const Divider(
                height: 10,
                color: Colors.grey,
                thickness: 2,
              ),
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
              const Divider(
                height: 10,
                color: Colors.grey,
                thickness: 2,
              ),
              ListTile(
                leading: const Icon(
                  Icons.exit_to_app,
                ),
                title: const Text(
                  "Sign Out",
                ),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (c) => const AuthScreen()),
                    (route) => false, // This predicate removes all routes in the stack
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
