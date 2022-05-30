import 'dart:async';

import 'package:app/module/animation.dart';
import 'package:app/module/base.dart';
import 'package:app/module/theme.dart';
import 'package:app/view/home.dart';
import 'package:app/view/preferences_dialog.dart';
import 'package:app/viewmodel/home.dart';
import 'package:app/widget/animation_options.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:path_provider/path_provider.dart' as pp;
import 'package:value_notifier/value_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sudokuDbInitialize();
  sudokuHomeDbInitialize();
  sudokuUserThemesDbInitialize();
  sudokuAnimationDbInitialize();
  Hive.init(await pp.getTemporaryDirectory().then((d) => d.path));

  // We need to initialize the theme module and ensure it is ready before
  // running the app so that we do not flicker when the theme is loaded.
  final themeController =
      ControllerBase.create(() => SudokuThemeController.open());
  final themeControllerReadyCompleter = Completer();
  final untilThemeControllerIsReady = themeControllerReadyCompleter.future;
  // assumes that isReady is only true after it is true once
  themeController.isReady.unique().connect((isReady) {
    if (isReady) {
      themeControllerReadyCompleter.complete();
    }
  });
  await untilThemeControllerIsReady;
  // Now run the app with this theme controller and inject it into the tree.
  // Use injector because it disposes the controller later.
  final app = InheritedControllerInjector<SudokuThemeController>(
    factory: (_) => themeController,
    child: SudokuApp(controller: themeController.handle),
  );
  // Also inject an animation controller
  final appWithAnimation = ControllerInjectorBuilder<SudokuAnimationController>(
    factory: (_) =>
        ControllerBase.create(() => SudokuAnimationController.open()),
    inherited: true,
    builder: (_, animController) => animController.unwrap.animationOptions
        .map((opts) => InheritedAnimationOptions(
              animationOptions: opts,
              child: app,
            ))
        .build(),
  );

  runPlatformThemedApp(
    appWithAnimation,
    initialOrFallback: () =>
        PlatformPalette.fallback(primaryColor: Color(0xDEADBEEF)),
  );
}

MonetTheme seededThemeToMonetTheme(SudokuSeededTheme theme) {
  final monetTheme = generateTheme(
    theme.seed,
    secondarySeed: theme.secondarySeed,
  );
  if (theme.background == null) {
    return monetTheme;
  }
  switch (theme.brightness) {
    case Brightness.dark:
      return monetTheme.copyWith(
        dark: monetTheme.dark.copyWith(background: theme.background),
      );
    case Brightness.light:
      return monetTheme.copyWith(
        light: monetTheme.light.copyWith(background: theme.background),
      );
  }
}

class SudokuApp extends ControllerWidget<SudokuThemeController> {
  const SudokuApp({
    Key? key,
    required ControllerHandle<SudokuThemeController> controller,
  }) : super(
          key: key,
          controller: controller,
        );

  @override
  Widget build(ControllerContext<SudokuThemeController> context) {
    final activeTheme = context.use(controller.activeTheme);
    return activeTheme
        .map((theme) => theme.visit(
              sudokuMaterialYouTheme: (theme) => MD3Themes(
                monetThemeForFallbackPalette: MonetTheme.baseline3p,
                builder: (context, light, dark) => MaterialApp(
                  title: 'Sudoku',
                  theme: light,
                  darkTheme: dark,
                  themeMode: theme.themeMode,
                  home: const MyHomePage(),
                ),
              ),
              sudokuSeededTheme: (theme) => MD3Themes(
                usePlatformPalette: false,
                monetThemeForFallbackPalette: seededThemeToMonetTheme(theme),
                builder: (context, light, dark) => MaterialApp(
                  title: 'Sudoku',
                  theme: light,
                  darkTheme: dark,
                  themeMode: theme.brightness == Brightness.dark
                      ? ThemeMode.dark
                      : ThemeMode.light,
                  home: const MyHomePage(),
                ),
              ),
            ))
        .build();
  }
}

final homeController = ControllerBase.create(() => HomeViewController());

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MD3AdaptativeScaffold(
      appBar: MD3CenterAlignedAppBar(
        title: Text("Sudoku"),
        trailing: IconButton(
          onPressed: () => showPreferencesDialogAndUpdateModules(context),
          icon: Icon(Icons.settings_outlined),
        ),
      ),
      body: MD3ScaffoldBody.noMargin(
        child: HomeView(
          controller: homeController.handle,
        ),
      ),
    );
  }
}
