import 'package:flutter/material.dart';

void main() {
  final List<Color> colors = [
    const Color(0xFF13BDEC),
    Colors.blueAccent,
    Colors.redAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.tealAccent,
    Colors.pinkAccent,
    Colors.amberAccent,
    Colors.indigoAccent,
  ];
  
  for (var color in colors) {
    print(color.value.toRadixString(16));
  }
}
