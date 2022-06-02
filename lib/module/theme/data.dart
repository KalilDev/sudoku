import 'package:adt_annotation/adt_annotation.dart' show data, T, Tp, NoMixin;
import 'package:adt_annotation/adt_annotation.dart' as adt;
import 'package:app/module/base.dart';
import 'package:collection/collection.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:utils/utils.dart';
import 'package:flutter/material.dart';

part 'data.g.dart';

@data(
    #SudokuTheme,
    [],
    adt.Union({
      #SudokuMaterialYouTheme: {
        #themeMode: T(#ThemeMode),
      },
      #SudokuSeededTheme: {
        #name: T(#String),
        #brightness: T(#Brightness),
        #seed: T(#Color),
        #secondarySeed: T.n(#Color),
        #background: T.n(#Color),
      },
    }))
const Type _sudokuTheme = SudokuTheme;

SudokuSeededTheme _darkSeededTheme(
  String name,
  Color seed, {
  Color? secondarySeed,
  Color? background,
}) =>
    SudokuSeededTheme(
      name,
      Brightness.dark,
      seed,
      secondarySeed,
      background,
    );

SudokuSeededTheme _lightSeededTheme(
  String name,
  Color seed, {
  Color? secondarySeed,
  Color? background,
}) =>
    SudokuSeededTheme(
      name,
      Brightness.light,
      seed,
      secondarySeed,
      background,
    );

final defaultSudokuThemes = [
  const SudokuMaterialYouTheme(ThemeMode.system),
  const SudokuMaterialYouTheme(ThemeMode.light),
  const SudokuMaterialYouTheme(ThemeMode.dark),
  _darkSeededTheme('dark_green', Colors.green),
  _darkSeededTheme(
    'black_green',
    Colors.green[500]!,
    background: const Color(0xFF0A0A0A),
  ),
  _lightSeededTheme(
    'material_light',
    Colors.teal,
    secondarySeed: Colors.blue,
  ),
  _darkSeededTheme(
    'material_dark',
    Colors.teal,
    secondarySeed: Colors.deepPurple,
  ),
  _lightSeededTheme(
    'seaside_light',
    Colors.indigo,
    secondarySeed: Colors.deepPurple,
    background: const Color(0xffdfe2f0),
  ),
  _darkSeededTheme(
    'seaside_dark',
    Colors.indigo,
    secondarySeed: Colors.deepPurple,
    background: const Color(0xff25262d),
  ),
  _lightSeededTheme(
    'desert_light',
    const Color(0xffc0b15c),
    secondarySeed: const Color(0xffc07f5c),
  ),
  _darkSeededTheme(
    'desert_dark',
    const Color(0xfff8f2a4),
    secondarySeed: const Color(0xfff8c8a4),
  ),
  _lightSeededTheme('pixel_blue', Colors.blue),
];
