import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sellers_app/view/authScreens/signin_screen.dart';
import 'package:sellers_app/view/authScreens/signup_screen.dart';
import 'package:sellers_app/view/mainScreens/theme_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Consumer<ThemeNotifier>(
            builder: (context, themeNotifier, child) {
              return Text(
                "iFood",
                style: TextStyle(
                  fontSize: 26,
                  color: themeNotifier.darkTheme ? Colors.white : Colors.black,
                ),
              );
            },
          ),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Consumer<ThemeNotifier>(
                  builder: (context, themeNotifier, child) {
                    return Icon(
                      Icons.lock,
                      color:
                          themeNotifier.darkTheme ? Colors.white : Colors.black,
                    );
                  },
                ),
                text: "Sign in",
              ),
              Tab(
                icon: Consumer<ThemeNotifier>(
                  builder: (context, themeNotifier, child) {
                    return Icon(
                      Icons.person,
                      color:
                          themeNotifier.darkTheme ? Colors.white : Colors.black,
                    );
                  },
                ),
                text: "Signup",
              ),
            ],
            indicatorColor: Colors.lightBlueAccent,
            indicatorWeight: 5,
          ),
        ),
        body: Container(
          color: Colors.blue,
          child: TabBarView(
            children: [
              SigninScreen(),
              SignupScreen(),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthViewModel {
  Future<void> signOut(BuildContext context) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    //  await sharedPreferences.clear();
    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (c) => const AuthScreen()));
  }
}
