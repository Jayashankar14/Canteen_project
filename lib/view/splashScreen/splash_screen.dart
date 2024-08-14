import 'package:flutter/material.dart';
import 'package:sellers_app/view/authScreens/auth_screen.dart';
import 'package:sellers_app/view/authScreens/userhome.dart';
import 'package:sellers_app/view/mainScreens/adminhome2.dart';
import 'package:sellers_app/view/mainScreens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  initTimer() async {
    await Future.delayed(const Duration(seconds: 3));

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool isAdminLoggedIn =
        sharedPreferences.getBool("isAdminLoggedIn") ?? false;
    print(isAdminLoggedIn);

    if (FirebaseAuth.instance.currentUser == null && !isAdminLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => const AuthScreen()),
      );
    } else if (isAdminLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => const HomeScreen1()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => HomeScreen2()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    initTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset("images/bakery.jpeg"),
            ),
            const Text(
              "iFood",
              textAlign: TextAlign.center,
              style: TextStyle(
                letterSpacing: 3,
                fontSize: 26,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
