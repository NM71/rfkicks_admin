import 'package:flutter/material.dart';

void navigateWithSlideTransition(BuildContext context, Widget page) {
  Navigator.of(context).push(
    _createSlideTransition(page),
  );
}

// Function to create a slide transition route
Route _createSlideTransition(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // Slide in from right
      const end = Offset.zero; // End at original position
      const curve = Curves.easeInOut;

      // Define the animation
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}
