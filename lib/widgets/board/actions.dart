import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku/theme.dart';
import 'package:sudoku_presentation/sudoku_bloc.dart';
import 'package:provider/provider.dart';

class SudokuActions extends StatelessWidget {
  final bool canRewind;
  final MarkType markType;
  final bool isPortrait;

  const SudokuActions({Key key, @required this.canRewind, @required this.markType, @required this.isPortrait})
      : super(key: key);

  Widget buildAction(IconData icon, VoidCallback? onTap, BuildContext context,
      {bool colored = false}) {
    final theme = Provider.of<SudokuTheme>(context);
    final isDisabled = onTap == null;
    final disabledColor = Theme.of(context).disabledColor;
    final decoration = BoxDecoration(
        border: Border.all(color: isDisabled ? disabledColor : theme.mainDarkened),
        borderRadius: BorderRadius.circular(48.0));
    final iconConstraints = BoxConstraints(
      minWidth: isPortrait ? 52.0 : 22.0,
      minHeight: !isPortrait ? 52.0 : 22.0,
      maxHeight: isPortrait ? 36.0 : 112.0,
      maxWidth: !isPortrait ? 36.0 : 112.0,
    );
    final aspectRatio = isPortrait ? 20/9 : 9/20;
    return Material(
      color: colored ? theme.secondary : null,
      shape: StadiumBorder(),
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: decoration,
          child: ConstrainedBox(
            constraints: iconConstraints,
              child: AspectRatio(
                aspectRatio: aspectRatio,
                  child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: FittedBox(
                    fit: BoxFit.contain,
                child: Icon(
                  icon,
                  color: isDisabled ? disabledColor : colored ? Theme.of(context).colorScheme.onPrimary : null,
                ),
            ),
                        ),
              ),
          ),
        ),
        customBorder: StadiumBorder(),
        highlightColor: colored ? theme.secondaryDarkened : theme.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    final bloc = context.bloc<SudokuBloc>();
    void resetBoard() => bloc.add(ActionReset());
    void validate() => bloc.add(ActionValidate());
    void changeMarkType() => bloc.add(ActionSetMark(
        markType == MarkType.concrete ? MarkType.possible : MarkType.concrete));
    void undo() => bloc.add(ActionUndo());
    final children = [
      Spacer(),
      Expanded(flex: 2, child: buildAction(Icons.sync, resetBoard, context)),
      Spacer(),
      Expanded(flex: 2, child: buildAction(Icons.check, validate, context)),
      Spacer(),
      Expanded(
          flex: 2,
          child: buildAction(Icons.edit, changeMarkType, context,
              colored: markType == MarkType.possible)),
      Spacer(),
      Expanded(
          flex: 2,
          child: buildAction(Icons.undo, canRewind ? undo : null, context)),
      Spacer(),
    ];
    return !isPortrait
        ? Column(
            children: children,
          )
        : Row(
            children: children,
          );
  }
}
