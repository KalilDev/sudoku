import 'package:sudoku/presentation/preferences_bloc.dart';
import 'package:sudoku/presentation/sudoku_bloc/state.dart';
import 'package:sudoku/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Color getTextColorForBrightness(Brightness b) => b == Brightness.dark ? Colors.white.withOpacity(0.87) : Colors.black87;

Widget buildThemePreview(
    MapEntry<AvailableTheme, SudokuTheme> entry, BuildContext context, bool enabled) {
  final shape =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0));
  final theme = entry.value;
  final textColor = theme.brightness == Theme.of(context).brightness
      ? null
      : getTextColorForBrightness(theme.brightness);
  final text = entry.key.toString();
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
    child: Material(
        shadowColor: theme.mainDarkened,
        shape: shape,
        color: theme.background,
        elevation: enabled ? 4.0 : 0,
        child: Ink(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(color: enabled ? theme.main : theme.mainDarkened, width: 2.0)),
            child: ListTile(
                onTap: enabled ? () => BlocProvider.of<PreferencesBloc>(context).add(
                    PrefsEvent<AvailableTheme>(
                        entry.key, PrefsEventType.themeUpdate)) : null,
                title: Builder(
                  builder: (BuildContext context) => Text(
                    text,
                    style: DefaultTextStyle.of(context)
                        .style
                        .copyWith(color: textColor),
                  ),
                )))),
  );
}

List<Widget> buildAnimations(AnimationOptions opts, BuildContext context) {
  // ignore: close_sinks
  final bloc = BlocProvider.of<PreferencesBloc>(context);
  Widget buildSingle(String name, bool enabled, ValueChanged<bool> onChange) {
    return ListTile(title: Text(name), trailing: Checkbox(value: enabled, onChanged: onChange, activeColor: Theme.of(context).colorScheme.secondary, checkColor: Theme.of(context).colorScheme.onPrimary,),onTap: ()=>onChange(!enabled),);
  }
  Widget buildSectionTitle(String name) => 
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(name),
    );
  void update(AnimationOptions newOpts) => bloc.add(PrefsEvent<AnimationOptions>(
          newOpts,
          PrefsEventType.animUpdate));
  return [
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(opts.speed.toString()),
    ),
    Slider(
      value: AnimationSpeed.values.indexOf(opts.speed).toDouble(),
      onChanged: (d) => update(opts.copyWith(speed: AnimationSpeed.values[d.round()])),
      max: AnimationSpeed.values.length - 1.0,
    ),
    buildSectionTitle("Seleção"),
    buildSingle("Tamanho", opts.selectSize, (b) =>update(opts.copyWith(selectSize: b))),
    buildSingle("Cor", opts.selectColor, (b) =>update(opts.copyWith(selectColor: b))),
    buildSectionTitle("Texto"),
    buildSingle("Posição", opts.textPosition, (b) =>update(opts.copyWith(textPosition: b))),
    buildSingle("Opacidade", opts.textOpacity, (b) =>update(opts.copyWith(textOpacity: b))),
    buildSingle("Tamanho", opts.textSize, (b) =>update(opts.copyWith(textSize: b))),
    buildSingle("Cor", opts.textColor, (b) =>update(opts.copyWith(textColor: b))),
  ];
}

void openPrefs(BuildContext context) {
  showModalBottomSheet(
      context: context,
      builder: (context) {
        return BlocBuilder<PreferencesBloc, PrefsState>(
          builder: (BuildContext context, PrefsState state) {
            final themes = [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Tema:",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              ...SudokuTheme.availableThemeMap.entries
                  .map((t) => buildThemePreview(t, context, t.value != state.theme))
            ];
            final opts = state.animationOptions;
            final animation = [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Animações:",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              ...buildAnimations(opts, context)
            ];
            return ListView(children: [...themes, ...animation]);
          },
        );
      });
}
