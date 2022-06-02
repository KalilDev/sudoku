import 'package:app/util/monadic.dart';
import 'package:flutter/material.dart';

final ContextfulAction<MediaQueryData> mediaQuery = readC.map(MediaQuery.of);
final ContextfulAction<Orientation> mediaQueryOrientation =
    mediaQuery.map((mq) => mq.orientation);

final ContextfulAction<Orientation> viewLayoutOrientation =
    readC.map(SudokuViewLayoutOrientation.of);

class SudokuViewLayoutOrientation extends InheritedWidget {
  const SudokuViewLayoutOrientation({
    Key? key,
    required this.orientation,
    required Widget child,
  }) : super(key: key, child: child);
  final Orientation orientation;

  @override
  bool updateShouldNotify(SudokuViewLayoutOrientation oldWidget) =>
      oldWidget.orientation != orientation;

  static Orientation of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<SudokuViewLayoutOrientation>()!
      .orientation;
}

class SudokuViewLayout extends StatelessWidget {
  final Widget board;
  final Widget keypad;
  final Widget actions;

  const SudokuViewLayout({
    Key? key,
    required this.board,
    required this.keypad,
    required this.actions,
  }) : super(key: key);

  static final ContextfulAction<Orientation> viewLayoutOrientation =
      mediaQueryOrientation;

  MultiChildLayoutDelegate _delegateForOrientation(Orientation orientation) {
    switch (orientation) {
      case Orientation.portrait:
        return _PortraitLayoutDelegate();
      case Orientation.landscape:
        return _LandscapeLayoutDelegate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final orientation = viewLayoutOrientation(context);
    return SudokuViewLayoutOrientation(
      orientation: orientation,
      child: CustomMultiChildLayout(
        delegate: _delegateForOrientation(orientation),
        children: [
          LayoutId(id: _SlotId.board, child: board),
          LayoutId(id: _SlotId.keypad, child: keypad),
          LayoutId(id: _SlotId.actions, child: actions),
        ],
      ),
    );
  }
}

enum _SlotId {
  board,
  keypad,
  actions,
}

class _PortraitLayoutDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    final Size totalSize = size;
    final actionsSize = layoutChild(
      _SlotId.actions,
      BoxConstraints(
        maxWidth: size.width,
        minWidth: size.width,
        minHeight: 0,
        maxHeight: size.height,
      ),
    );
    size = Size(size.width, size.height - actionsSize.height);
    final keypadSize = layoutChild(
      _SlotId.keypad,
      BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
        minHeight: 0,
        maxHeight: size.height,
      ),
    );
    size = Size(size.width, size.height - keypadSize.height);
    final boardSize = layoutChild(_SlotId.board, BoxConstraints.tight(size));
    positionChild(
      _SlotId.board,
      Offset.zero,
    );
    positionChild(
      _SlotId.actions,
      Offset(
        0,
        totalSize.height - actionsSize.height,
      ),
    );
    positionChild(
      _SlotId.keypad,
      Offset(
        0,
        totalSize.height - actionsSize.height - keypadSize.height,
      ),
    );
  }

  @override
  bool shouldRelayout(_PortraitLayoutDelegate oldDelegate) => false;
}

class _LandscapeLayoutDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    final Size totalSize = size;
    final actionsSize = layoutChild(
      _SlotId.actions,
      BoxConstraints(
        maxWidth: size.width,
        minWidth: 0,
        minHeight: size.height,
        maxHeight: size.height,
      ),
    );
    size = Size(size.width - actionsSize.width, size.height);
    positionChild(_SlotId.actions, Offset(size.width, 0));

    final keypadSize = layoutChild(
      _SlotId.keypad,
      BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
        minHeight: 0,
        maxHeight: size.height,
      ),
    );
    size = Size(size.width, size.height - keypadSize.height);
    positionChild(_SlotId.keypad, Offset(0, size.height));
    final boardSize = layoutChild(_SlotId.board, BoxConstraints.tight(size));
    positionChild(
      _SlotId.board,
      Offset.zero,
    );
  }

  @override
  bool shouldRelayout(_LandscapeLayoutDelegate oldDelegate) => false;
}
