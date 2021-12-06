import 'package:material_widgets/material_widgets.dart';
import 'package:sudoku/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sudoku_presentation/models.dart';
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
    case AvailableTheme.monetLight:
      return 'Material You Claro';
    case AvailableTheme.monetDark:
      return 'Material You Escuro';
    case AvailableTheme.monetAuto:
      return 'Material You Automatico';
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

Widget buildSingleThemePreview(
  MapEntry<AvailableTheme, SudokuTheme> entry,
  BuildContext context,
  bool enabled,
) {
  final rawTheme = entry.value;
  final theme =
      rawTheme.copyWith(main: rawTheme.background, mainDarkened: rawTheme.main);
  final text = themeToString(entry.key);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
    child: ColoredCard(
      color: CustomColorScheme(
        color: theme.main,
        onColor: theme.main,
        colorContainer: theme.main.withOpacity(enabled ? 1.0 : 0.38),
        onColorContainer: rawTheme.main.withOpacity(enabled ? 1.0 : 0.38),
      ),
      style: CardStyle(
        side: MaterialStateProperty.resolveWith(
          (states) => BorderSide(
            color: rawTheme.main.withOpacity(enabled ? 1.0 : 0.6),
            width: 2.0,
          ),
        ),
      ),
      onPressed: enabled
          ? () => BlocProvider.of<PreferencesBloc>(context)
              .add(ThemeUpdatedEvent(entry.key))
          : null,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

Widget buildSectionTitle(String title, BuildContext context) => Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headline5,
      ),
    );

List<Widget> buildThemes(BuildContext context, AvailableTheme currentTheme) {
  final monetTheme = generateTheme(context.palette.primaryColor);
  final monetThemes = {
    AvailableTheme.monetAuto:
        MediaQuery.platformBrightnessOf(context) == Brightness.dark
            ? monetTheme.dark
            : monetTheme.light,
    AvailableTheme.monetLight: monetTheme.light,
    AvailableTheme.monetDark: monetTheme.dark,
  }.map((key, value) => MapEntry(key, sudokuThemeFromMonetScheme(value)));
  final themes = SudokuTheme.availableThemeMap.entries
      .followedBy(monetThemes.entries)
      .map((t) => buildSingleThemePreview(t, context, t.key != currentTheme))
      .toList();
  return [
    SliverToBoxAdapter(child: buildSectionTitle("Temas:", context)),
    SliverGrid(
      delegate: SliverChildListDelegate(themes),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 1.8,
      ),
    )
  ];
}

class MD3SwitchListTile extends StatelessWidget {
  const MD3SwitchListTile({
    Key key,
    this.onChanged,
    this.title,
    this.value,
  }) : super(key: key);

  final ValueChanged<bool> onChanged;
  final Widget title;
  final bool value;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title,
      onTap: () => onChanged(!value),
      trailing: MD3Switch(value: value, onChanged: onChanged),
    );
  }
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
    return MD3SwitchListTile(
      value: enabled,
      onChanged: checksEnabled ? onChange : null,
      title: Text(name),
    );
  }

  void update(AnimationOptions newOpts) =>
      bloc.add(AnimationOptionsUpdatedEvent(newOpts));
  return [
    SliverToBoxAdapter(child: buildSectionTitle("Animações:", context)),
    SliverList(
        delegate: SliverChildListDelegate([
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Velocidade: ' + speedToString(speed)),
      ),
      MD3Slider(
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
  final nav = Navigator.of(context);
  nav.push<void>(
    MaterialPageRoute(
      builder: (context) => MD3FullScreenDialog(
        action: Center(
          child: TextButton(
            child: Text('Salvar'),
            onPressed: () => nav.pop(),
          ),
        ),
        title: Text('Configurações'),
        body: BlocBuilder<PreferencesBloc, PrefsState>(
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
            return ConstrainedBox(
              constraints: widthConstraints,
              child: CustomScrollView(
                slivers: slivers,
                shrinkWrap: true,
              ),
            );
          },
        ),
      ),
    ),
  );
}
