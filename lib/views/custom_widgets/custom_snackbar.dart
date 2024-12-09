import 'package:flutter/material.dart';

class CustomSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Dismiss any existing snackbars
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF3C76AD),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      duration: duration,
      backgroundColor: Colors.white,
      elevation: 6,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: const Color(0xFF3C76AD),
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

// // Example usage:
// class ExampleScreen extends StatelessWidget {
//   const ExampleScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             CustomSnackbar.show(
//               context: context,
//               message: 'This is a custom snackbar message',
//             );
//           },
//           child: const Text('Show Snackbar'),
//         ),
//       ),
//     );
//   }
// }