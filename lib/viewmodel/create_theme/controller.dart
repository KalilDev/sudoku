import 'package:app/module/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kalil_utils/utils.dart';
import 'package:value_notifier/value_notifier.dart';

class CreateThemeController extends ControllerBase<CreateThemeController> {
  final ValueNotifier<String> _name;
  final ValueNotifier<Brightness> _brightness;
  final ValueNotifier<Color> _seed;
  final ValueNotifier<Color?> _secondarySeed;
  final ValueNotifier<Color?> _background;

  CreateThemeController(
    Brightness initialBrightness,
    Color initialSeed,
  )   : _name = ValueNotifier(''),
        _brightness = ValueNotifier(initialBrightness),
        _seed = ValueNotifier(initialSeed),
        _secondarySeed = ValueNotifier(null),
        _background = ValueNotifier(null);
  CreateThemeController.withInitial(SudokuSeededTheme theme)
      : _name = ValueNotifier(theme.name),
        _brightness = ValueNotifier(theme.brightness),
        _seed = ValueNotifier(theme.seed),
        _secondarySeed = ValueNotifier(theme.secondarySeed),
        _background = ValueNotifier(theme.background);

  ValueListenable<String> get name => _name.view();
  ValueListenable<Brightness> get brightness => _brightness.view();
  ValueListenable<Color> get seed => _seed.view();
  ValueListenable<Color?> get secondarySeed => _secondarySeed.view();
  ValueListenable<Color?> get background => _background.view();

  ValueListenable<String?> get finalName =>
      name.map((name) => name.isEmpty ? null : name);

  // The name can be ommited.
  ValueListenable<SudokuSeededTheme> get overrideTheme =>
      SudokuSeededTheme.new.curry.asValueListenable >>
      name >>
      brightness >>
      seed >>
      secondarySeed >>
      background;

  // The  name cannot be ommited
  ValueListenable<SudokuSeededTheme?> get finalTheme =>
      finalName.bind((finalName) =>
          finalName == null ? null.asValueListenable : overrideTheme);

  // The name cannot be ommited
  ValueListenable<bool> get canSave =>
      finalTheme.map((finalTheme) => finalTheme != null);

  // TODO
  static const maxNameLength = 255;

  late final setName = _name.setter;
  late final setBrightness = _brightness.setter;
  late final setSeed = _seed.setter;
  late final setSecondarySeed = _secondarySeed.setter;
  late final setBackground = _background.setter;

  @override
  void init() {
    super.init();
  }

  @override
  void dispose() {
    IDisposable.disposeAll([
      _name,
      _brightness,
      _seed,
      _secondarySeed,
      _background,
    ]);
    super.dispose();
  }
}
