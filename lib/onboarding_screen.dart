import 'package:flutter/material.dart';
import 'package:neskart/bottom_nav.dart';
import 'package:neskart/home_page.dart';
import 'package:neskart/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'asset/drag.jpg', // Add your image in assets
      'title': 'Welcome to NesCart',
      'desc': 'Discover the best deals and offers from top brands.',
    },
    {
      'image': 'asset/drag.jpg',
      'title': 'Fast Delivery',
      'desc': 'Get your products delivered to your door in no time.',
    },
    {
      'image': 'asset/drag.jpg',
      'title': 'Easy Payments',
      'desc': 'Multiple payment options for a smooth checkout.',
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(

        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: onboardingData.length,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final item = onboardingData[index];
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(item['image']!, height: 250),
                      const SizedBox(height: 40),
                      Text(
                        item['title']!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        item['desc']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(onboardingData.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: currentPage == index ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: currentPage == index ? Colors.black : Colors.grey,
                  borderRadius: BorderRadius.circular(35),
                ),
              );
            }),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ElevatedButton(
              onPressed: () async{
                SharedPreferences pref =  await SharedPreferences.getInstance();
                if (currentPage == onboardingData.length - 1) {
                  pref.setBool("onboarding_done", true);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                } else {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(currentPage == onboardingData.length - 1
                  ? "Get Started"
                  : "Next",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16
              ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}


