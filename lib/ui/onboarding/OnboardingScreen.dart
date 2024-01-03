import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';

import '../../main.dart';

class OnboardingScreen extends StatelessWidget {
  final List<Slide> slides = [
    Slide(
      title: 'Welcome to Your App',
      description: 'This is your onboarding description.',
      styleTitle: TextStyle(
        color: Colors.black,
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
      ),
      styleDescription: TextStyle(
        color: Colors.grey,
        fontSize: 18.0,
      ),
      pathImage: 'assets/onboarding_image_1.png', // Add your image path
    ),
    // Add more slides as needed
  ];

  @override
  Widget build(BuildContext context) {
    return IntroSlider(
      slides: slides,
      onDonePress: () {
        // Navigate to TodoListScreenWithBottomNav on Done press
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TodoListScreenWithBottomNav(),
          ),
        );
      },
      onSkipPress: () {
        // Navigate to TodoListScreenWithBottomNav on Skip press
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TodoListScreenWithBottomNav(),
          ),
        );
      },
    );
  }
}
