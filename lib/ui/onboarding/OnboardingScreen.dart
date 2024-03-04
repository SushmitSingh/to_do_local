import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:to_do_local/ui/auth/PhoneOTPVerification.dart';

class OnboardingScreen extends StatelessWidget {
  final List<Slide> slides = [
    Slide(
      widgetTitle: RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          text: 'Welcome to Your\nTask Manager',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      description:
          'Your all-in-one solution for managing tasks, calendar events, and your profile effortlessly.',
      styleDescription: const TextStyle(
        color: Colors.blueGrey,
        fontSize: 18.0,
      ),
      pathImage: 'assets/boarding/1onboarding.png',
      heightImage: 300,
    ),
    Slide(
        widgetTitle: RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            text: 'Add Tasks With Ease',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        description:
            'Effortlessly add tasks and events to keep your schedule organized and stress-free.',
        styleTitle: const TextStyle(
          color: Colors.blue,
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
        styleDescription: const TextStyle(
          color: Colors.blueGrey,
          fontSize: 18.0,
        ),
        pathImage: 'assets/boarding/2onboarding.png',
        heightImage: 300 // Replace with your add image path
        ),
    Slide(
        widgetTitle: RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            text: 'Stay Organized \nWith The Calendar',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        description:
            'Utilize our integrated calendar to manage your events, appointments, and deadlines seamlessly.',
        styleTitle: const TextStyle(
          color: Colors.blue,
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
        styleDescription: const TextStyle(
          color: Colors.blueGrey,
          fontSize: 18.0,
        ),
        pathImage: 'assets/boarding/3onboarding.png',
        heightImage: 300),
    Slide(
        widgetTitle: RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            text: 'Manage Your Profile',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        description:
            'Create and customize your profile to personalize your task management experience.',
        styleTitle: const TextStyle(
          color: Colors.blue,
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
        styleDescription: const TextStyle(
          color: Colors.blueGrey,
          fontSize: 18.0,
        ),
        pathImage: 'assets/boarding/4onboarding.png',
        heightImage: 300 // Replace with your profile image path
        ),
  ];

  @override
  Widget build(BuildContext context) {
    return IntroSlider(
      key: UniqueKey(),
      backgroundColorAllSlides: Colors.white,
      colorActiveDot: Colors.blue,
      colorDot: Colors.lightBlueAccent,
      skipButtonStyle: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          // If the button is pressed, return green, otherwise blue
          if (states.contains(MaterialState.pressed)) {
            return Colors.green;
          }
          return Colors.blue;
        }),
        textStyle: MaterialStateProperty.resolveWith((states) {
          return const TextStyle(color: Colors.white);
        }),
      ),
      slides: slides,
      onDonePress: () {
        // Navigate to TodoListScreenWithBottomNav on Done press
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PhoneOTPVerification(),
          ),
        );
      },
      onSkipPress: () {
        // Navigate to TodoListScreenWithBottomNav on Skip press
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PhoneOTPVerification(),
          ),
        );
      },
      scrollPhysics: const BouncingScrollPhysics(),
      autoScroll: true,
      loopAutoScroll: true,
      curveScroll: Curves.bounceIn,
    );
  }
}
