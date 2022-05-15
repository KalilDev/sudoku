import 'dart:math';

import 'package:flutter/material.dart';

class SudokuBoardDecoration extends StatelessWidget {
  const SudokuBoardDecoration({
    Key? key,
    required this.sideSqrt,
    required this.secondaryOpacity,
    this.child,
  }) : super(key: key);
  final int sideSqrt;
  final Animation<double> secondaryOpacity;
  final Widget? child;

  static const maxNoChildDecorationSide = 400.0;

  @override
  Widget build(BuildContext context) => child != null
      ? Container(
          color: Colors.red,
          child: child,
        )
      : LayoutBuilder(builder: (context, constraints) {
          final side = max(min(maxNoChildDecorationSide, constraints.maxWidth),
              constraints.minWidth);
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: side,
                height: side,
                child: Container(
                  color: Colors.red,
                  child: child,
                ),
              ),
            ],
          );
        });

  max(min, double minWidth) {}
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
        ),
      );
}
