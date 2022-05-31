import 'package:app/module/base.dart';
import 'package:app/navigation/src/game_route/data.dart';
import 'package:app/sudoku_generation/sudoku_generation.dart';
import 'package:app/util/l10n.dart';
import 'package:app/view/home.dart';
import 'package:app/view/preferences_dialog.dart';
import 'package:app/view/sudoku_generation.dart';
import 'package:app/viewmodel/sudoku_board.dart';
import 'package:app/viewmodel/sudoku_generation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:value_notifier/value_notifier.dart';

class SudokuGenerationView extends StatefulWidget {
  const SudokuGenerationView({
    Key? key,
    required this.sideSqrt,
    required this.difficulty,
    required this.db,
  }) : super(key: key);
  final int sideSqrt;
  final SudokuDifficulty difficulty;
  final SudokuDb db;

  @override
  State<SudokuGenerationView> createState() => _SudokuGenerationViewState();
}

class _SudokuGenerationViewState extends State<SudokuGenerationView> {
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
      child: MD3AdaptativeScaffold(
        appBar: MD3SmallAppBar(
          title: Text(context.l10n.sudoku),
          actions: [
            PreferencesButton(),
          ],
        ),
        body: MD3ScaffoldBody.noMargin(
          child: ControllerInjectorBuilder<GenerationController>(
            factory: (context) => ControllerBase.create(
              () => GenerationController.generate(
                widget.sideSqrt,
                widget.difficulty,
              ),
            ),
            builder: (context, genController) => GenerationView(
              createBoardControllerFromGenerated:
                  (SolvedAndChallengeBoard boards) {
                print('create view controller');
                assert(sudokuController == null);
                sudokuController = ControllerBase.create(
                  () => SudokuController.fromInitialState(
                    widget.db,
                    stateFromSolvedAndChallenge(boards),
                  ),
                );
                return ControllerBase.create(
                  () => SudokuViewController(
                    sudokuController!,
                    boards.left.length,
                  ),
                );
              },
              controller: genController,
            ),
          ),
        ),
      ),
    );
  }
}
