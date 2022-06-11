import 'package:app/module/theme.dart';
import 'package:app/util/l10n.dart';
import 'package:app/view/create_theme.dart';
import 'package:app/view/sudoku_board/layout.dart';
import 'package:app/viewmodel/preferences_dialog.dart';
import 'package:app/widget/grid_widget.dart';
import 'package:app/widget/theme_override.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:utils/utils.dart';
import 'package:value_notifier/value_notifier.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension on AppLocalizations {
  String defaultTheme(String name) {
    switch (name) {
      case 'dark_green':
        return themes_default_dark_green;
      case 'black_green':
        return themes_default_black_green;
      case 'material_light':
        return themes_default_material_light;
      case 'material_dark':
        return themes_default_material_dark;
      case 'seaside_light':
        return themes_default_seaside_light;
      case 'seaside_dark':
        return themes_default_seaside_dark;
      case 'desert_light':
        return themes_default_desert_light;
      case 'desert_dark':
        return themes_default_desert_dark;
      case 'pixel_blue':
        return themes_default_pixel_blue;
      default:
        return 'TODO: $name';
    }
  }
}

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
    BuildContext context,
    SudokuTheme defaultTheme,
    int i,
  ) =>
      controller.currentTheme
          .map((curr) => curr == defaultTheme)
          .unique()
          .map((isSelected) => _ThemeCard(
                onPressed:
                    isSelected ? null : () => controller.changeCurrentIndex(i),
                colorScheme: colorSchemeFromSudokuTheme(context, defaultTheme),
                isSelected: isSelected,
                child: Text(
                  defaultTheme.visit(
                    sudokuMaterialYouTheme: (mu) {
                      switch (mu.themeMode) {
                        case ThemeMode.system:
                          return context.l10n.themes_mu_system;
                        case ThemeMode.light:
                          return context.l10n.themes_mu_light;
                        case ThemeMode.dark:
                          return context.l10n.themes_mu_dark;
                      }
                    },
                    sudokuSeededTheme: (seeded) =>
                        context.l10n.defaultTheme(seeded.name),
                  ),
                ),
              ))
          .build();
  Widget _buildUserTheme(
    BuildContext context,
    SudokuSeededTheme userTheme,
    int i,
  ) =>
      controller.currentTheme
          .map((curr) => curr == userTheme)
          .unique()
          .map(
            (isSelected) => _ThemeCard(
              onPressed: isSelected
                  ? null
                  : () => controller
                      .changeCurrentIndex(i + controller.defaultThemes.length),
              isSelected: isSelected,
              colorScheme: colorSchemeFromSudokuTheme(context, userTheme),
              child: Text(userTheme.name),
              action: _UserThemeActionWidget(
                controller: controller,
                index: i,
                theme: userTheme,
              ),
            ),
          )
          .build();

  void _onAddTheme(BuildContext context) async {
    final result = await showCreateThemeDialog(context);
    if (result == null) {
      return;
    }
    controller.addUserTheme(result);
  }

  Widget _buildAddTheme(BuildContext context) =>
      _AddThemeButton(onPressed: () => _onAddTheme(context));

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
        Text(context.l10n.themes, style: sectionTitle),
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
        isSelected: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(context.l10n.themes_create_new),
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
    this.onPressed,
    required this.colorScheme,
    required this.isSelected,
    required this.child,
    this.action,
  }) : super(key: key);
  final VoidCallback? onPressed;
  final MonetColorScheme colorScheme;
  final Widget? action;
  final bool isSelected;
  final Widget child;

  static const _kCardHeight = 96.0;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;
    final color = CustomColorScheme(
      color: colorScheme.primary.withOpacity(isDisabled ? 0.6 : 1.0),
      onColor: colorScheme.onPrimary,
      colorContainer: isDisabled
          ? colorScheme.surfaceVariant.withOpacity(0.6)
          : colorScheme.background,
      onColorContainer: colorScheme.primary.withOpacity(isDisabled ? 0.6 : 1.0),
    );
    return SizedBox(
      height: _kCardHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: Semantics(
              selected: isSelected,
              enabled: !isDisabled,
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
                    context.elevation.level0,
                    context.elevation.level1,
                    pressed: context.elevation.level2,
                  ),
                ),
                color: color,
                child: Center(
                  child: DefaultTextStyle.merge(
                    style: context.textTheme.titleSmall,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
          if (action != null)
            Positioned(
              top: 0,
              right: 0,
              child: action!,
            )
        ],
      ),
    );
  }
}

enum _UserThemeAction {
  delete,
  modify,
}

class _UserThemeActionWidget extends StatelessWidget {
  const _UserThemeActionWidget({
    Key? key,
    required this.controller,
    required this.index,
    required this.theme,
  }) : super(key: key);

  final PreferencesDialogThemeController controller;
  final int index;
  final SudokuSeededTheme theme;

  void _onSelected(BuildContext context, _UserThemeAction action) async {
    switch (action) {
      case _UserThemeAction.delete:
        controller.removeUserTheme(index);
        break;
      case _UserThemeAction.modify:
        final newTheme = await showCreateThemeDialogWithInitial(context, theme);
        if (newTheme == null) {
          return;
        }
        controller.modifyUserTheme(index, newTheme);
        break;
    }
  }

  Color _color(BuildContext context) {
    final currentBrightness = context.theme.brightness;
    final backgroundBrightness = theme.background == null
        ? theme.brightness
        : ThemeData.estimateBrightnessForColor(theme.background!);
    if (currentBrightness == backgroundBrightness) {
      return context.colorScheme.onBackground;
    }
    return context.colorScheme.onInverseSurface;
  }

  @override
  Widget build(BuildContext context) => MD3PopupMenuButton<_UserThemeAction>(
        icon: Icon(
          Icons.more_vert,
          color: _color(context),
        ),
        onSelected: (action) =>
            action == null ? null : _onSelected(context, action),
        itemBuilder: (c) => [
          MD3PopupMenuItem(
            value: _UserThemeAction.delete,
            child: Text(context.l10n.theme_user_delete),
            trailing: Icon(Icons.delete_outlined),
          ),
          MD3PopupMenuItem(
            value: _UserThemeAction.modify,
            child: Text(context.l10n.theme_user_edit),
            trailing: Icon(Icons.edit),
          ),
        ],
      );
}
