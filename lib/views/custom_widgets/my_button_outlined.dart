// import 'package:flutter/material.dart';
//
// class MyButtonOutlined extends StatelessWidget {
//   final String text;
//   final VoidCallback onTap;
//
//   const MyButtonOutlined({required this.text, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return OutlinedButton(
//       onPressed: onTap,
//       style: OutlinedButton.styleFrom(
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
//         side: const BorderSide(color: Color(0xff3c76ad)), // Outline color
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//       child: Text(
//         text,
//         style: const TextStyle(
//           // color: Color(0xff3c76ad),
//           fontSize: 14,
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';

class MyButtonOutlined extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final TextStyle? textStyle;

  const MyButtonOutlined({
    required this.text,
    required this.onTap,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
        side: const BorderSide(color: Color(0xff3c76ad)), // Outline color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Text(
        text,
        style: textStyle ?? const TextStyle(fontSize: 14), // Use provided style if available, otherwise default
      ),
    );
  }
}
