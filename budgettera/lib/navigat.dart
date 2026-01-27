import 'package:budgettera/budget_screen.dart';
import 'package:budgettera/home.dart';
import 'package:flutter/material.dart';
import 'custom_navbar.dart';

class Navigat extends StatefulWidget {
  const Navigat({super.key});

  @override
  State<Navigat> createState() => _NavigatState();
}

class _NavigatState extends State<Navigat> {
  int currentIndex = 0;

  final List<Widget> pages = [
    Home(userName: 'Abel'),
    Wallet(),
    Center(child: Text("Transactions Page")),
    Center(child: Text("Analytics Page")),
    Center(child: Text("Profile Page")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: pages[currentIndex],

      bottomNavigationBar: CustomNavBar(
        currentIndex: currentIndex,
        onTabSelected: (index) {
          setState(() => currentIndex = index);
        },
      ),
    );
  }
}
