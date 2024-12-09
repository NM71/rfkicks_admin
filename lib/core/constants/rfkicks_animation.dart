import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class RfkicksAnimation extends StatefulWidget {
  final Widget targetScreen;

  const RfkicksAnimation({super.key, required this.targetScreen});

  @override
  _RfkicksAnimationState createState() => _RfkicksAnimationState();
}

class _RfkicksAnimationState extends State<RfkicksAnimation> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => widget.targetScreen),
      // );
      Navigator.pushReplacement(
          context,
          PageTransition(
              child: widget.targetScreen,
              type: PageTransitionType.rightToLeft));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Circular loading animation
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 1.0,
                ),
              ),
              // Image in the center of the loading animation
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  "assets/images/header2-2-1.png",
                  height: 80,
                  width: 80,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// // Example usage
// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Home Screen')),
//       body: Center(child: Text('Welcome to the Home Screen!')),
//     );
//   }
// }
//
// void main() {
//   runApp(
//     MaterialApp(
//       home: RfkicksAnimation(targetScreen: HomeScreen()),
//     ),
//   );
// }
