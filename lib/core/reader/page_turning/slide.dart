/// slide
import 'dart:ui' show Canvas;
import 'package:flutter/material.dart' show CustomPainter, Size;

class Slide extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
