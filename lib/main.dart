import 'dart:async';
import 'dart:ui';

import 'package:app/module/animation.dart';
import 'package:app/module/base.dart';
import 'package:app/module/theme.dart';
import 'package:app/navigation/src/navigation.dart';
import 'package:app/view/home.dart';
import 'package:app/view/preferences_dialog.dart';
import 'package:app/viewmodel/home.dart';
import 'package:app/widget/animation_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:path_provider/path_provider.dart' as pp;
import 'package:value_notifier/value_notifier.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'widget/theme_override.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sudokuDbInitialize();
  sudokuHomeDbInitialize();
  sudokuUserThemesDbInitialize();
  sudokuAnimationDbInitialize();
  Hive.init(await pp.getApplicationSupportDirectory().then((d) => d.path));

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

class SudokuApp extends StatefulWidget {
  const SudokuApp({
    Key? key,
    required this.controller,
  }) : super(
          key: key,
        );
  final ControllerHandle<SudokuThemeController> controller;

  @override
  State<SudokuApp> createState() => _SudokuAppState();
}

class _SudokuAppState extends State<SudokuApp> with WidgetsBindingObserver {
  late Brightness platformBrightness;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    platformBrightness = window.platformBrightness;
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setState(() => platformBrightness = window.platformBrightness);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  static const _debugLocale = Locale('en');
  static const _locale = kDebugMode ? _debugLocale : null;
  static const _localizationsDelegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];
  static const _supportedLocales = AppLocalizations.supportedLocales;
  static String _onGenerateTitle(BuildContext context) =>
      AppLocalizations.of(context)!.sudoku;

  static Color _primaryContainerColor(
    MonetTheme theme,
    ThemeMode themeMode,
    Brightness platformBrightnes,
  ) {
    switch (themeMode) {
      case ThemeMode.system:
        switch (platformBrightnes) {
          case Brightness.dark:
            return theme.dark.primaryContainer;
          case Brightness.light:
            return theme.light.primaryContainer;
        }
      case ThemeMode.light:
        return theme.light.primaryContainer;
      case ThemeMode.dark:
        return theme.dark.primaryContainer;
    }
  }

  // uses platform brightness
  Color _color(BuildContext context, ThemeMode themeMode) =>
      _primaryContainerColor(
        context.monetTheme,
        themeMode,
        platformBrightness,
      );

  Widget Function(BuildContext context, Widget? home) _builder(
    ThemeMode themeMode,
  ) =>
      (context, home) => AnimatedMonetColorSchemes<NoAppScheme, NoAppTheme>(
            child: home!,
            themeMode: themeMode,
          );

  @override
  Widget build(BuildContext context) {
    final kDebugSemantics = false;
    return ControllerWidgetBuilder<SudokuThemeController>(
        controller: widget.controller,
        builder: (context, controller) {
          final activeTheme = context.use(controller.activeTheme);
          return activeTheme
              .map((theme) => theme.visit(
                    sudokuMaterialYouTheme: (theme) => MD3Themes(
                      monetThemeForFallbackPalette: MonetTheme.baseline3p,
                      builder: (context, light, dark) => MaterialApp(
                        theme: light,
                        darkTheme: dark,
                        themeMode: theme.themeMode,
                        onGenerateTitle: _onGenerateTitle,
                        onGenerateRoute: SudokuNavigation.onGenerateRoute,
                        locale: _locale,
                        localizationsDelegates: _localizationsDelegates,
                        supportedLocales: _supportedLocales,
                        color: _color(context, theme.themeMode),
                        builder: _builder(theme.themeMode),
                        home: SudokuNavigation.homeView,
                        showSemanticsDebugger: kDebugSemantics,
                      ),
                    ),
                    sudokuSeededTheme: (theme) {
                      final themeMode = theme.brightness == Brightness.dark
                          ? ThemeMode.dark
                          : ThemeMode.light;
                      return MD3Themes(
                        usePlatformPalette: false,
                        monetThemeForFallbackPalette:
                            seededThemeToMonetTheme(theme),
                        builder: (context, light, dark) => MaterialApp(
                          theme: light,
                          darkTheme: dark,
                          themeMode: themeMode,
                          onGenerateTitle: _onGenerateTitle,
                          onGenerateRoute: SudokuNavigation.onGenerateRoute,
                          locale: _locale,
                          localizationsDelegates: _localizationsDelegates,
                          supportedLocales: _supportedLocales,
                          color: _color(
                            context,
                            themeMode,
                          ),
                          builder: _builder(themeMode),
                          home: SudokuNavigation.homeView,
                          showSemanticsDebugger: kDebugSemantics,
                        ),
                      );
                    },
                  ))
              .build();
        });
  }
}
