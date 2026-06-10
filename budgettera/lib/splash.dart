import 'package:budgettera/onboarding_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinnerCtrl;

  @override
  void initState() {
    super.initState();

    _spinnerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Onboarding()),
      );
    });
  }

  @override
  void dispose() {
    _spinnerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F4F1), // off-white
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // ── Logo ───────────────────────────────────────────
            Image.asset(
              'images/logo.png',
              width: 320,
              fit: BoxFit.contain,
            ),

            const Spacer(),

            // ── Loading indicator ───────────────────────────────
            SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                strokeWidth: 5,
                color: const Color(0xFF007AFF),   // dominant blue
                backgroundColor: const Color(0xFF007AFF).withValues(alpha: 0.15),
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
