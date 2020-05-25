import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/theme.dart';

typedef ShapeBuilder = ShapeBorder Function(Color);

class SudokuButton extends MaterialButton {
  final bool filled;
  final BoxConstraints constraints;
  final ShapeBuilder shapeBuilder;
  final bool useSecondary;
  final TextStyle textStyle;
  final SudokuTheme theme;
  final double borderWidth;
  final BorderRadiusGeometry borderRadius;
  const SudokuButton(
      {Key key,
      bool filled,
      VoidCallback onPressed,
      this.constraints,
      this.textStyle,
      this.shapeBuilder,
      Widget child,
      bool useSecondary,
      this.theme,
      double elevation,
      this.borderWidth,
      this.borderRadius})
      : assert(
            shapeBuilder == null ||
                (borderWidth == null && borderRadius == null),
            "You cannot specify both an shapebuilder and an borderWidth or borderRadius!"),
        filled = filled ?? false,
        useSecondary = useSecondary ?? true,
        super(
            key: key, onPressed: onPressed, child: child, elevation: elevation);

  @override
  Widget build(BuildContext context) {
    final theme = this.theme ?? Provider.of<SudokuTheme>(context);

    final ThemeData materialTheme = Theme.of(context);
    var buttonTheme =
        ButtonTheme.of(context).copyWith(textTheme: ButtonTextTheme.primary);
    final mainColor = useSecondary ? theme.secondary : theme.main;
    final mainDarkenedColor =
        useSecondary ? theme.secondaryDarkened : theme.mainDarkened;
    //final mainColor =  useSecondary ? theme.secondary : theme.main;
    //debugger();
    buttonTheme = buttonTheme.copyWith(
        buttonColor: filled ? mainColor : materialTheme.backgroundColor,
        highlightColor: filled ? null : mainDarkenedColor.withAlpha(80),
        splashColor: filled ? null : mainColor);
    final borderColor =
        enabled ? mainDarkenedColor : buttonTheme.getDisabledFillColor(this);
    final defaultBorder = RoundedRectangleBorder(
        side: BorderSide(color: borderColor, width: borderWidth ?? 1.0),
        borderRadius: borderRadius ?? BorderRadius.circular(4.0));

    return RawMaterialButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      onHighlightChanged: onHighlightChanged,
      fillColor: buttonTheme.getFillColor(this),
      textStyle: (textStyle ?? materialTheme.textTheme.button)
          .copyWith(color: buttonTheme.getTextColor(this)),
      focusColor: buttonTheme.getFocusColor(this),
      hoverColor: buttonTheme.getHoverColor(this),
      highlightColor: buttonTheme.getHighlightColor(this),
      splashColor: buttonTheme.getSplashColor(this),
      elevation: elevation ?? 0,
      focusElevation: buttonTheme.getFocusElevation(this),
      hoverElevation: buttonTheme.getHoverElevation(this),
      highlightElevation: buttonTheme.getHighlightElevation(this),
      disabledElevation: buttonTheme.getDisabledElevation(this),
      visualDensity: visualDensity ?? materialTheme.visualDensity,
      constraints: constraints ?? buttonTheme.getConstraints(this),
      shape: shapeBuilder?.call(borderColor) ?? defaultBorder,
      clipBehavior: clipBehavior,
      focusNode: focusNode,
      autofocus: autofocus,
      materialTapTargetSize: buttonTheme.getMaterialTapTargetSize(this),
      animationDuration: buttonTheme.getAnimationDuration(this),
      child: child,
    );
  }
}
