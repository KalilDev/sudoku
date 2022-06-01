import 'package:app/module/base.dart';
import 'package:app/sudoku_generation/sudoku_generation.dart';
import 'package:app/util/l10n.dart';
import 'package:app/view/preferences_dialog.dart';
import 'package:app/view/sudoku_board.dart';
import 'package:app/viewmodel/sudoku_board.dart';
import 'package:app/widget/memo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:value_notifier/value_notifier.dart';

import 'base_view.dart';
import 'data.dart';

class SudokuResumeView extends StatefulWidget {
  const SudokuResumeView({
    Key? key,
    required this.sideSqrt,
    required this.difficulty,
    required this.db,
  }) : super(key: key);
  final int sideSqrt;
  final SudokuDifficulty difficulty;
  final SudokuDb db;

  @override
  State<SudokuResumeView> createState() => _SudokuResumeViewState();
}

class _SudokuResumeViewState extends State<SudokuResumeView> {
  SudokuController? sudokuController;
  Future<bool> _willPop(BuildContext context) {
    WidgetsBinding.instance!.scheduleFrameCallback(
      (_) => Navigator.of(context).pop<GameRouteResult>(sudokuController),
    );
    return SynchronousFuture(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _willPop(context),
      child: BaseSudokuView(
        // Memo instead of ControllerInjectorBuilder because the route is
        // responsible for the lifecycle of the SudokuController
        child: Memo<SudokuViewController>(
          factory: () {
            print('create controller');
            assert(sudokuController == null);
            sudokuController = ControllerBase.create(
              () => SudokuController.fromStorage(widget.db),
            );
            print('create view controller');
            return ControllerBase.create(
              () => SudokuViewController(
                sudokuController!,
                widget.sideSqrt * widget.sideSqrt,
              ),
            );
          },
          builder: (context, controller) => SudokuView(
            controller: controller.handle,
          ),
        ),
      ),
    );
  }
}
