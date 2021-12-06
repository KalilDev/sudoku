import 'dart:math';
import 'package:flutter/material.dart';
import 'package:material_you/material_you.dart';
import 'package:sudoku_core/sudoku_core.dart';
import 'package:sudoku/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_presentation/models.dart';
import 'package:sudoku_presentation/sudoku_bloc.dart';
import 'package:provider/provider.dart';

Color getColor(SquareInfo info, BuildContext context) {
  final theme = Provider.of<SudokuTheme>(context);
  if (info.validation == Validation.incorrect) {
    return theme.invalid;
  }
  if (info.isInitial) {
    final bg = Color.alphaBlend(Colors.grey.withAlpha(20), theme.background);
    //final bg = theme.background;
    return Color.alphaBlend(theme.main.withAlpha(20), bg);
  }
  return info.isSelected ? Provider.of<SudokuTheme>(context).secondary : null;
}

String getText(SquareInfo info) {
  final noMainNumber = info.number == 0;
  final text =
      noMainNumber ? info.possibleNumbers.join() : info.number.toString();
  return text;
}

Alignment getTextAlignment(SquareInfo info) {
  final noMainNumber = info.number == 0;
  if (noMainNumber) {
    return Alignment.bottomCenter;
  }
  return Alignment.center;
}

TextStyle getTextStyle(
    SquareInfo info, double squareSide, BuildContext context) {
  final noMainNumber = info.number == 0;
  final theme = Theme.of(context);
  final textTheme = context.textTheme;
  final smallestTextStyle = textTheme.labelMedium;
  final biggestTextStyle = textTheme.headlineMedium;
  final absoluteBiggest = squareSide * 0.8;
  final constrainedTextStyle = biggestTextStyle.copyWith(
    fontSize: absoluteBiggest
        .clamp(smallestTextStyle.fontSize, biggestTextStyle.fontSize)
        .toDouble(),
  );
  final style = noMainNumber ? smallestTextStyle : constrainedTextStyle;
  final color = getColor(info, context);
  if (color == null) {
    return style;
  }
  final colorBrightness = ThemeData.estimateBrightnessForColor(color);
  if (colorBrightness != theme.brightness) {
    return style.copyWith(
        color:
            colorBrightness == Brightness.dark ? Colors.white : Colors.black87);
  }
  return style;
}

class SudokuStaticSquare extends StatelessWidget {
  final SquareInfo info;
  final int x;
  final int y;
  final double squareSide;
  final bool disabled;
  const SudokuStaticSquare(
      {@required Key key,
      @required this.info,
      @required this.x,
      @required this.y,
      this.disabled,
      this.squareSide})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final text =
        Text(getText(info), style: getTextStyle(info, squareSide, context));
    final decoration =
        BoxDecoration(color: getColor(info, context), shape: BoxShape.circle);
    void onTap() => context.bloc<SudokuBloc>().add(SquareTap(x, y));

    final padding = squareSide / 15;
    return Padding(
      padding: EdgeInsets.all(padding),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: disabled || info.isInitial ? null : onTap,
        onFocusChange: (a) => a ? onTap() : null,
        child: Ink(
          decoration: decoration,
          child: Align(alignment: getTextAlignment(info), child: text),
        ),
      ),
    );
  }
}

class SudokuAnimatedSquare extends StatefulWidget {
  final SquareInfo info;
  final int x;
  final int y;
  final double squareSide;
  final bool disabled;
  final AnimationOptions animationOptions;

  const SudokuAnimatedSquare(
      {@required Key key,
      @required this.info,
      @required this.x,
      @required this.y,
      @required this.animationOptions,
      this.disabled,
      this.squareSide})
      : super(key: key);

  @override
  _SudokuSquareState createState() => _SudokuSquareState();
}

class _SquareState {
  final double textPos; // 0.0 -> oldInfo text, 1.0 -> info text
  final Alignment textAlign;
  final Color squareColor;
  final double decorationSize;
  final TextStyle style;
  _SquareState._(this.textPos, this.squareColor, this.decorationSize,
      this.textAlign, this.style);
}

class _SquareTween extends Tween<_SquareState> {
  _SquareTween({_SquareState begin, _SquareState end})
      : super(begin: begin, end: end);
  @override
  _SquareState lerp(double t) {
    assert(begin != null);
    assert(end != null);
    if (t == 0) {
      return begin;
    }
    if (t == 1) {
      return end;
    }
    final textPos = Curves.easeIn.transform(t);
    final squareColor = Color.lerp(
        begin.squareColor, end.squareColor, Curves.easeIn.transform(t));
    Curve decorationCurve = Curves.bounceInOut;
    Animatable<double> decorationTween =
        Tween<double>(begin: begin.decorationSize, end: end.decorationSize);
    if (begin.decorationSize == 1 &&
        begin.decorationSize == end.decorationSize &&
        begin.squareColor != squareColor) {
      decorationCurve = Curves.easeInOut;
      decorationTween = TweenSequence<double>([
        TweenSequenceItem<double>(
            tween: Tween<double>(begin: 1, end: 0.8), weight: 0.5),
        TweenSequenceItem<double>(
            tween: Tween<double>(begin: 0.8, end: 1), weight: 0.5),
      ]);
    }
    final textAlign = Alignment.lerp(
        begin.textAlign, end.textAlign, Curves.bounceInOut.transform(t));
    final style =
        TextStyle.lerp(begin.style, end.style, Curves.easeIn.transform(t));
    return _SquareState._(
        textPos,
        squareColor,
        decorationTween.transform(decorationCurve.transform(t)),
        textAlign,
        style);
  }
}

class _SudokuSquareState extends State<SudokuAnimatedSquare>
    with SingleTickerProviderStateMixin {
  SquareInfo oldInfo = SquareInfo.empty;
  SquareInfo targetInfo;
  AnimationController controller;
  _SquareTween tween;

  @override
  void initState() {
    updateControllerIfNeeded();
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        oldInfo = widget.info;
      }
    });
    super.initState();
  }

  void updateControllerIfNeeded() {
    Duration duration;
    switch (widget.animationOptions.speed) {
      case AnimationSpeed.none:
        duration = Duration.zero;
        break;
      case AnimationSpeed.normal:
        duration = const Duration(milliseconds: 400);
        break;
      case AnimationSpeed.fast:
        duration = const Duration(milliseconds: 200);
        break;
      case AnimationSpeed.fastest:
        duration = const Duration(milliseconds: 100);
        break;
    }
    controller ??= AnimationController(vsync: this, duration: duration);
    controller.duration = duration;
  }

  void onTap() {
    context.bloc<SudokuBloc>().add(SquareTap(widget.x, widget.y));
  }

  @override
  void didUpdateWidget(SudokuAnimatedSquare oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  static _SquareState createState(
      SquareInfo info, double squareSide, BuildContext context, bool isEnd) {
    final color = getColor(info, context);
    final align = getTextAlignment(info);
    final style = getTextStyle(info, squareSide, context);
    return _SquareState._(
        isEnd ? 1.0 : 0.0, color, color == null ? 0 : 1.0, align, style);
  }

  Widget buildWidget(BuildContext context) {
    final state = tween.transform(controller.value);
    TextStyle textStyle;
    if (widget.animationOptions.hasTextStyleAnimations) {
      textStyle = state.style;
      final targetStyle = getTextStyle(targetInfo, widget.squareSide, context);
      if (!widget.animationOptions.textSize) {
        textStyle = textStyle.copyWith(fontSize: targetStyle.fontSize);
      }
      if (!widget.animationOptions.textColor) {
        textStyle = textStyle.copyWith(color: targetStyle.color);
      }
    } else {
      textStyle = getTextStyle(targetInfo, widget.squareSide, context);
    }
    Widget text;
    if (state.textPos == 0.0 ||
        state.textPos == 1.0 ||
        !widget.animationOptions.textOpacity) {
      text = Text(state.textPos == 0.0 ? getText(oldInfo) : getText(targetInfo),
          style: textStyle);
    } else {
      final oldOpacity = (1 - 2.0 * state.textPos).clamp(0.0, 1.0)
          as double; // idk why this type isn't inferred
      text = Stack(fit: StackFit.loose, children: [
        if (oldOpacity != 0)
          Opacity(
              opacity: oldOpacity,
              child: Text(
                getText(oldInfo),
                style: textStyle,
              )),
        Opacity(
            opacity: state.textPos,
            child: Text(
              getText(targetInfo),
              style: textStyle,
            ))
      ]);
    }
    final decoration = BoxDecoration(
        color: widget.animationOptions.selectColor
            ? state.squareColor
            : getColor(targetInfo, context),
        shape: BoxShape.circle);
    final sizeFrac =
        widget.animationOptions.selectSize ? state.decorationSize : 1.0;
    final padding = widget.squareSide / 15;
    return Padding(
      padding: EdgeInsets.all(padding),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: widget.disabled || targetInfo.isInitial ? null : onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
                child: FractionallySizedBox(
                    widthFactor: sizeFrac,
                    heightFactor: sizeFrac,
                    child: Ink(
                      decoration: decoration,
                      child: const SizedBox.expand(),
                    ))),
            Align(
                alignment: widget.animationOptions.textPosition
                    ? state.textAlign
                    : getTextAlignment(targetInfo),
                child: text),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    updateControllerIfNeeded();
    if (controller.isAnimating) {
      tween = _SquareTween(
          begin: tween.transform(controller.value),
          end: createState(widget.info, widget.squareSide, context, true));
    } else {
      tween = _SquareTween(
          begin: createState(oldInfo, widget.squareSide, context, false),
          end: createState(widget.info, widget.squareSide, context, true));
    }
    if (targetInfo == null || !targetInfo.hasSameContentAs(widget.info)) {
      targetInfo = widget.info;
      if (!targetInfo.hasSameContentAs(oldInfo)) {
        controller.reset();
        controller.forward();
      }
    }
    return AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, _) => buildWidget(context));
  }
}

class SudokuBoard extends StatelessWidget {
  final BidimensionalList<SquareInfo> state;
  final AnimationOptions animationOptions;
  final bool disabled;
  const SudokuBoard({Key key, this.state, this.animationOptions, this.disabled})
      : super(key: key);

  Widget buildNumber(SquareInfo info, int x, int y, double childSize) {
    final key = ValueKey("Square: $x, $y");
    if (animationOptions.hasAnimations) {
      return SudokuAnimatedSquare(
        info: info,
        x: x,
        y: y,
        disabled: disabled,
        squareSide: childSize,
        key: key,
        animationOptions: animationOptions,
      );
    }
    return SudokuStaticSquare(
      info: info,
      x: x,
      y: y,
      disabled: disabled,
      squareSide: childSize,
      key: key,
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
    final theme = Provider.of<SudokuTheme>(context);
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
                theme.main,
                Color.lerp(
                    theme.background, theme.mainDarkened, animation.value))),
        animation: animation,
      ),
      child: CustomPaint(
        painter: SudokuBgPainter(state.length, theme.main, theme.mainDarkened),
      ),
    );
  }

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
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              SizedBox.expand(child: buildBackground(context)),
              SizedBox.expand(
                child: buildGrid(context),
              )
            ],
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
