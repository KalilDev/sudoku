import 'dart:html';

import 'package:flutter/material.dart';
import 'package:utils/utils.dart';

Color? parseHexColor(String color) {
  if (!color.startsWith('#')) {
    return null;
  }
  color = color.substring(1);
  if (color.length == 4) {
    color = '${color[0]}${color[0]}'
        '${color[1]}${color[1]}'
        '${color[2]}${color[2]}'
        '${color[3]}${color[3]}';
  } else if (color.length == 3) {
    color = '${color[0]}${color[0]}'
        '${color[1]}${color[1]}'
        '${color[2]}${color[2]}';
  } else if (color.length == 6) {
    color = 'FF$color';
  } else if (color.length != 8) {
    return null;
  }
  final a = color.substring(0, 2);
  final r = color.substring(2, 4);
  final g = color.substring(4, 6);
  final b = color.substring(6, 8);
  return Color.fromARGB(
    int.parse(a, radix: 16),
    int.parse(r, radix: 16),
    int.parse(g, radix: 16),
    int.parse(b, radix: 16),
  );
}

Future<Tuple2<Color, Color>?> getSplashColors() async {
  final style =
      document.body?.querySelector('.launch_colors')!.getComputedStyle();
  if (style == null) {
    return null;
  }
  final background = parseHexColor(style.backgroundColor);
  final foreground = parseHexColor(style.color);
  if (background == null || foreground == null) {
    return null;
  }
  return Tuple2(
    background,
    foreground,
  );
}
