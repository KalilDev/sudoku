import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_presentation/sudoku_bloc.dart';

import '../sudoku_button.dart';

class SudokuNumbers extends StatelessWidget {
  final List<NumberInfo> state;
  final bool isPortrait;
  final bool enabled;

  const SudokuNumbers({Key key, @required this.state, @required this.isPortrait, @required this.enabled}) : super(key: key);

  static double buttonSize = 52;
  static final buttonConstraints = BoxConstraints(
    minWidth: 0,
    minHeight: 0,
    maxHeight: 2*buttonSize,
    maxWidth: 2*buttonSize,
  );

  Widget renderNumber(NumberInfo info, BuildContext context) {
    void onTap() {
      context.bloc<SudokuBloc>().add(NumberTap(info.number));
    }
    final textOrIcon = info.number == 0 ? Icon(Icons.clear) : Text(info.number.toString());
    final textStyle = Theme.of(context).textTheme.headline4;
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: SudokuButton(filled: info.isSelected, textStyle: textStyle, constraints: buttonConstraints, child: AspectRatio(aspectRatio: 1, child: Center(child: textOrIcon)), onPressed: enabled ? onTap : null, shapeBuilder: (c)=> CircleBorder(side: BorderSide(color: c)),),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      final crossAxis = isPortrait ? constraints.maxWidth : constraints.maxHeight;
      final mainAxisMax = isPortrait ? constraints.maxHeight : constraints.maxWidth;
      final numbersPerCrossAxis = max(crossAxis ~/ buttonSize, state.length ~/ 3);
      final crossAxisCount = (state.length / numbersPerCrossAxis).ceil();
      final mainAxisCount = (state.length / crossAxisCount).ceil();

      final zeroAtEnd = state.toList()..sort((a,b) => a.number == 0 ? 1 : 0);
      final toBeFitted = List<List<NumberInfo>>.generate(crossAxisCount, (_) => <NumberInfo>[]);
      for (var i = 0; i < state.length; i++) {
        final toBeFittedI = i == state.length - 1 ? toBeFitted.length -1 : i ~/ mainAxisCount;
        toBeFitted[toBeFittedI].add(zeroAtEnd[i]);
      }
      final children = toBeFitted.where((e) => e.isNotEmpty).map((list) {
        final children = list.map((e) => Expanded(child: renderNumber(e, context))).toList();
        if (!isPortrait) {
          return ConstrainedBox(constraints: BoxConstraints(maxWidth: mainAxisMax / crossAxisCount), child: Column(children: children));
        }
        return ConstrainedBox(constraints: BoxConstraints(maxHeight: mainAxisMax / crossAxisCount), child: Row(children: children));
      }).toList();

        if (!isPortrait) {
          return Row(mainAxisSize: MainAxisSize.min, children: children);
        }
        return Column(mainAxisSize: MainAxisSize.min, children: children);
    });
  }
}