import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_core/sudoku_core.dart';
import 'package:sudoku_presentation/preferences_bloc.dart';
import 'package:sudoku_presentation/sudoku_bloc.dart';

import '../prefs_sheet.dart';
import './actions.dart';
import './board.dart';
import './numbers.dart';

class SudokuBoardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreferencesBloc, PrefsState>(
        condition: (prev, next) {
          if (prev is PrefsSnap && next is PrefsSnap) {
            return prev.animationOptions != next.animationOptions;
          }
          return true;
        },
        builder: (BuildContext context, PrefsState _prefsState) => BlocBuilder<
                SudokuBloc, SudokuBlocState>(
            builder: (BuildContext context, SudokuBlocState _state) =>
                LayoutBuilder(builder: (context, constraints) {
                  final appBar = MD3SmallAppBar(
                    title: const Text("Sudoku"),
                    actions: [
                      IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () => openPrefs(context))
                    ],
                  );
                  final sliverAppBar = MD3SliverAppBar(
                    expandable: false,
                    pinned: false,
                    title: const Text("Sudoku"),
                    actions: [
                      IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () => openPrefs(context))
                    ],
                  );
                  if (_prefsState is LoadingPrefsState) {
                    return Scaffold(
                        appBar: appBar,
                        body: const Center(child: CircularProgressIndicator()));
                  }

                  if (_state is SudokuErrorState) {
                    return Scaffold(
                      appBar: appBar,
                      body: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_state.userFriendlyMessage),
                            Text("Mensagem do erro: ${_state.message}")
                          ],
                        ),
                      ),
                    );
                  }
                  final state = _state as SudokuBlocStateWithInfo;
                  final snapOrNull = _state is SudokuSnapshot ? _state : null;
                  final prefsState = _prefsState as PrefsSnap;
                  if (snapOrNull?.validationState == Validation.correct &&
                      !(snapOrNull?.wasDeleted ?? true)) {
                    BlocProvider.of<SudokuBloc>(context).add(DeleteSudoku());
                  }
                  if (snapOrNull?.wasDeleted ?? false) {
                    void pop([dynamic _]) => Navigator.of(context).pop();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showDialog<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return MD3BasicDialog(
                                title: const Text('Parabéns'),
                                icon: Icon(Icons.celebration),
                                content: const Text("Você completou o Sudoku!"),
                                actions: [
                                  TextButton(
                                      onPressed: pop,
                                      child: const Text("Início"))
                                ]);
                          }).then(pop);
                    });
                  }

                  final isPortrait = constraints.biggest.aspectRatio <= 1;
                  final actionsOnChildren =
                      constraints.biggest.aspectRatio >= 1.2;
                  final sudokuActions = Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: SudokuActions(
                          canRewind: snapOrNull?.canRewind,
                          markType: snapOrNull?.markType,
                          enabled: snapOrNull != null,
                          isPortrait: !actionsOnChildren));

                  const numberSize = SudokuNumbers.buttonSize;

                  final numberConstraints = BoxConstraints(
                    minHeight: isPortrait ? numberSize : double.infinity,
                    maxHeight: isPortrait ? 3 * numberSize : double.infinity,
                    minWidth: !isPortrait ? numberSize : double.infinity,
                    maxWidth: !isPortrait ? 3 * numberSize : double.infinity,
                  );

                  final children = [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: SudokuBoard(
                          state: state.squares,
                          animationOptions: prefsState.animationOptions,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: numberConstraints,
                        child: SudokuNumbers(
                            state: state.numbers,
                            enabled: snapOrNull != null,
                            isPortrait: isPortrait),
                      ),
                    ),
                    if (actionsOnChildren) sudokuActions
                  ];
                  final widget = SliverFillRemaining(
                      child: !isPortrait
                          ? Row(children: children)
                          : Column(children: children));
                  return Scaffold(
                    bottomNavigationBar:
                        !actionsOnChildren ? sudokuActions : null,
                    body: CustomScrollView(
                      slivers: [sliverAppBar, widget],
                      physics: const SnapToEdgesAndPointsPhysics(
                          points: [kToolbarHeight]),
                    ),
                  );
                })));
  }
}

/// Scroll physics used by a [PageView].
///
/// These physics cause the page view to snap to page boundaries.
///
/// See also:
///
///  * [ScrollPhysics], the base class which defines the API for scrolling
///    physics.
///  * [PageView.physics], which can override the physics used by a page view.
class SnapToEdgesAndPointsPhysics extends ScrollPhysics {
  /// Creates physics for a [PageView].
  const SnapToEdgesAndPointsPhysics({this.points, ScrollPhysics parent})
      : super(parent: parent);

  final List<double> points;

  @override
  SnapToEdgesAndPointsPhysics applyTo(ScrollPhysics ancestor) {
    return SnapToEdgesAndPointsPhysics(
        points: points, parent: buildParent(ancestor));
  }

  // 0 = start of scroll
  // 1 = points[0]
  // 2 = points[1]..
  // n = n < points.length ? points[n] : end of scroll
  double _getPoint(ScrollMetrics position) {
    final sortedPoints = points.toList()..sort((a, b) => a.compareTo(b));
    final currentPos = position.pixels;
    int startI = 0;
    double start = 0.0;
    double end;
    for (var i = 0; i < sortedPoints.length; i++) {
      final point = sortedPoints[i];
      if (point < currentPos) {
        start = point;
        startI = i + 1;
      } else {
        end = point;
        break;
      }
    }
    end ??= position.viewportDimension;
    final range = end - start;
    return startI + (currentPos - start) / range;
  }

  double _getPixels(ScrollMetrics position, int point) {
    if (point == 0) {
      return 0.0;
    }
    if (point > points.length) {
      return position.viewportDimension;
    }
    return points[point - 1];
  }

  double _getTargetPixels(
      ScrollMetrics position, Tolerance tolerance, double velocity) {
    double point = _getPoint(position);
    // TODO
    if (velocity < -tolerance.velocity) {
      point -= 0.1;
    } else if (velocity > tolerance.velocity) {
      point += 0.1;
    }
    return _getPixels(position, point.round());
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}
