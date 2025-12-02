import 'package:budgettera/sign_in.dart';
import 'package:budgettera/sign_up.dart';
import 'package:flutter/material.dart';

class Launch extends StatelessWidget {
  const Launch({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [?Colors.blue[900], ?Colors.blue[800], ?Colors.blue[400]],
            begin: Alignment.topLeft,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  "Budgetterra",
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 150),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUp()),
                  );
                },
                child: LaunchContainer(
                  authText: "Sign UP",
                  customColor: Colors.transparent,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignIn()),
                  );
                },
                child: LaunchContainer(
                  authText: "Sign In",
                  customColor: Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LaunchContainer extends StatelessWidget {
  final String authText;
  final Color customColor;
  const LaunchContainer({
    super.key,
    required this.authText,
    required this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        border: BoxBorder.all(width: 2, color: Colors.white),
        color: customColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        authText,
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}
