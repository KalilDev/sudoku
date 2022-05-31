import 'package:app/main.dart';
import 'package:app/module/theme.dart';
import 'package:app/util/l10n.dart';
import 'package:app/view/sudoku_board/layout.dart';
import 'package:app/viewmodel/preferences_dialog.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:value_notifier/value_notifier.dart';

import 'animation_fragment.dart';
import 'flutter_intents.dart';
import 'theme_fragment.dart';

class PreferencesDialog extends StatelessWidget {
  const PreferencesDialog({
    Key? key,
    required this.controller,
  }) : super(key: key);
  final ControllerHandle<PreferencesDialogController> controller;

  @override
  Widget build(BuildContext context) => Actions(
        actions: {
          PopCommitingPreferencesIntent:
              PoppedCommitingPreferencesAction(controller.unwrap),
          PopNotCommitingPreferencesIntent:
              PoppedNotCommitingPreferencesAction(),
        },
        child: Builder(
          builder: (context) => _theme(
            context,
            child: _layout(
              context,
              child: _PreferencesDialogBody(
                controller: controller,
              ),
            ),
          ),
        ),
      );

  Widget _layout(
    BuildContext context, {
    required Widget child,
  }) {
    final margin = context.sizeClass.minimumMargins;
    final saveButton = TextButton(
      onPressed: () => Actions.invoke(
        context,
        PopCommitingPreferencesIntent(),
      ),
      child: Text(context.l10n.save),
    );
    switch (context.sizeClass) {
      case MD3WindowSizeClass.compact:
        return MD3FullScreenDialog(
          action: saveButton,
          title: Text(context.l10n.settings),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: margin,
              vertical: margin / 2,
            ),
            child: child,
          ),
        );
      case MD3WindowSizeClass.medium:
      case MD3WindowSizeClass.expanded:
        return MD3BasicDialog(
          title: Text(context.l10n.settings),
          content: child,
          scrollable: true,
          actions: [
            TextButton(
              onPressed: () => Actions.invoke(
                context,
                PopNotCommitingPreferencesIntent(),
              ),
              child: Text(context.l10n.cancel),
            ),
            saveButton,
          ],
        );
    }
  }

  static ThemeMode _concreteThemeModeFromSudokuTheme(
    SudokuTheme sudokuTheme,
    Brightness platformBrightness,
  ) =>
      sudokuTheme.visit(
        sudokuMaterialYouTheme: (mu) {
          switch (mu.themeMode) {
            case ThemeMode.system:
              return platformBrightness == Brightness.light
                  ? ThemeMode.light
                  : ThemeMode.dark;
            case ThemeMode.light:
              return ThemeMode.light;
            case ThemeMode.dark:
              return ThemeMode.dark;
          }
        },
        sudokuSeededTheme: (seeded) {
          switch (seeded.brightness) {
            case Brightness.dark:
              return ThemeMode.dark;
            case Brightness.light:
              return ThemeMode.light;
          }
        },
      );

  Widget _theme(
    BuildContext context, {
    required Widget child,
  }) =>
      controller.unwrap.currentTheme
          .map(
            (theme) => MD3Themes(
              monetThemeForFallbackPalette: theme.visit(
                sudokuMaterialYouTheme: (_) => MonetTheme.baseline3p,
                sudokuSeededTheme: (seeded) => seededThemeToMonetTheme(seeded),
              ),
              usePlatformPalette: theme.visit(
                sudokuMaterialYouTheme: (_) => true,
                sudokuSeededTheme: (_) => false,
              ),
              builder: (context, light, dark) {
                final concreteThemeMode = _concreteThemeModeFromSudokuTheme(
                  theme,
                  mediaQuery(context).platformBrightness,
                );
                return AnimatedMonetColorSchemes<NoAppScheme, NoAppTheme>(
                  themeMode: concreteThemeMode,
                  child: AnimatedTheme(
                    data: concreteThemeMode == ThemeMode.light ? light : dark,
                    child: child,
                  ),
                );
              },
            ),
          )
          .build();
}

class PoppedCommitingPreferencesAction
    extends ContextAction<PopCommitingPreferencesIntent> {
  final PreferencesDialogController controller;

  PoppedCommitingPreferencesAction(this.controller);
  @override
  Object? invoke(PopCommitingPreferencesIntent intent,
      [BuildContext? context]) {
    Navigator.of(context!)
        .pop<PreferencesDialogResult>(controller.buildResult());
  }
}

class PoppedNotCommitingPreferencesAction
    extends ContextAction<PopNotCommitingPreferencesIntent> {
  @override
  Object? invoke(PopNotCommitingPreferencesIntent intent,
      [BuildContext? context]) {
    Navigator.of(context!).pop<PreferencesDialogResult>();
  }
}

class _PreferencesDialogBody extends StatelessWidget {
  const _PreferencesDialogBody({
    Key? key,
    required this.controller,
  }) : super(key: key);
  final ControllerHandle<PreferencesDialogController> controller;

  @override
  Widget build(BuildContext context) {
    final margin = context.sizeClass.minimumMargins;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PreferencesDialogThemeFragment(controller: controller.unwrap.theme),
        SizedBox(height: margin),
        PreferencesDialogAnimationFragment(
            controller: controller.unwrap.animation),
      ],
    );
  }
}
