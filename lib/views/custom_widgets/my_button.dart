import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final double? borderRadius;
  final double? width;
  final double? height;

  const MyButton({
    super.key,
    required this.text,
    required this.onTap,
    this.backgroundColor = const Color(0xff3c76ad),
    this.textStyle,
    this.borderRadius = 6,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius!),
        ),
        child: Center(
          child: Text(
            text,
            style: textStyle ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
          ),
        ),
      ),
    );
  }
}
