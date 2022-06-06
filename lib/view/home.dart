library app.view.home;

import 'package:app/module/base.dart';
import 'package:app/navigation/src/navigation.dart';
import 'package:app/sudoku_generation/sudoku_generation.dart';
import 'package:app/util/l10n.dart';
import 'package:app/util/monadic.dart';
import 'package:app/viewmodel/home.dart';
import 'package:app/widget/decoration.dart';
import 'package:app/widget/slider_with_title.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:utils/utils.dart';
import 'package:value_notifier/value_notifier.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      final result = await SudokuNavigation.pushGameRoute(context, target);
      if (result != null) {
        controller.popTarget(SudokuNavigationPopInfo(target, result));
        result.dispose();
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

extension on AppLocalizations {
  String sideN(int n) => sudoku_side.replaceAll('%n', '$n');
  String difficultyString(SudokuDifficulty d) {
    switch (d) {
      case SudokuDifficulty.begginer:
        return difficulty_begginer;
      case SudokuDifficulty.easy:
        return difficulty_easy;
      case SudokuDifficulty.medium:
        return difficulty_medium;
      case SudokuDifficulty.hard:
        return difficulty_hard;
      case SudokuDifficulty.extreme:
        return difficulty_extreme;
      case SudokuDifficulty.impossible:
        return difficulty_impossible;
    }
  }

  String difficultyD(SudokuDifficulty d) =>
      difficulty.replaceAll('%d', difficultyString(d));
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
    final side = sideSqrt * sideSqrt;
    return Center(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Semantics(
              image: true,
              label: 'Empty Sudoku board',
              child: SudokuBoardHeroDecoration(
                sideSqrt: sideSqrt,
                isHome: true,
              ),
            ),
            Padding(
              padding: InheritedMD3BodyMargin.of(context).padding +
                  EdgeInsets.only(bottom: gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SiderWithTitle(
                    value: sideSqrt.toDouble(),
                    min: 2.0,
                    max: 4.0,
                    divisions: 2,
                    label: Text(context.l10n.sideN(side)),
                    onChanged: isLocked
                        ? null
                        : (n) => Actions.invoke(
                              context,
                              ChangeHomeViewSideSqrtIntent(n.toInt()),
                            ),
                    semanticFormatterCallback: (v) =>
                        context.l10n.sideN(v.toInt() * v.toInt()),
                  ),
                  marginW,
                  SiderWithTitle(
                      label: Text(context.l10n.difficultyD(difficulty)),
                      semanticFormatterCallback: (n) => context.l10n
                          .difficultyD(SudokuDifficulty.values[n.toInt()]),
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
                      child: Text(context.l10n.new_game_action)),
                  marginW,
                  FilledTonalButton(
                      onPressed: isLocked || !canResume
                          ? null
                          : () => Actions.invoke(
                                context,
                                SudokuHomeContinueGameIntent(),
                              ),
                      child: Text(context.l10n.continue_action)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
