import 'package:app/module/theme.dart';
import 'package:app/viewmodel/create_theme.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:value_notifier/value_notifier.dart';
import 'dialog.dart';

Future<SudokuSeededTheme?> showCreateThemeDialog(BuildContext context) {
  final initialBrightness = context.theme.brightness;
  return showDialog(
    context: context,
    builder: (context) => ControllerInjectorBuilder<CreateThemeController>(
      factory: (_) => ControllerBase.create(() => CreateThemeController(
            initialBrightness,
            context.colorScheme.primary,
          )),
      builder: (context, controller) => CreateThemeDialog(
        controller: controller,
      ),
    ),
  );
}
