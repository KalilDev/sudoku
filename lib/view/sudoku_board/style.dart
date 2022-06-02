import 'package:app/util/monadic.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';

const _kDisabledForegroundOpacity = 0.6;
const _kDisabledBackgroundOpacity = 0.38;
const _kDisabledOutlineOpacity = 0.38;

ContextfulAction<ButtonStyle> _styleFromValues(
  Color foreground,
  Color pressedForeground,
  Color background,
  Color pressedBackground,
  Color overlayColor,
  Color pressedOverlayColor,
) =>
    readC.map((c) => c.stateOverlayOpacity).map(
          (stateOverlayOpacity) => ButtonStyle(
            foregroundColor: MaterialStateProperty.resolveWith(
              (states) => (_pressedOrFocused(states)
                      ? pressedForeground
                      : foreground)
                  .withOpacity(
                      _disabled(states) ? _kDisabledForegroundOpacity : 1.0),
            ),
            backgroundColor: MaterialStateProperty.resolveWith(
              (states) => (_pressedOrFocused(states)
                      ? pressedBackground
                      : background)
                  .withOpacity(
                      _disabled(states) ? _kDisabledBackgroundOpacity : 1.0),
            ),
            overlayColor: MaterialStateProperty.resolveWith((states) {
              if (_disabled(states)) {
                return Colors.transparent;
              }
              return MD3StateOverlayColor(
                MaterialStateColor.resolveWith(
                  (states) => _pressedOrFocused(states)
                      ? pressedOverlayColor
                      : overlayColor,
                ),
                stateOverlayOpacity,
              ).resolve(states);
            }),
          ),
        );

final ContextfulAction<ButtonStyle> sudokuOutlinedButtonStyle =
    colorScheme.bind(
  (scheme) => _styleFromValues(
    scheme.onSurfaceVariant,
    scheme.onSurfaceVariant,
    scheme.surface,
    scheme.surface,
    scheme.tertiary,
    scheme.primary,
  ).map(
    (baseStyle) => baseStyle.copyWith(
      side: MaterialStateProperty.resolveWith(
        (states) {
          if (_disabled(states)) {
            return BorderSide(
              color: scheme.outline.withOpacity(_kDisabledOutlineOpacity),
              width: 1.0,
            );
          }
          return _pressedOrFocused(states)
              ? BorderSide(
                  color: scheme.tertiary,
                  width: 2.0,
                )
              : BorderSide(
                  color: scheme.primary,
                  width: 1.0,
                );
        },
      ),
    ),
  ),
);

final ContextfulAction<ButtonStyle> sudokuFilledButtonStyle = colorScheme.bind(
  (scheme) => _styleFromValues(
    scheme.onPrimary,
    scheme.onTertiary,
    scheme.primary,
    scheme.tertiary,
    scheme.primary,
    scheme.tertiary,
  ),
);

bool _disabled(Set<MaterialState> states) =>
    states.contains(MaterialState.disabled);
bool _pressedOrFocused(Set<MaterialState> states) =>
    states.contains(MaterialState.pressed) ||
    states.contains(MaterialState.focused);
