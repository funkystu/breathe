import 'dart:math';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

//A circle has a radius and a color.
class Circle {
  Circle(this.radius, this.color);

  factory Circle.empty() => Circle(0.0, Colors.transparent);

  factory Circle.random(Random random) {
    return Circle(
        random.nextDouble() * 100, ColorPalette.primary.random(random));
  }

  factory Circle.smallest() {
    return Circle(20.0, ColorPalette.primary[0]);
  }

  factory Circle.largest() {
    return Circle(155.0, ColorPalette.primary[1]);
  }

  final double radius;
  final Color color;

  static Circle lerp(Circle begin, Circle end, double t) {
    return Circle(
      lerpDouble(begin.radius, end.radius, t),
      Color.lerp(begin.color, end.color, t),
    );
  }
}

//Tween between two circles.
class CircleTween extends Tween<Circle> {
  CircleTween(Circle begin, Circle end) : super(begin: begin, end: end);

  @override
  Circle lerp(double t) => Circle.lerp(begin, end, t);
}

//paint the circle.
class CirclePainter extends CustomPainter {
  CirclePainter(Animation<Circle> animation)
      : animation = animation,
        super(repaint: animation);

  final Animation<Circle> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final circle = animation.value;
    final paint = Paint()
      ..color = circle.color
      ..style = PaintingStyle.fill;
    //center the circle...
    canvas.drawCircle(Offset(0.0,0.0), circle.radius, paint);
  }

  @override
  bool shouldRepaint(CirclePainter old) => false;
}

//cool looping color palette.
class ColorPalette {
  static final ColorPalette primary = new ColorPalette(<Color>[
    Colors.blue[400],
    Colors.red[400],
    Colors.green[400],
  ]);

  ColorPalette(List<Color> colors) : _colors = colors {
    assert(colors.isNotEmpty);
  }

  final List<Color> _colors;

  Color operator [](int index) => _colors[index % length];

  int get length => _colors.length;

  Color random(Random random) => this[random.nextInt(length)];
}

