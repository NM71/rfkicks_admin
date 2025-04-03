import 'package:flutter/material.dart';

class MyButtonOutlined extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final double? width;
  final double? height;

  const MyButtonOutlined({
    super.key,
    required this.text,
    required this.onTap,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
    this.borderColor = const Color(0xff3c76ad),
    this.borderWidth = 1.0,
    this.borderRadius = 6,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: padding,
        side: BorderSide(color: borderColor!, width: borderWidth!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius!),
        ),
        fixedSize:
            width != null && height != null ? Size(width!, height!) : null,
      ),
      child: Text(
        text,
        style: textStyle ?? const TextStyle(fontSize: 16),
      ),
    );
  }
}
