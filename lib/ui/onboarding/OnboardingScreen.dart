import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:to_do_local/ui/auth/LoginScreen.dart';

class OnboardingScreen extends StatelessWidget {
  final List<Slide> slides = [
    Slide(
      widgetTitle: RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          text: 'Welcome to Your\nTask Manager',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 26.0,
            height: 1.6,
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
              height: 1.6,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        description:
            'Effortlessly add tasks and events to keep your schedule organized and stress-free.',
        styleTitle: const TextStyle(
          color: Colors.blue,
          fontSize: 26.0,
          height: 1.6,
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
              height: 1.6,
              fontSize: 26.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        description:
            'Utilize our integrated calendar to manage your events, appointments, and deadlines seamlessly.',
        styleTitle: const TextStyle(
          color: Colors.blue,
          fontSize: 26.0,
          height: 1.6,
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
          fontSize: 26.0,
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

      // Skip button
      renderSkipBtn: renderSkipBtn(),
      skipButtonStyle: myButtonStyle(),

      // Next button
      renderNextBtn: renderNextBtn(),
      nextButtonStyle: myButtonStyle(),

      // Done button
      renderDoneBtn: renderDoneBtn(),
      doneButtonStyle: myButtonStyle(),

      backgroundColorAllSlides: Colors.white,
      colorActiveDot: Colors.blue,
      colorDot: Colors.lightBlueAccent,
      slides: slides,
      onDonePress: () {
        // Navigate to TodoListScreenWithBottomNav on Done press
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      },
      onSkipPress: () {
        // Navigate to TodoListScreenWithBottomNav on Skip press
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      },
      scrollPhysics: const PageScrollPhysics(),
      autoScroll: true,
      loopAutoScroll: true,
      curveScroll: Curves.bounceIn,
    );
  }

  Widget renderNextBtn() {
    return Icon(
      Icons.navigate_next,
      color: Colors.blue,
      size: 35.0,
    );
  }

  Widget renderDoneBtn() {
    return Icon(
      Icons.done,
      color: Colors.blue,
    );
  }

  Widget renderSkipBtn() {
    return Icon(
      Icons.skip_next,
      color: Colors.blue,
    );
  }

  ButtonStyle myButtonStyle() {
    return ButtonStyle(
      shape: MaterialStateProperty.all<OutlinedBorder>(const StadiumBorder()),
      backgroundColor:
          MaterialStateProperty.all<Color>(const Color(0xffb4d6ef)),
      overlayColor: MaterialStateProperty.all<Color>(const Color(0xffb4d6ef)),
    );
  }
}
