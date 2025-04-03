import 'package:flutter/material.dart';

OutlineInputBorder customBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(6),
    gapPadding: 5,
    borderSide: const BorderSide(
      width: 1,
      color: Color(0xff767676),
    ),
  );
}
