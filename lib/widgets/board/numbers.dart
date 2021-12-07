import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:sudoku/theme.dart';
import 'package:sudoku_presentation/sudoku_bloc.dart';

import 'package:provider/provider.dart';

class SudokuNumbers extends StatelessWidget {
  final List<NumberInfo> state;
  final bool isPortrait;
  final bool disabled;

  const SudokuNumbers(
      {Key key,
      @required this.state,
      @required this.isPortrait,
      @required this.disabled})
      : super(key: key);

  static const double buttonSize = 52;
  static final buttonSytle = ButtonStyle(
      minimumSize: MaterialStateProperty.all(Size.zero),
      fixedSize: MaterialStateProperty.all(Size.infinite),
      maximumSize: MaterialStateProperty.all(Size.square(buttonSize * 2)),
      padding: MaterialStateProperty.all(EdgeInsets.zero),
      shape: MaterialStateProperty.all(CircleBorder()));

  Widget renderNumber(NumberInfo info, BuildContext context) {
    void onTap() {
      context.bloc<SudokuBloc>().add(NumberTap(info.number));
    }

    final textOrIcon = info.number == 0
        ? const Icon(Icons.clear)
        : Text(info.number.toString());
    final textStyle = context.textTheme.headlineSmall;
    final scheme = context.colorScheme;
    final style = buttonSytle
        .copyWith(
          textStyle: MaterialStateProperty.all(textStyle),
          side: MaterialStateProperty.resolveWith(
            (states) => BorderSide(
              color: states.contains(MaterialState.disabled)
                  ? scheme.outline.withOpacity(0.38)
                  : scheme.primary,
            ),
          ),
        )
        .merge(
          info.isSelected
              ? FilledButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  disabledColor: scheme.onSurface,
                  stateLayerOpacityTheme: context.stateOverlayOpacity,
                )
              : ButtonStyle(
                  foregroundColor: MD3DisablableColor(scheme.onSurface),
                ),
        );
    final child = AspectRatio(aspectRatio: 1, child: Center(child: textOrIcon));
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: TextButton(
        key: const ObjectKey(const Object()),
        onPressed: disabled ? null : onTap,
        style: style,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final crossAxis =
          isPortrait ? constraints.maxWidth : constraints.maxHeight;
      final mainAxisMax =
          isPortrait ? constraints.maxHeight : constraints.maxWidth;
      final numbersPerCrossAxis =
          max(crossAxis ~/ buttonSize, state.length ~/ 3);
      final crossAxisCount = (state.length / numbersPerCrossAxis).ceil();
      final mainAxisCount = (state.length / crossAxisCount).ceil();

      final zeroAtEnd = state.toList()..sort((a, b) => a.number == 0 ? 1 : 0);
      final toBeFitted = List<List<NumberInfo>>.generate(
          crossAxisCount, (_) => <NumberInfo>[]);
      for (var i = 0; i < state.length; i++) {
        final toBeFittedI =
            i == state.length - 1 ? toBeFitted.length - 1 : i ~/ mainAxisCount;
        toBeFitted[toBeFittedI].add(zeroAtEnd[i]);
      }
      final children = toBeFitted.where((e) => e.isNotEmpty).map((list) {
        final children =
            list.map((e) => Expanded(child: renderNumber(e, context))).toList();
        if (!isPortrait) {
          return ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: mainAxisMax / crossAxisCount),
              child: Column(children: children));
        }
        return ConstrainedBox(
            constraints:
                BoxConstraints(maxHeight: mainAxisMax / crossAxisCount),
            child: Row(children: children));
      }).toList();

      if (!isPortrait) {
        return Row(mainAxisSize: MainAxisSize.min, children: children);
      }
      return Column(mainAxisSize: MainAxisSize.min, children: children);
    });
  }
}
