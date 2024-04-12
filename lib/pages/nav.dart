// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:fitness/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

// ignore: camel_case_types
class navBar extends StatefulWidget {
  const navBar({super.key});

  @override
  State<navBar> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<navBar> {
  int myIndex = 0;
  List<Widget> widgetList = const [
    HomePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: widgetList[myIndex],
        ),
        bottomNavigationBar: Container(
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GNav(
                  backgroundColor: Colors.black,
                  color: Colors.white,
                  activeColor: Colors.white,
                  tabBackgroundColor: Colors.grey.shade800,
                  gap: 8,
                  onTabChange: (index) {
                    setState(() {
                      myIndex = index;
                    });
                  },
                  padding: EdgeInsets.all(12),
                  tabs: [
                    GButton(
                      icon: Icons.home,
                      text: 'Home',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
