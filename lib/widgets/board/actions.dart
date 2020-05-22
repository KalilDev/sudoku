import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_presentation/sudoku_bloc.dart';
import '../sudoku_button.dart';

class SudokuActions extends StatelessWidget {
  final bool canRewind;
  final MarkType markType;
  final bool isPortrait;

  const SudokuActions({Key key, @required this.canRewind, @required this.markType, @required this.isPortrait})
      : super(key: key);

  static Map<IconData, Key> iconKeyMap = {};

  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    final bloc = context.bloc<SudokuBloc>();

    final buttonConstraints = BoxConstraints(
      minWidth: isPortrait ? 52.0 : 36.0,
      minHeight: !isPortrait ? 52.0 : 36.0,
      maxHeight: isPortrait ? 42.0 : 112.0,
      maxWidth: !isPortrait ? 42.0 : 112.0,
    );
    ShapeBorder shapeBuilder(Color c) => StadiumBorder(side: BorderSide(color: c));

    void resetBoard() => bloc.add(ActionReset());
    void validate() => bloc.add(ActionValidate());
    void changeMarkType() => bloc.add(ActionSetMark(
        markType == MarkType.concrete ? MarkType.possible : MarkType.concrete));
    void undo() => bloc.add(ActionUndo());
    Widget buildButton({IconData icon, VoidCallback onPressed, bool filled = false}) => SudokuButton(shapeBuilder: shapeBuilder, constraints: buttonConstraints, child: Icon(icon), filled: filled,onPressed: onPressed,);
    final children = [
      Spacer(),
      Expanded(flex: 3, child: buildButton(icon: Icons.sync, onPressed: resetBoard)),
      Spacer(),
      Expanded(flex: 3, child: buildButton(icon: Icons.check, onPressed: validate)),
      Spacer(),
      Expanded(
          flex: 3,
          child: buildButton(icon: Icons.edit, onPressed: changeMarkType,
              filled: markType == MarkType.possible)),
      Spacer(),
      Expanded(
          flex: 3,
          child: buildButton(icon: Icons.undo,  onPressed: canRewind ? undo : null)),
      Spacer(),
    ];
    return !isPortrait
        ? Column(
            children: children.reversed.toList(),
          )
        : Row(
            children: children,
          );
  }
}
