import 'package:app/module/theme.dart';
import 'package:app/viewmodel/create_theme.dart';
import 'package:app/widget/adaptative_dialog.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:value_notifier/value_notifier.dart';
import 'dialog.dart';

Future<SudokuSeededTheme?> showCreateThemeDialog(BuildContext context) {
  final initialBrightness = context.theme.brightness;
  return showAdaptativeDialog(
    context,
    builder: (context, body) =>
        ControllerInjectorBuilder<CreateThemeController>(
      inherited: true,
      factory: (_) => ControllerBase.create(() => CreateThemeController(
            initialBrightness,
            context.colorScheme.primary,
          )),
      builder: (context, controller) =>
          CreateThemeDialog.builder(context, body),
    ),
    bodyBuilder: CreateThemeDialog.buildBody,
    saveBuilder: CreateThemeDialog.buildSave,
    titleBuilder: CreateThemeDialog.buildTitle,
  );
}

Future<SudokuSeededTheme?> showCreateThemeDialogWithInitial(
    BuildContext context, SudokuSeededTheme theme) {
  return showAdaptativeDialog(
    context,
    builder: (context, body) =>
        ControllerInjectorBuilder<CreateThemeController>(
      inherited: true,
      factory: (_) =>
          ControllerBase.create(() => CreateThemeController.withInitial(theme)),
      builder: (context, controller) =>
          CreateThemeDialog.builder(context, body),
    ),
    bodyBuilder: CreateThemeDialog.buildBody,
    saveBuilder: CreateThemeDialog.buildSave,
    titleBuilder: CreateThemeDialog.buildTitle,
  );
}
