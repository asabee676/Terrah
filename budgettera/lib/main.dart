import 'package:flutter/material.dart';
import 'package:budgettera/splash.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen()));
}
