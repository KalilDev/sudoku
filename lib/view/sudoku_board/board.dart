import 'dart:math';

import 'package:app/module/base.dart';
import 'package:app/old/board_button/board_button.dart';
import 'package:app/util/l10n.dart';
import 'package:app/viewmodel/sudoku_board.dart';
import 'package:app/widget/animation_options.dart';
import 'package:app/widget/decoration.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:utils/utils.dart';
import 'package:value_notifier/value_notifier.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'flutter_intents.dart';
import 'locking.dart';

extension on AppLocalizations {
  String tileIndexedInfo(int r, int c, String state) =>
      board_board_tile_indexed_info
          .replaceAll('%r', '$r')
          .replaceAll('%c', '$c')
          .replaceAll('%ps_const_or_n', state);
  String boardTileState(SudokuTile tile) => tile.visit(
        permanent: (n) => board_tile_permanent.replaceAll('%n', '$n'),
        number: (n, v) => board_tile_number
            .replaceAll('%n', '$n')
            .replaceAll('%v', boardTileValidation(v)),
        possibilities: (ps) => ps.isEmpty
            ? board_tile_no_possibilities
            : board_tile_possibilities.replaceAll('%ps', ps.join(' ')),
      );
  String boardTileValidation(Validation validation) {
    switch (validation) {
      case Validation.unknown:
        return board_tile_not_validated;
      case Validation.valid:
        return board_tile_valid;
      case Validation.invalid:
        return board_tile_invalid;
    }
  }
}

class _TileWidget extends StatelessWidget {
  const _TileWidget({
    Key? key,
    required this.index,
    required this.tile,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  final SudokuBoardIndex index;
  final SudokuTile tile;
  final bool? isSelected;
  final PressTileIntent onPressed;

  @override
  Widget build(BuildContext context) {
    void invokeIntent() => Actions.invoke<PressTileIntent>(context, onPressed);
    return MergeSemantics(
      child: Semantics(
        selected: isSelected ?? false,
        label: context.l10n.tileIndexedInfo(
          index.y + 1,
          index.x + 1,
          context.l10n.boardTileState(tile),
        ),
        button: tile.visit(
          permanent: (_) => false,
          number: (_, __) => true,
          possibilities: (_) => true,
        ),
        child: BoardButton(
          onTap: tile is Permanent ? null : invokeIntent,
          isLoading: isLocked(context),
          isSelected: isSelected ?? false,
          text: tile.visit(
            permanent: (n) => n.toString(),
            number: (n, _) => n.toString(),
            possibilities: (ps) => (ps.toList()..sort()).join(' '),
          ),
          isBottomText: tile is Possibilities,
          isInvalid: tile is Number &&
              (tile as Number).validation == Validation.invalid,
          animationOptions: animationOptions(context),
          isInitial: tile is Permanent,
        ),
      ),
    );
  }
}

class SudokuViewBoardWidget extends StatefulWidget {
  const SudokuViewBoardWidget({
    Key? key,
    required this.board,
    required this.selectedIndex,
    required this.side,
  }) : super(key: key);
  final ValueListenable<TileMatrix> board;
  final ValueListenable<MatrixIndex?> selectedIndex;
  final int side;

  @override
  State<SudokuViewBoardWidget> createState() => _SudokuViewBoardWidgetState();
}

class _SudokuViewBoardWidgetState extends State<SudokuViewBoardWidget> {
  static final _indexedShortcutCache =
      <SudokuBoardIndex, Map<ShortcutActivator, Intent>>{};
  static Map<ShortcutActivator, Intent> shortcutsForIndex(
          SudokuBoardIndex index) =>
      _indexedShortcutCache.putIfAbsent(
          index,
          () => {
                const SingleActivator(LogicalKeyboardKey.digit0):
                    PressNumberOnBoardIntent(index, 0),
                const SingleActivator(LogicalKeyboardKey.digit1):
                    PressNumberOnBoardIntent(index, 1),
                const SingleActivator(LogicalKeyboardKey.digit2):
                    PressNumberOnBoardIntent(index, 2),
                const SingleActivator(LogicalKeyboardKey.digit3):
                    PressNumberOnBoardIntent(index, 3),
                const SingleActivator(LogicalKeyboardKey.digit4):
                    PressNumberOnBoardIntent(index, 4),
                const SingleActivator(LogicalKeyboardKey.digit5):
                    PressNumberOnBoardIntent(index, 5),
                const SingleActivator(LogicalKeyboardKey.digit6):
                    PressNumberOnBoardIntent(index, 6),
                const SingleActivator(LogicalKeyboardKey.digit7):
                    PressNumberOnBoardIntent(index, 7),
                const SingleActivator(LogicalKeyboardKey.digit8):
                    PressNumberOnBoardIntent(index, 8),
                const SingleActivator(LogicalKeyboardKey.digit9):
                    PressNumberOnBoardIntent(index, 9),
                const SingleActivator(LogicalKeyboardKey.digit0, control: true):
                    PressNumberOnBoardAltIntent(index, 0),
                const SingleActivator(LogicalKeyboardKey.digit1, control: true):
                    PressNumberOnBoardAltIntent(index, 1),
                const SingleActivator(LogicalKeyboardKey.digit2, control: true):
                    PressNumberOnBoardAltIntent(index, 2),
                const SingleActivator(LogicalKeyboardKey.digit3, control: true):
                    PressNumberOnBoardAltIntent(index, 3),
                const SingleActivator(LogicalKeyboardKey.digit4, control: true):
                    PressNumberOnBoardAltIntent(index, 4),
                const SingleActivator(LogicalKeyboardKey.digit5, control: true):
                    PressNumberOnBoardAltIntent(index, 5),
                const SingleActivator(LogicalKeyboardKey.digit6, control: true):
                    PressNumberOnBoardAltIntent(index, 6),
                const SingleActivator(LogicalKeyboardKey.digit7, control: true):
                    PressNumberOnBoardAltIntent(index, 7),
                const SingleActivator(LogicalKeyboardKey.digit8, control: true):
                    PressNumberOnBoardAltIntent(index, 8),
                const SingleActivator(LogicalKeyboardKey.digit9, control: true):
                    PressNumberOnBoardAltIntent(index, 9),
              });

  Widget _buildChild(
    TileMatrix board,
    ValueGetter<ValueListenable<MatrixIndex?>> selected,
    BuildContext context,
    SudokuBoardIndex index,
  ) {
    final tile = matrixGetAt(board, index);
    return Shortcuts(
      shortcuts: shortcutsForIndex(index),
      child: selected()
          // Ensure we are not doing useless rebuilds by only querying the
          // current index
          .map((selected) => selected == null ? null : selected == index)
          .unique()
          .map((isSelected) => _TileWidget(
                index: index,
                tile: tile,
                isSelected: isSelected,
                onPressed: PressTileIntent(index),
              ))
          .build(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableOwnerBuilder<MatrixIndex?>(
      valueListenable: widget.selectedIndex,
      builder: (context, selectedIndex) => _GridLayout(
        child: widget.board
            .map(
              (board) => SudokuBoardHeroDecoration(
                  sideSqrt: sqrt(widget.side).toInt(),
                  isHome: false,
                  child: _BoardGrid(
                    side: widget.side,
                    buildChild: _buildChild.apL(board).apL(selectedIndex),
                  )),
            )
            .build(),
      ),
    );
  }
}

class SudokuViewBoard extends ControllerWidget<SudokuViewBoardController> {
  const SudokuViewBoard({
    Key? key,
    required ControllerHandle<SudokuViewBoardController> controller,
    this.sudokuBoardKey,
  }) : super(
          key: key,
          controller: controller,
        );
  final Key? sudokuBoardKey;

  @override
  Widget build(ControllerContext<SudokuViewBoardController> context) {
    final board = context.useLazy((c) => c.board);
    final selected = context.use(controller.selectedIndex);
    return SudokuViewBoardWidget(
      key: sudokuBoardKey,
      board: board,
      selectedIndex: selected,
      side: controller.side,
    );
  }
}

class _GridLayout extends StatelessWidget {
  const _GridLayout({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox.expand(
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: child,
          ),
        ),
      );
}

class _BoardGrid extends StatelessWidget {
  const _BoardGrid({
    Key? key,
    this.padding = 0,
    required this.side,
    required this.buildChild,
  }) : super(key: key);
  final double padding;
  final int side;
  final Widget Function(BuildContext, SudokuBoardIndex) buildChild;

  @override
  Widget build(BuildContext context) {
    final paddingSquare = SizedBox(
      height: padding,
      width: padding,
    );
    return Column(
      children: List.generate(
        side * 2 - 1,
        (twoJ) => twoJ % 2 != 0
            ? paddingSquare
            : Expanded(
                child: Row(
                  children: List.generate(
                    side * 2 - 1,
                    (twoI) => twoI % 2 != 0
                        ? paddingSquare
                        : Expanded(
                            child: buildChild(
                              context,
                              SudokuBoardIndex(twoI ~/ 2, twoJ ~/ 2),
                            ),
                          ),
                    growable: false,
                  ),
                ),
              ),
        growable: false,
      ),
    );
  }
}
