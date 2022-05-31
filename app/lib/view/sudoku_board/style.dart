import 'package:app/util/monadic.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';

final ContextfulAction<ButtonStyle> outlinedActionAndKeypadButtonStyle =
    readC.bind(
  (context) => colorScheme.map(
    (scheme) => ButtonStyle(
      foregroundColor: MaterialStateProperty.resolveWith(
          (states) => _disabled(states) ? null : scheme.onSurfaceVariant),
      backgroundColor: MaterialStateProperty.resolveWith(
          (states) => _disabled(states) ? null : scheme.surface),
      overlayColor: MaterialStateProperty.resolveWith((states) {
        if (_disabled(states)) {
          return null;
        }
        return MD3StateOverlayColor(
          MaterialStateColor.resolveWith(
            (states) =>
                _pressedOrFocused(states) ? scheme.tertiary : scheme.primary,
          ),
          context.stateOverlayOpacity,
        ).resolve(states);
      }),
      side: MaterialStateProperty.resolveWith(
        (states) {
          if (_disabled(states)) {
            return null;
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

bool _disabled(Set<MaterialState> states) =>
    states.contains(MaterialState.disabled);
bool _pressedOrFocused(Set<MaterialState> states) =>
    states.contains(MaterialState.pressed) ||
    states.contains(MaterialState.focused);
