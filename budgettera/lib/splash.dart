import 'package:budgettera/onboarding_screen.dart';
import 'package:budgettera/navigat.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Delay splash for 2 seconds then navigate based on session status
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Onboarding()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2EF), // light teal
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo
            Image.asset("images/logo.png", height: 220),

            const SizedBox(height: 40),

            // loading spinner
            const CircularProgressIndicator(strokeWidth: 5, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
