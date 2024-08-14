import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sellers_app/global/global_var.dart';
import 'package:sellers_app/view/splashScreen/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'view/mainScreens/theme_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  sharedPreferences = await SharedPreferences.getInstance();
  await Permission.locationWhenInUse.isDenied.then((valueOfPermission) {
    if (valueOfPermission) {
      Permission.locationWhenInUse.request();
    }
  });

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Sellers App',
          theme: themeNotifier.darkTheme ? ThemeData.dark() : ThemeData.light(),
          debugShowCheckedModeBanner: false,
          home: const MySplashScreen(),
        );
      },
    );
  }
}
