import 'package:flutter/material.dart';

// COMMON BUTTON STYLE
final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: const Color(0xFF0135C5),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  padding: const EdgeInsets.symmetric(vertical: 15),
);

const inputDecoration = InputDecoration(
  filled: true,
  fillColor: Color(0xFFF3F6FA),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
    borderSide: BorderSide.none,
  ),
);

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password?'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0135C5),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Forgot Password?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0135C5),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Don\'t worry! It happens. Please provide the email address associated with your account.',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: emailController,
              decoration: inputDecoration.copyWith(
                hintText: 'Enter your email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: primaryButtonStyle,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VerificationScreen(
                        email: emailController.text.trim(),
                      ),
                    ),
                  );
                },
                child: const Text('Verify code'),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Remember Password? '),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // back to login
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Color(0xFF0135C5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class VerificationScreen extends StatefulWidget {
  final String email;
  const VerificationScreen({super.key, required this.email});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  // 4 digit code inputs
  final List<TextEditingController> controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void verifyCode() {
    // You can add your real verification logic here

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CreateNewPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0135C5),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verification',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0135C5),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Enter the verification code we just sent on your email address (${widget.email})',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) {
                return SizedBox(
                  width: 55,
                  height: 55,
                  child: TextField(
                    controller: controllers[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    decoration: inputDecoration.copyWith(counterText: ''),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 3) {
                        FocusScope.of(context).nextFocus();
                      } else if (value.isEmpty && index > 0) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: primaryButtonStyle,
                onPressed: verifyCode,
                child: const Text('Verify'),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: () {
                  // Resend code logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Verification code resent!')),
                  );
                },
                child: const Text(
                  "Didn't receive code? Resend",
                  style: TextStyle(
                    color: Color(0xFF0135C5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateNewPasswordScreen extends StatefulWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  State<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  void resetPassword() {
    if (newPasswordController.text == confirmPasswordController.text &&
        newPasswordController.text.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoadingScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match or are empty.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create new password'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0135C5),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create new password',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0135C5),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your new password must be unique from those previously used.',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: inputDecoration.copyWith(hintText: 'New Password'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: inputDecoration.copyWith(
                hintText: 'Confirm Password',
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: primaryButtonStyle,
                onPressed: resetPassword,
                child: const Text('Reset Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulate some loading delay then navigate to Password Changed screen
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PasswordChangedScreen()),
      );
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            // 3 dots animation placeholder
            _Dot(active: true),
            SizedBox(height: 15),
            Text(
              'Please wait...',
              style: TextStyle(fontSize: 18, color: Color(0xFF0135C5)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: active ? 18 : 12,
      height: active ? 18 : 12,
      decoration: BoxDecoration(
        color: const Color(0xFF0135C5),
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }
}

class PasswordChangedScreen extends StatelessWidget {
  const PasswordChangedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Changed!'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0135C5),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF0135C5), size: 100),
            const SizedBox(height: 20),
            const Text(
              'Password Changed!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0135C5),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your password has been changed successfully.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: primaryButtonStyle,
                onPressed: () {
                  // Navigate to login screen or wherever you want
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Back to login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
