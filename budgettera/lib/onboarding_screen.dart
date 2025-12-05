import 'package:budgettera/launch.dart';
import 'package:flutter/material.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _controller = PageController();
  int currentPage = 0;

  // AUTO-SLIDE TIMER
  @override
  void initState() {
    super.initState();
    autoSlide();
  }

  void autoSlide() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 7));

      if (!mounted) return;

      if (currentPage < pages.length - 1) {
        _controller.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      } else {
        _controller.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    }
  }

  final List<Map<String, String>> pages = [
    {
      "image": "images/first.png",
      "title": "Your budget, your future\nstart today!",
      "description":
          "Lorem ipsum dolor sit amet,\nconsectetur adipiscing elit.",
    },
    {
      "image": "images/second.png",
      "title": "Organize your finances\nwith ease and achieve your goals.",
      "description":
          "Lorem ipsum dolor sit amet,\nconsectetur adipiscing elit.",
    },
    {
      "image": "images/third.png",
      "title": "Track your spending, set your\ngoals, and save effortlessly.",
      "description":
          "Lorem ipsum dolor sit amet,\nconsectetur adipiscing elit.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // MAIN PAGEVIEW
          PageView.builder(
            controller: _controller,
            itemCount: pages.length,
            onPageChanged: (index) {
              setState(() => currentPage = index);
            },
            itemBuilder: (context, index) {
              return buildPage(
                image: pages[index]["image"]!,
                title: pages[index]["title"]!,
                description: pages[index]["description"]!,
              );
            },
          ),

          // SKIP BUTTON
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => Launch()),
                );
              },
              child: const Text(
                "Skip",
                style: TextStyle(
                  color: Color.fromARGB(255, 18, 4, 86),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // DOTS + BUTTON
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // DOT INDICATOR
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: currentPage == index ? 16 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: currentPage == index
                            ? Color.fromARGB(255, 18, 4, 86)
                            : Colors.white54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // NEXT / GET STARTED BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (currentPage < pages.length - 1) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => Launch()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 18, 4, 86),
                      foregroundColor: const Color.fromARGB(255, 246, 246, 248),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      currentPage == pages.length - 1 ? "Get Started" : "Next",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // PAGE DESIGN
  Widget buildPage({
    required String image,
    required String title,
    required String description,
  }) {
    return Stack(
      children: [
        // BACKGROUND IMAGE
        Positioned.fill(
          child: IgnorePointer(child: Image.asset(image, fit: BoxFit.cover)),
        ),

        // GRADIENT OVERLAY
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [
                    // ignore: deprecated_member_use
                    Colors.blue.withOpacity(0.95),
                    // ignore: deprecated_member_use
                    Colors.blue.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // TEXT
        Positioned(
          left: 20,
          right: 20,
          bottom: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(
                  color: Color.fromARGB(179, 31, 24, 96),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
