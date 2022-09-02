import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalil_utils/utils.dart';

const COLOR_CHANNEL_NAME = "io.kalildev.github.sudoku/splash_colors";
const COLOR_CHANNEL_GET_COLORS_NAME = "get_colors";

const splashColorsMethodChannel = MethodChannel(COLOR_CHANNEL_NAME);
Future<Tuple2<Color, Color>?> getSplashColors() async {
  final colors = await splashColorsMethodChannel
      .invokeMapMethod<String, int>(COLOR_CHANNEL_GET_COLORS_NAME);
  if (colors == null || colors.isEmpty) {
    return null;
  }
  return Tuple2(
    Color(colors['ic_launcher_background']!),
    Color(colors['ic_launcher_foreground']!),
  );
}
