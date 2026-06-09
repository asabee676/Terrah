import 'package:budgettera/budget_screen.dart';
import 'package:budgettera/home.dart';
import 'package:budgettera/transactions_screen.dart';
import 'package:budgettera/analytics_screen.dart';
import 'package:budgettera/profile_screen.dart';
import 'package:flutter/material.dart';
import 'custom_navbar.dart';

class Navigat extends StatefulWidget {
  const Navigat({super.key});

  @override
  State<Navigat> createState() => _NavigatState();
}

class _NavigatState extends State<Navigat> {
  int currentIndex = 0;
  String userName = 'User';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() {
    // Mock user data since Supabase is removed
    setState(() {
      userName = 'Abel';
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      Home(userName: userName),
      const Wallet(),
      const TransactionsScreen(),
      const AnalyticsScreen(),
      const ProfileScreen(),
    ];

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
