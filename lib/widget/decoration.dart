library app.widget.decoration;

import 'dart:math';

import 'board_button.dart';
import 'package:app/util/monadic.dart';
import 'package:flutter/material.dart';

class SudokuBoardDecoration extends StatelessWidget {
  const SudokuBoardDecoration({
    Key? key,
    required this.sideSqrt,
    required this.secondaryOpacity,
    this.largeStrokeWidth = const AlwaysStoppedAnimation(2.0),
    this.color,
    this.secondaryColor,
    this.child,
  }) : super(key: key);
  final int sideSqrt;
  final Animation<double> secondaryOpacity;
  final Animation<double> largeStrokeWidth;
  final Color? color;
  final Color? secondaryColor;
  final Widget? child;

  static const maxNoChildDecorationSide = 400.0;

  @override
  Widget build(BuildContext context) {
    final decoratedChild = AnimatedBuilder(
      animation: Listenable.merge([secondaryOpacity, largeStrokeWidth]),
      builder: (context, child) => DecoratedBox(
        decoration: _SudokuBoardDecoration(
            sideSqrt: sideSqrt,
            color: color ?? colorScheme(context).primary,
            largeStrokeWidth: largeStrokeWidth.value,
            secondaryColor: secondaryColor ??
                colorScheme(context)
                    .secondary
                    .withOpacity(secondaryOpacity.value)),
        child: child,
      ),
      child: child,
    );
    return child != null
        ? decoratedChild
        : LayoutBuilder(builder: (context, constraints) {
            final side = max(
                min(maxNoChildDecorationSide, constraints.maxWidth),
                constraints.minWidth);
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: side,
                  height: side,
                  child: decoratedChild,
                ),
              ],
            );
          });
  }
}

class _SudokuBoardDecoration extends Decoration {
  final int sideSqrt;
  final double largeStrokeWidth;
  final Color color;
  final Color secondaryColor;

  const _SudokuBoardDecoration({
    required this.sideSqrt,
    required this.largeStrokeWidth,
    required this.color,
    required this.secondaryColor,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _SudokuBoardDecorationPainter(
          sideSqrt, largeStrokeWidth, color, secondaryColor);
}

class _SudokuBoardDecorationPainter extends BoxPainter {
  final int sideSqrt;
  final double largeStrokeWidth;
  final Color color;
  final Color secondaryColor;

  _SudokuBoardDecorationPainter(
      this.sideSqrt, this.largeStrokeWidth, this.color, this.secondaryColor);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final largeGridPaint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = largeStrokeWidth;
    const smallGridStrokeWidth = 0.0;
    final smallGridPaint = Paint()
      ..color = secondaryColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = smallGridStrokeWidth;
    final side = configuration.size!.width;
    final sideOfSquare = side / sideSqrt;
    final sideOfCell = sideOfSquare / sideSqrt;
    final sideInCells = sideSqrt * sideSqrt;
    final cellSmallGridDecorationSize = min(
      sideOfCell * 0.8,
      BoardButton.maxButtonSize * 0.8,
    );
    final cellSmallGridPadding = (sideOfCell - cellSmallGridDecorationSize) / 2;
    for (var i = 1; i < sideSqrt; i++) {
      // rows
      canvas.drawLine(
        Offset(largeStrokeWidth / 2, sideOfSquare * i),
        Offset(side - largeStrokeWidth / 2, sideOfSquare * i),
        largeGridPaint,
      );
    }
    for (var j = 1; j < sideSqrt; j++) {
      // cols
      canvas.drawLine(
        Offset(sideOfSquare * j, largeStrokeWidth / 2),
        Offset(sideOfSquare * j, side - largeStrokeWidth / 2),
        largeGridPaint,
      );
    }
    for (var i = 1; i < sideInCells; i++) {
      // ignore the rows that match the square grid
      if (i % sideSqrt == 0) {
        continue;
      }
      // for each col
      for (var j = 0; j < sideInCells; j++) {
        // draw the row segments for cell border at (i,j)
        canvas.drawLine(
          Offset(sideOfCell * j + cellSmallGridPadding, sideOfCell * i),
          Offset(sideOfCell * (j + 1) - cellSmallGridPadding, sideOfCell * i),
          smallGridPaint,
        );
      }
    }
    for (var j = 1; j < sideInCells; j++) {
      // ignore the cols that match the square grid
      if (j % sideSqrt == 0) {
        continue;
      }
      // for each row
      for (var i = 0; i < sideInCells; i++) {
        // draw the row segments for cell border at (i,j)
        canvas.drawLine(
          Offset(sideOfCell * j, sideOfCell * i + cellSmallGridPadding),
          Offset(sideOfCell * j, sideOfCell * (i + 1) - cellSmallGridPadding),
          smallGridPaint,
        );
      }
    }
    canvas.restore();
  }
}

class SudokuBoardHeroDecoration extends StatelessWidget {
  const SudokuBoardHeroDecoration({
    Key? key,
    required this.sideSqrt,
    required this.isHome,
    this.child,
  }) : super(key: key);
  final int sideSqrt;
  final bool isHome;
  final Widget? child;

  Widget _buildShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) =>
      SudokuBoardDecoration(
        secondaryOpacity: Tween<double>(
          begin: isHome ? 0 : 1,
          end: isHome ? 1 : 0,
        ).animate(animation),
        sideSqrt: sideSqrt,
      );

  @override
  Widget build(BuildContext context) => Hero(
        tag: 'sudoku-board-decoration-hero-$sideSqrt',
        flightShuttleBuilder: _buildShuttle,
        child: SudokuBoardDecoration(
          secondaryOpacity: AlwaysStoppedAnimation(isHome ? 0 : 1),
          sideSqrt: sideSqrt,
          child: child,
        ),
      );
}
