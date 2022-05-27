import 'package:app/util/monadic.dart';
import 'package:flutter/widgets.dart';

final ContextfulAction<bool> isLocked = readC.map(SudokuBoardIsLocked.of);

class SudokuBoardIsLocked extends InheritedWidget {
  final bool isLocked;

  const SudokuBoardIsLocked({
    Key? key,
    required this.isLocked,
    required Widget child,
  }) : super(
          key: key,
          child: child,
        );

  @override
  bool updateShouldNotify(SudokuBoardIsLocked oldWidget) =>
      oldWidget.isLocked != isLocked;

  static bool of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<SudokuBoardIsLocked>()!
      .isLocked;
}
