import 'dart:math';
import 'package:flutter/material.dart';
import 'package:material_you/material_you.dart';
import 'package:sudoku/widgets/board_button/board_button.dart';
import 'package:sudoku_core/sudoku_core.dart';
import 'package:sudoku/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_presentation/models.dart';
import 'package:sudoku_presentation/sudoku_bloc.dart';
import 'package:provider/provider.dart';

class SudokuAnimatedSquare extends StatelessWidget {
  const SudokuAnimatedSquare({
    Key key,
    this.info,
    this.x,
    this.y,
    this.squareSide,
    this.disabled,
    this.loading,
    this.animationOptions,
  }) : super(key: key);
  final SquareInfo info;
  final int x;
  final int y;
  final double squareSide;
  final bool disabled;
  final bool loading;
  final AnimationOptions animationOptions;

  @override
  Widget build(BuildContext context) {
    final bloc = context.bloc<SudokuBloc>();
    void onTap() {
      bloc.add(SquareTap(x, y));
    }

    void onFocused() {
      if (bloc.selectedNum == null && !info.isSelected)
        bloc.add(SquareTap(x, y));
    }

    return BoardButton(
      onTap: disabled || info.isInitial ? null : onTap,
      onFocused: disabled || info.isInitial ? null : onFocused,
      isLoading: loading,
      isInitial: info.isInitial,
      isSelected: info.isSelected,
      isBottomText: info.number == 0,
      isInvalid: info.validation == Validation.incorrect,
      animationOptions: animationOptions,
      text: info.number == 0
          ? info?.possibleNumbers?.join(' ') ?? ''
          : info.number.toString(),
    );
  }
}

class SudokuBoard extends StatelessWidget {
  final BidimensionalList<SquareInfo> state;
  final AnimationOptions animationOptions;
  final bool disabled;
  final bool loading;
  const SudokuBoard({
    Key key,
    this.state,
    this.animationOptions,
    this.disabled,
    this.loading,
  }) : super(key: key);

  Widget buildNumber(SquareInfo info, int x, int y, double childSize) {
    final key = ValueKey("Square: $x, $y");

    return SudokuAnimatedSquare(
      info: info,
      x: x,
      y: y,
      disabled: disabled,
      loading: loading,
      squareSide: childSize,
      key: key,
      animationOptions: animationOptions,
    );
  }

  Widget buildGrid(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final childSize = constraints.biggest.height / state.length;
      final children = state
          .mapInnerIndexed((x, y, info) => buildNumber(info, x, y, childSize))
          .toList();
      return GridView.count(
        crossAxisCount: state.length,
        childAspectRatio: 1,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
        physics: const NeverScrollableScrollPhysics(),
        children: children,
      );
    });
  }

  Widget buildBackground(BuildContext context) {
    final scheme = context.colorScheme;
    return Hero(
      tag: "SudokuBG",
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) =>
          AnimatedBuilder(
        builder: (BuildContext context, _) => CustomPaint(
          painter: SudokuBgPainter(
            state.length,
            scheme.primary,
            Color.lerp(
              scheme.background,
              scheme.primary,
              animation.value,
            ),
          ),
        ),
        animation: animation,
      ),
      child: CustomPaint(
        painter: SudokuBgPainter(
          state.length,
          scheme.primary,
          scheme.primary,
        ),
      ),
    );
  }

  static const kMaxIconSize = 124.0;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: kMaxIconSize * state.length,
            maxWidth: kMaxIconSize * state.length,
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(child: buildBackground(context)),
                Positioned.fill(
                  child: buildGrid(context),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SudokuBgPainter extends CustomPainter {
  final int side;
  final Color hashtagColor;
  final Color gridColor;

  SudokuBgPainter(this.side, this.hashtagColor, this.gridColor);
  int get sideSqrt => sqrt(side).round();
  final double hashtagSize = 2.0;
  final double gridSize = 1.0;

  @override
  void paint(Canvas canvas, Size size) {
    void paintHashtag() {
      final unitSize = size.width / sideSqrt;
      final paint = Paint()
        ..color = hashtagColor
        ..strokeWidth = hashtagSize
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      for (var i = 1; i < sideSqrt; i++) {
        canvas.drawLine(Offset(hashtagSize / 2, unitSize * i),
            Offset(size.width - hashtagSize / 2, unitSize * i), paint);
        canvas.drawLine(Offset(unitSize * i, hashtagSize / 2),
            Offset(unitSize * i, size.height - hashtagSize / 2), paint);
      }
    }

    void paintGrid() {
      final unitSize = size.width / side;
      final padding = unitSize * 1 / 4;
      final paint = Paint()
        ..color = gridColor
        ..strokeWidth = gridSize
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      for (var y = 1; y < side + 1; y++) {
        for (var x = 1; x < side + 1; x++) {
          if (y % sideSqrt != 0) {
            canvas.drawLine(Offset((x - 1) * unitSize + padding, y * unitSize),
                Offset(x * unitSize - padding, y * unitSize), paint);
          }
          if (x % sideSqrt != 0) {
            canvas.drawLine(Offset(x * unitSize, (y - 1) * unitSize + padding),
                Offset(x * unitSize, y * unitSize - padding), paint);
          }
        }
      }
    }

    paintHashtag();
    paintGrid();
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    if (old is SudokuBgPainter) {
      return old.side != side ||
          old.hashtagColor != hashtagColor ||
          old.gridColor != gridColor;
    }
    return true;
  }
}
