import 'package:sudoku/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku/widgets/sudoku_button.dart';

import 'package:sudoku_presentation/common.dart';
import 'package:sudoku_presentation/preferences_bloc.dart';

Color getTextColorForBrightness(Brightness b) =>
    b == Brightness.dark ? Colors.white.withOpacity(0.87) : Colors.black87;

String themeToString(AvailableTheme theme) {
  switch (theme) {
    case AvailableTheme.darkGreen:
      return "Verde escuro";
    case AvailableTheme.blackGreen:
      return "Preto e verde";
    case AvailableTheme.materialLight:
      return "Material Design";
    case AvailableTheme.materialDark:
      return "Material Design escuro";
    case AvailableTheme.seasideLight:
      return "Seaside";
    case AvailableTheme.seasideDark:
      return "Seaside escuro";
    case AvailableTheme.desertLight:
      return "Deserto";
    case AvailableTheme.desertDark:
      return "Deserto escuro";
    case AvailableTheme.pixelBlue:
      return "Azul Pixel";
    default:
      return 'Desconhecido';
  }
}

String speedToString(AnimationSpeed speed) {
  switch (speed) {
    case AnimationSpeed.none:
      return 'Desativada';
    case AnimationSpeed.normal:
      return 'Lenta';
    case AnimationSpeed.fast:
      return 'Normal';
    case AnimationSpeed.fastest:
      return 'Rápida';
    default:
      return 'Desconhecido';
  }
}

Widget buildSingleThemePreview(MapEntry<AvailableTheme, SudokuTheme> entry,
    BuildContext context, bool enabled) {
  final rawTheme = entry.value;
  final theme =
      rawTheme.copyWith(main: rawTheme.background, mainDarkened: rawTheme.main);
  const expand =
      BoxConstraints.expand(width: double.infinity, height: double.infinity);
  final shape = RoundedRectangleBorder(
      side: BorderSide(
          color: enabled ? rawTheme.main : rawTheme.mainDarkened, width: 2.0),
      borderRadius: BorderRadius.circular(4.0));
  final text = themeToString(entry.key);
  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: SudokuButton(
        elevation: 2.0,
        shapeBuilder: (_) => shape,
        theme: theme,
        filled: true,
        useSecondary: false,
        onPressed: enabled
            ? () => BlocProvider.of<PreferencesBloc>(context).add(
                PrefsEvent<AvailableTheme>(
                    entry.key, PrefsEventType.themeUpdate))
            : null,
        constraints: expand,
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ));
}

Widget buildSectionTitle(String title, BuildContext context) => Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headline5,
      ),
    );

List<Widget> buildThemes(BuildContext context, AvailableTheme currentTheme) {
  final themes = SudokuTheme.availableThemeMap.entries
      .map((t) => buildSingleThemePreview(t, context, t.key != currentTheme))
      .toList();
  return [
    SliverToBoxAdapter(child: buildSectionTitle("Temas:", context)),
    SliverGrid(
        delegate: SliverChildListDelegate(themes),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200, childAspectRatio: 1.8))
  ];
}

List<Widget> buildAnimations(AnimationOptions opts, BuildContext context) {
  // ignore: close_sinks
  final bloc = BlocProvider.of<PreferencesBloc>(context);
  Widget buildSubSectionTitle(String name) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(name),
      );
  final checksEnabled = opts.speed != AnimationSpeed.none;
  final sliderEnabled = opts.hasAnimations || opts.speed == AnimationSpeed.none;
  final speed = !opts.hasAnimations ? AnimationSpeed.none : opts.speed;
  Widget buildSingle(String name, bool enabled, ValueChanged<bool> onChange) {
    return CheckboxListTile(
        value: enabled,
        onChanged: checksEnabled ? onChange : null,
        title: Text(name),
        activeColor: Theme.of(context).colorScheme.secondary,
        checkColor: Theme.of(context).colorScheme.onPrimary);
  }

  void update(AnimationOptions newOpts) => bloc
      .add(PrefsEvent<AnimationOptions>(newOpts, PrefsEventType.animUpdate));
  return [
    SliverToBoxAdapter(child: buildSectionTitle("Animações:", context)),
    SliverList(
        delegate: SliverChildListDelegate([
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Velocidade: ' + speedToString(speed)),
      ),
      Slider(
        value: AnimationSpeed.values.indexOf(opts.speed).toDouble(),
        onChanged: sliderEnabled
            ? (d) =>
                update(opts.copyWith(speed: AnimationSpeed.values[d.round()]))
            : null,
        max: AnimationSpeed.values.length - 1.0,
      ),
      buildSubSectionTitle("Seleção"),
      buildSingle("Tamanho", opts.selectSize,
          (b) => update(opts.copyWith(selectSize: b))),
      buildSingle("Cor", opts.selectColor,
          (b) => update(opts.copyWith(selectColor: b))),
      buildSubSectionTitle("Texto"),
      buildSingle("Posição", opts.textPosition,
          (b) => update(opts.copyWith(textPosition: b))),
      buildSingle("Opacidade", opts.textOpacity,
          (b) => update(opts.copyWith(textOpacity: b))),
      buildSingle(
          "Tamanho", opts.textSize, (b) => update(opts.copyWith(textSize: b))),
      buildSingle(
          "Cor", opts.textColor, (b) => update(opts.copyWith(textColor: b))),
    ]))
  ];
}

void openPrefs(BuildContext context) {
  showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return BlocBuilder<PreferencesBloc, PrefsState>(
          builder: (BuildContext context, PrefsState _state) {
            if (_state is LoadingPrefsState) {
              return const Center(child: CircularProgressIndicator());
            }
            final state = _state as PrefsSnap;
            final opts = state.animationOptions;
            final slivers = [
              ...buildThemes(context, state.theme),
              ...buildAnimations(opts, context)
            ];
            const widthConstraints = BoxConstraints(maxWidth: 900);
            return Center(
                child: ConstrainedBox(
                    constraints: widthConstraints,
                    child: CustomScrollView(slivers: slivers)));
          },
        );
      });
}
