import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:sudoku/theme.dart';
import 'package:sudoku_presentation/sudoku_bloc.dart';

import 'package:provider/provider.dart';

class SudokuActions extends StatelessWidget {
  final bool canRewind;
  final MarkType markType;
  final bool isPortrait;
  final bool disabled;

  const SudokuActions(
      {Key key,
      @required this.canRewind,
      @required this.markType,
      @required this.isPortrait,
      @required this.disabled})
      : super(key: key);

  static Map<IconData, Key> iconKeyMap = {};

  static final portraitButtonSize = ButtonStyle(
    minimumSize: MaterialStateProperty.all(Size(52, 36)),
    maximumSize: MaterialStateProperty.all(Size(112, 42)),
    fixedSize: MaterialStateProperty.all(Size.infinite),
  );

  static final landscapeButtonSize = ButtonStyle(
    minimumSize: MaterialStateProperty.all(Size(36, 52)),
    maximumSize: MaterialStateProperty.all(Size(42, 112)),
    fixedSize: MaterialStateProperty.all(Size.infinite),
  );

  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    final bloc = context.bloc<SudokuBloc>();

    final scheme = context.colorScheme;
    final buttonStyle = ButtonStyle(
      side: MaterialStateProperty.resolveWith(
        (states) => BorderSide(
          color: states.contains(MaterialState.disabled)
              ? scheme.outline.withOpacity(0.38)
              : scheme.primary,
        ),
      ),
      padding: MaterialStateProperty.all(EdgeInsets.zero),
    ).merge(isPortrait ? portraitButtonSize : landscapeButtonSize);

    void resetBoard() => bloc.add(ActionReset());
    void validate() {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Sudoku Validado!'),
        ),
      );
      bloc.add(ActionValidate());
    }

    void changeMarkType() => bloc.add(ActionSetMark(
        markType == MarkType.concrete ? MarkType.possible : MarkType.concrete));
    void undo() => bloc.add(ActionUndo());
    Widget buildButton({
      IconData icon,
      VoidCallback onPressed,
      bool filled = false,
    }) =>
        TextButton(
          onPressed: disabled ? null : onPressed,
          style: buttonStyle.merge(
            filled
                ? FilledTonalButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    disabledColor: scheme.onSurface,
                    stateLayerOpacityTheme: context.stateOverlayOpacity,
                  )
                : const ButtonStyle(),
          ),
          child: Icon(icon),
        );
    final children = [
      const Spacer(),
      Expanded(
          flex: 3, child: buildButton(icon: Icons.sync, onPressed: resetBoard)),
      const Spacer(),
      Expanded(
          flex: 3, child: buildButton(icon: Icons.check, onPressed: validate)),
      const Spacer(),
      Expanded(
          flex: 3,
          child: buildButton(
              icon: Icons.edit,
              onPressed: changeMarkType,
              filled: markType == MarkType.possible)),
      const Spacer(),
      Expanded(
          flex: 3,
          child: buildButton(
              icon: Icons.undo, onPressed: (canRewind ?? false) ? undo : null)),
      const Spacer(),
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
