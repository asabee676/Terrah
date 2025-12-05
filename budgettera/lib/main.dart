import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budgettera/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jiykdyfhsglbsjikeamz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImppeWtkeWZoc2dsYnNqaWtlYW16Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ2MjM0OTUsImV4cCI6MjA4MDE5OTQ5NX0.Q6o4Vi6G0onZD648cKgsaj4Jv-4ufAsUGfTTli2HhPM',
  );

  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen()));
}
