// ignore_for_file: unused_import, unnecessary_const

import 'package:flutter/material.dart';
import 'package:sellers_app/view/authScreens/userhome.dart';
import 'package:sellers_app/view/mainScreens/admin_home.dart';
import 'package:sellers_app/view/mainScreens/my_drawer.dart';
import 'package:sellers_app/view/mainScreens/tab_bar.dart';
import 'package:sellers_app/view/mainScreens/user_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Home")),
      // drawer: const MyDrawer2(),
      // //body: const MyTabBar(),
      body: HomeScreen2(),
    );
  }
}
