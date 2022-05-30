import 'package:app/main.dart';
import 'package:app/module/theme.dart';
import 'package:app/view/sudoku_board/layout.dart';
import 'package:app/viewmodel/preferences_dialog.dart';
import 'package:app/widget/grid_widget.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:utils/utils.dart';
import 'package:value_notifier/value_notifier.dart';

class PreferencesDialogThemeFragment
    extends ControllerWidget<PreferencesDialogThemeController> {
  PreferencesDialogThemeFragment({
    Key? key,
    required ControllerHandle<PreferencesDialogThemeController> controller,
  }) : super(
          key: key,
          controller: controller,
        );

  static MonetColorScheme colorSchemeFromSudokuTheme(
          BuildContext context, SudokuTheme theme) =>
      theme.visit(
        sudokuMaterialYouTheme: (mu) {
          final palette = context.palette;
          MonetTheme monetTheme;
          switch (palette.source) {
            case PaletteSource.platform:
              monetTheme = monetThemeFromPalette(palette);
              break;
            case PaletteSource.fallback:
            case PaletteSource.errorHandler:
              monetTheme = MonetTheme.baseline3p;
              break;
          }
          final brightness = mu.themeMode == ThemeMode.system
              ? mediaQuery(context).platformBrightness
              : mu.themeMode == ThemeMode.dark
                  ? Brightness.dark
                  : Brightness.light;
          switch (brightness) {
            case Brightness.dark:
              return monetTheme.dark;
            case Brightness.light:
              return monetTheme.light;
          }
        },
        sudokuSeededTheme: (seeded) {
          final monetTheme = seededThemeToMonetTheme(seeded);
          switch (seeded.brightness) {
            case Brightness.dark:
              return monetTheme.dark;
            case Brightness.light:
              return monetTheme.light;
          }
        },
      );

  Widget _buildDefaultTheme(
          BuildContext context, SudokuTheme defaultTheme, int i) =>
      controller.currentTheme
          .map((curr) => curr == defaultTheme)
          .unique()
          .map((isElevated) => _ThemeCard(
                onPressed: () => controller.changeCurrentIndex(i),
                colorScheme: colorSchemeFromSudokuTheme(context, defaultTheme),
                isElevated: isElevated,
                child: Text(
                  defaultTheme.visit(
                      sudokuMaterialYouTheme: (mu) {
                        switch (mu.themeMode) {
                          case ThemeMode.system:
                            return 'Material You Automático';
                          case ThemeMode.light:
                            return 'Material You Claro';
                          case ThemeMode.dark:
                            return 'Material You Escuro';
                        }
                      },
                      sudokuSeededTheme: (seeded) => seeded.name),
                ),
              ))
          .build();
  Widget _buildUserTheme(
          BuildContext context, SudokuSeededTheme userTheme, int i) =>
      controller.currentTheme
          .map((curr) => curr == userTheme)
          .unique()
          .map(
            (isElevated) => _ThemeCard(
              onPressed: () {},
              isElevated: isElevated,
              colorScheme: colorSchemeFromSudokuTheme(context, userTheme),
              child: Text(userTheme.name),
            ),
          )
          .build();
  Widget _buildAddTheme(BuildContext context) =>
      _AddThemeButton(onPressed: () {});

  @override
  Widget build(ControllerContext<PreferencesDialogThemeController> context) {
    final hasUserThemes =
        context.use(controller.userThemes.map((e) => e.isNotEmpty));
    final userThemes = context.use(controller.userThemes);
    final gridSpacing = context.sizeClass.minimumMargins / 2;
    const themeCols = 2;
    final defaultThemesW = GridWidget.linearC(
      layoutMode: GridLayoutMode.intrinsicWidth,
      verticalSpace: gridSpacing,
      horizontalSpace: gridSpacing,
      cols: 2,
      count: controller.defaultThemes.length,
      buildChild: (c, i) =>
          _buildDefaultTheme(c, controller.defaultThemes[i], i),
    );
    final userThemesW = userThemes
        .map((themes) => GridWidget.linearC(
              layoutMode: GridLayoutMode.intrinsicWidth,
              verticalSpace: gridSpacing,
              horizontalSpace: gridSpacing,
              cols: 2,
              count: themes.length,
              buildChild: (c, i) => _buildUserTheme(c, themes[i], i),
            ))
        .build();
    final addThemeW = _buildAddTheme(context);
    final margin = context.sizeClass.minimumMargins;
    final gutter = margin / 2;
    final marginW = SizedBox.square(
      dimension: margin,
    );
    final gutterW = SizedBox.square(
      dimension: gutter,
    );
    final maybeUserThemesGutterW = hasUserThemes
        .map((hasUserThemes) => hasUserThemes ? gutterW : SizedBox())
        .build();
    final sectionTitle = context.textTheme.titleLarge;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Temas', style: sectionTitle),
        gutterW,
        defaultThemesW,
        maybeUserThemesGutterW,
        userThemesW,
        gutterW,
        addThemeW,
      ],
    );
  }
}

class _AddThemeButton extends StatefulWidget {
  const _AddThemeButton({Key? key, required this.onPressed}) : super(key: key);
  final VoidCallback onPressed;

  @override
  State<_AddThemeButton> createState() => __AddThemeButtonState();
}

class __AddThemeButtonState extends State<_AddThemeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _hsvController;

  // An animation that goes from 0 to 360
  late Animation<double> _hsvAngleAnimation;

  static const _hsvDuration = Duration(milliseconds: 3600);

  @override
  void initState() {
    super.initState();
    _hsvController = AnimationController(vsync: this, duration: _hsvDuration)
      ..repeat();
    _hsvAngleAnimation = Tween(begin: 0.0, end: 360.0).animate(_hsvController);
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentBrightness = context.theme.brightness;
    late Tween<double> brightnessTween;
    switch (currentBrightness) {
      case Brightness.dark:
        brightnessTween = Tween(begin: 1.0, end: 0.0);
        break;
      case Brightness.light:
        brightnessTween = Tween(begin: 0.0, end: 1.0);
        break;
    }
  }

  @override
  void dispose() {
    _hsvController.dispose();
    super.dispose();
  }

  // Store the light and dark schemes for an theme generated with an hsv color
  // with hue [angle].
  static Tuple2<MonetColorScheme, MonetColorScheme> _generateForAngle(
      double angle) {
    final theme = generateTheme(
      HSVColor.fromAHSV(1, angle, 0.6, 0.6).toColor(),
    );
    return Tuple2(theme.light, theme.dark);
  }

  static const _kCacheAngleResolution = 30;
  // Cache the hsv generated monet themes to an resolution of
  // [_kCacheAngleResolution]
  static final List<Tuple2<MonetColorScheme, MonetColorScheme>?>
      _schemeFromAngleCache = List.filled(360 ~/ _kCacheAngleResolution, null);

  // Find the closest 2 cached themes, get the corresponding brightness, and
  // interpolate between them.
  static MonetColorScheme _schemeFromAngleCaching(double hsvAngle, bool dark) {
    final prevI = hsvAngle ~/ _kCacheAngleResolution;
    final prev = _schemeFromAngleCache[prevI] ??=
        _generateForAngle(prevI * _kCacheAngleResolution.toDouble());
    final prevWithBrightness = dark ? prev.e1 : prev.e0;
    final nextI = prevI + 1 >= 360 ~/ _kCacheAngleResolution ? 0 : prevI + 1;
    final next = _schemeFromAngleCache[nextI] ??=
        _generateForAngle(nextI * _kCacheAngleResolution.toDouble());
    final nextWithBrightness = dark ? next.e1 : next.e0;
    final dtA = hsvAngle - (prevI * _kCacheAngleResolution);
    final t = dtA / _kCacheAngleResolution;
    return MonetColorScheme.lerp(prevWithBrightness, nextWithBrightness, t);
  }

  Widget _build(
    BuildContext context,
    double hsvAngle,
  ) {
    final colorScheme = _schemeFromAngleCaching(hsvAngle, context.isDark);
    return _ThemeCard(
        onPressed: widget.onPressed,
        colorScheme: colorScheme,
        isElevated: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text('Criar Novo'),
            SizedBox(
              width: 12.0,
            ),
            Icon(Icons.add),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) =>
      (_build.curry(context).asValueListenable >> _hsvAngleAnimation).build();
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    Key? key,
    required this.onPressed,
    required this.colorScheme,
    required this.isElevated,
    required this.child,
  }) : super(key: key);
  final VoidCallback onPressed;
  final MonetColorScheme colorScheme;
  final bool isElevated;
  final Widget child;

  static const _kCardHeight = 96.0;

  @override
  Widget build(BuildContext context) {
    final color = CustomColorScheme(
      color: colorScheme.primary,
      onColor: colorScheme.onPrimary,
      colorContainer: colorScheme.background,
      onColorContainer: colorScheme.primary,
    );
    return SizedBox(
      height: _kCardHeight,
      child: ColoredCard(
        onPressed: onPressed,
        style: CardStyle(
            padding: MaterialStateProperty.all(
              EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 16.0,
              ),
            ),
            side: MaterialStateProperty.all(
              BorderSide(
                color: color.color,
                width: 2,
              ),
            ),
            elevation: MD3MaterialStateElevation(
              isElevated ? context.elevation.level2 : context.elevation.level0,
              isElevated ? context.elevation.level3 : context.elevation.level1,
              pressed: isElevated
                  ? context.elevation.level4
                  : context.elevation.level2,
            )),
        color: color,
        child: child,
      ),
    );
  }
}
