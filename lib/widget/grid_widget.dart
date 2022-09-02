import 'package:flutter/material.dart';
import 'package:kalil_utils/utils.dart';

enum GridLayoutMode {
  intrinsic,
  intrinsicWidth,
  intrinsicHeight,
  expand,
}

class GridWidget extends StatelessWidget {
  const GridWidget({
    Key? key,
    this.horizontalSpace = 0,
    this.verticalSpace = 0,
    this.layoutMode = GridLayoutMode.expand,
    required this.rows,
    required this.cols,
    required this.buildChild,
  }) : super(key: key);

  factory GridWidget.linearC({
    Key? key,
    double horizontalSpace = 0,
    double verticalSpace = 0,
    GridLayoutMode layoutMode = GridLayoutMode.expand,
    required int cols,
    required int count,
    required IndexedWidgetBuilder buildChild,
  }) =>
      GridWidget(
        key: key,
        horizontalSpace: horizontalSpace,
        verticalSpace: verticalSpace,
        layoutMode: layoutMode,
        cols: cols,
        rows: (count / cols).ceil(),
        buildChild: (context, c, r) {
          final i = r * cols + c;
          if (i >= count) {
            return SizedBox();
          }
          return buildChild(context, i);
        },
      );

  factory GridWidget.linearR({
    Key? key,
    double horizontalSpace = 0,
    double verticalSpace = 0,
    GridLayoutMode layoutMode = GridLayoutMode.expand,
    required int rows,
    required int count,
    required IndexedWidgetBuilder buildChild,
  }) {
    final cols = (count / rows).ceil();
    return GridWidget(
      key: key,
      horizontalSpace: horizontalSpace,
      verticalSpace: verticalSpace,
      layoutMode: layoutMode,
      cols: cols,
      rows: rows,
      buildChild: (context, c, r) {
        final i = r * cols + c;
        if (i >= count) {
          return SizedBox();
        }
        return buildChild(context, i);
      },
    );
  }
  final double horizontalSpace;
  final double verticalSpace;
  final GridLayoutMode layoutMode;
  final int rows;
  final int cols;
  final Widget Function(BuildContext, int c, int r) buildChild;

  Widget _wrapRow({required Widget child}) => {
        GridLayoutMode.intrinsicHeight,
        GridLayoutMode.expand
      }.contains(layoutMode)
          ? Expanded(child: child)
          : child;
  Widget _wrapCol({required Widget child}) => {
        GridLayoutMode.intrinsicWidth,
        GridLayoutMode.expand
      }.contains(layoutMode)
          ? Expanded(child: child)
          : child;

  static int _clampPos(int n) => n < 0 ? 0 : n;

  @override
  Widget build(BuildContext context) {
    final paddingRect = SizedBox(
      height: verticalSpace,
      width: horizontalSpace,
    );
    return Column(
      children: List.generate(
        _clampPos(rows * 2 - 1),
        (twoR) => twoR % 2 != 0
            ? paddingRect
            : _wrapRow(
                child: Row(
                  children: List.generate(
                    _clampPos(cols * 2 - 1),
                    (twoC) => twoC % 2 != 0
                        ? paddingRect
                        : _wrapCol(
                            child: buildChild(
                              context,
                              twoC ~/ 2,
                              twoR ~/ 2,
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
