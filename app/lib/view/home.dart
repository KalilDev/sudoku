library app.view.home;

import 'package:app/module/base.dart';
import 'package:app/sudoku_generation/sudoku_generation.dart';
import 'package:app/util/monadic.dart';
import 'package:app/view/preferences_dialog.dart';
import 'package:app/view/sudoku_board.dart';
import 'package:app/view/sudoku_generation.dart';
import 'package:app/viewmodel/home.dart';
import 'package:app/viewmodel/sudoku_board.dart';
import 'package:app/viewmodel/sudoku_generation.dart';
import 'package:app/widget/decoration.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:utils/utils.dart';
import 'package:value_notifier/value_notifier.dart';

final ContextfulAction<bool> isHomeLocked = readC.map(HomeViewIsLocked.of);

class HomeViewIsLocked extends InheritedWidget {
  const HomeViewIsLocked(
      {Key? key, required Widget child, required this.isLocked})
      : super(key: key, child: child);
  final bool isLocked;

  @override
  bool updateShouldNotify(HomeViewIsLocked oldWidget) =>
      isLocked != oldWidget.isLocked;
  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HomeViewIsLocked>()!.isLocked;
}

SudokuAppBoardState stateFromSolvedAndChallenge(
        SolvedAndChallengeBoard boards) =>
    (SudokuAppBoardStateBuilder(boards.left.length)
          ..fixedNumbers = boards.right
          ..solvedBoard = boards.left)
        .build();

final ContextfulAction<NavigatorState> navigator = readC.map(Navigator.of);

class HomeView extends ControllerWidget<HomeViewController> {
  const HomeView(
      {Key? key, required ControllerHandle<HomeViewController> controller})
      : super(
          key: key,
          controller: controller,
        );

  static final emptyActions = <Type, Action>{
    ChangeHomeViewDifficultyIntent: DoNothingAction(),
    ChangeHomeViewSideSqrtIntent: DoNothingAction(),
    SudokuHomeNewGameIntent: DoNothingAction(),
    SudokuHomeContinueGameIntent: DoNothingAction(),
  };

  @override
  Widget build(ControllerContext<HomeViewController> context) {
    final sideSqrt = context.use(controller.sideSqrt);
    final canResume = context.use(controller.canContinue);
    final difficulty = context.use(controller.difficulty);
    final isLocked = context.use(controller.isLocked);
    void requestNavigation(SudokuNavigationTarget target) async {
      // TODO
      //showSnackbar(SnackBar(content: Text(target.toString())))(context);
      SudokuController? sudokuController;
      final route = target.visit<Route>(
        left: (create) => MaterialPageRoute(builder: (context) {
          print('create controller');
          return MD3AdaptativeScaffold(
            appBar: MD3SmallAppBar(
              title: Text("Sudoku"),
              actions: [
                IconButton(
                  onPressed: () =>
                      showPreferencesDialogAndUpdateModules(context),
                  icon: Icon(Icons.settings_outlined),
                ),
              ],
            ),
            body: MD3ScaffoldBody.noMargin(
              child: ControllerInjectorBuilder<GenerationController>(
                factory: (context) => ControllerBase.create(() =>
                    GenerationController.generate(
                        create.sideSqrt, create.difficulty)),
                builder: (context, genController) => GenerationView(
                  createBoardControllerFromGenerated:
                      (SolvedAndChallengeBoard boards) {
                    print('create view controller');
                    sudokuController = ControllerBase.create(() =>
                        SudokuController.fromInitialState(
                            create.db, stateFromSolvedAndChallenge(boards)));
                    return ControllerBase.create(() => SudokuViewController(
                        sudokuController!, boards.left.length));
                  },
                  controller: genController,
                ),
              ),
            ),
          );
        }),
        right: (resume) => MaterialPageRoute(
          builder: (context) => MD3AdaptativeScaffold(
            appBar: MD3SmallAppBar(
              title: Text("Sudoku"),
              actions: [
                IconButton(
                  onPressed: () =>
                      showPreferencesDialogAndUpdateModules(context),
                  icon: Icon(Icons.settings_outlined),
                ),
              ],
            ),
            body: MD3ScaffoldBody.noMargin(
              child: ControllerInjectorBuilder<SudokuViewController>(
                factory: (context) {
                  print('create controller');
                  sudokuController = ControllerBase.create(
                      () => SudokuController.fromStorage(resume.db));
                  print('create view controller');
                  return ControllerBase.create(() => SudokuViewController(
                      sudokuController!, resume.sideSqrt * resume.sideSqrt));
                },
                builder: (context, controller) => SudokuView(
                  controller: controller,
                ),
              ),
            ),
          ),
        ),
      );
      await navigator(context).push(route);
      if (sudokuController != null) {
        controller
            .popTarget(SudokuNavigationPopInfo(target, sudokuController!));
        sudokuController!.dispose();
      }
    }

    context.useEventHandler(controller.didRequestNavigation, requestNavigation);
    final actions = <Type, Action>{
      ChangeHomeViewDifficultyIntent:
          HomeViewDifficultyChangedAction(controller),
      ChangeHomeViewSideSqrtIntent: HomeViewSideSqrtChangedAction(controller),
      SudokuHomeNewGameIntent: HomeViewSideNewGameAction(controller),
      SudokuHomeContinueGameIntent: HomeViewSideContinueGameAction(controller),
    };
    final child =
        (((int sideSqrt, bool canResume, SudokuDifficulty difficulty) =>
                    _HomeView(
                        sideSqrt: sideSqrt,
                        canResume: canResume,
                        difficulty: difficulty)).curry.asValueListenable >>
                sideSqrt >>
                canResume >>
                difficulty)
            .build();
    return isLocked
        .map((isLocked) => HomeViewIsLocked(
            isLocked: isLocked,
            child: Actions(
              actions: isLocked ? emptyActions : actions,
              child: child,
            )))
        .build();
  }
}

class ChangeHomeViewSideSqrtIntent extends Intent {
  final int sideSqrt;

  ChangeHomeViewSideSqrtIntent(this.sideSqrt);
}

class HomeViewSideSqrtChangedAction
    extends Action<ChangeHomeViewSideSqrtIntent> {
  final HomeViewController controller;

  HomeViewSideSqrtChangedAction(this.controller);

  @override
  Object? invoke(ChangeHomeViewSideSqrtIntent intent) {
    controller.changeSideSqrt(intent.sideSqrt);
  }
}

class ChangeHomeViewDifficultyIntent extends Intent {
  final SudokuDifficulty difficulty;

  ChangeHomeViewDifficultyIntent(this.difficulty);
}

class HomeViewDifficultyChangedAction
    extends Action<ChangeHomeViewDifficultyIntent> {
  final HomeViewController controller;

  HomeViewDifficultyChangedAction(this.controller);

  @override
  Object? invoke(ChangeHomeViewDifficultyIntent intent) {
    controller.changeDifficulty(intent.difficulty);
  }
}

class SudokuHomeContinueGameIntent extends Intent {}

class HomeViewSideContinueGameAction
    extends Action<SudokuHomeContinueGameIntent> {
  final HomeViewController controller;

  HomeViewSideContinueGameAction(this.controller);

  @override
  Object? invoke(SudokuHomeContinueGameIntent intent) {
    controller.continueA();
  }
}

class SudokuHomeNewGameIntent extends Intent {}

class HomeViewSideNewGameAction extends Action<SudokuHomeNewGameIntent> {
  final HomeViewController controller;

  HomeViewSideNewGameAction(this.controller);

  @override
  Object? invoke(SudokuHomeNewGameIntent intent) {
    controller.startNewGame();
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView({
    Key? key,
    required this.sideSqrt,
    required this.canResume,
    required this.difficulty,
  }) : super(key: key);
  final int sideSqrt;
  final bool canResume;
  final SudokuDifficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final margin = context.sizeClass.minimumMargins;
    final marginW = SizedBox.square(dimension: margin);
    final gutter = margin / 2;
    final gutterW = SizedBox.square(dimension: gutter);
    final isLocked = isHomeLocked(context);
    return Center(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SudokuBoardHeroDecoration(
              sideSqrt: sideSqrt,
              isHome: true,
            ),
            Padding(
              padding: InheritedMD3BodyMargin.of(context).padding +
                  EdgeInsets.only(bottom: gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Lado: ${sideSqrt * sideSqrt}"),
                  gutterW,
                  MD3Slider(
                      value: sideSqrt.toDouble(),
                      min: 2.0,
                      max: 4.0,
                      divisions: 2,
                      onChanged: isLocked
                          ? null
                          : (n) => Actions.invoke(context,
                              ChangeHomeViewSideSqrtIntent(n.toInt()))),
                  marginW,
                  Text("Dificuldade: ${difficulty.name}"),
                  gutterW,
                  MD3Slider(
                      value: difficulty.index.toDouble(),
                      max: (SudokuDifficulty.values.length - 1).toDouble(),
                      divisions: SudokuDifficulty.values.length - 1,
                      onChanged: isLocked
                          ? null
                          : (n) => Actions.invoke(
                              context,
                              ChangeHomeViewDifficultyIntent(
                                  SudokuDifficulty.values[n.toInt()]))),
                  marginW,
                  FilledButton(
                      onPressed: isLocked
                          ? null
                          : () => Actions.invoke(
                                context,
                                SudokuHomeNewGameIntent(),
                              ),
                      child: Text('Novo Jogo')),
                  marginW,
                  FilledTonalButton(
                      onPressed: isLocked || !canResume
                          ? null
                          : () => Actions.invoke(
                                context,
                                SudokuHomeContinueGameIntent(),
                              ),
                      child: Text('Continuar')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
