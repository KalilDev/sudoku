import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';

class HuePicker extends StatelessWidget {
  const HuePicker({
    Key? key,
    required this.current,
    required this.onChanged,
  }) : super(key: key);

  final double current;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: TweenAnimationBuilder<double>(
              tween: Tween(
                end: context.theme.brightness == Brightness.light ? 0.0 : 1.0,
              ),
              duration: kThemeChangeDuration,
              builder: (context, brightness, _) => DecoratedBox(
                decoration: _HuePickerDecoration(
                  current: current,
                  brightness: brightness,
                ),
                child: const SizedBox(
                  height: 24.0,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          MD3Slider(
            min: 0.0,
            max: 360.0,
            value: current,
            onChanged: onChanged,
          ),
        ],
      );
}

class _HuePickerDecoration extends Decoration {
  final double current;
  final double brightness;

  const _HuePickerDecoration({
    required this.current,
    required this.brightness,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _HuePickerDecorationPainter(current, brightness);
}

class _HuePickerDecorationPainter extends BoxPainter {
  final double current;
  final double brightness;

  _HuePickerDecorationPainter(this.current, this.brightness);

  static const _stepCount = 36;
  static const _hsvSaturation = 0.8;
  static const _lightHsvValue = 0.9;
  static const _darkHsvValue = 0.65;
  static final _hueGradientSteps = List.generate(
    _stepCount,
    (i) => i / _stepCount,
  );
  static final _lightHueGradientColors = List.generate(
    _stepCount,
    (i) {
      final hue = (i / _stepCount) * 360;
      return HSVColor.fromAHSV(
        1,
        hue,
        _hsvSaturation,
        _lightHsvValue,
      ).toColor();
    },
  );
  static final _darkHueGradientColors = List.generate(
    _stepCount,
    (i) {
      final hue = (i / _stepCount) * 360;
      return HSVColor.fromAHSV(
        1,
        hue,
        _hsvSaturation,
        _darkHsvValue,
      ).toColor();
    },
  );

  @override
  void paint(
    Canvas canvas,
    Offset startOffset,
    ImageConfiguration configuration,
  ) {
    final size = configuration.size!;
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(
        startOffset & size, Radius.circular(size.height / 2)));
    final hueGradientColors = List.generate(
      _stepCount,
      (i) => Color.lerp(
        _lightHueGradientColors[i],
        _darkHueGradientColors[i],
        brightness,
      )!,
    );
    final gradientPaint = Paint()
      ..shader = ui.Gradient.linear(
        startOffset.translate(0, size.height / 2),
        startOffset.translate(size.width, size.height / 2),
        hueGradientColors,
        _hueGradientSteps,
      );
    canvas.drawPaint(gradientPaint);
    final currentContrasting = HSVColor.fromAHSV(
      1,
      current > 180.0 ? current - 180 : current + 180,
      _hsvSaturation,
      ui.lerpDouble(
        _lightHsvValue,
        _darkHsvValue,
        brightness,
      )!,
    ).toColor();
    final cursorPaint = Paint()
      ..color = currentContrasting
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;
    final cursorOffset = (current / 360.0) * size.width;
    final cursorStart = startOffset.translate(cursorOffset, 0);
    canvas.drawLine(
      cursorStart.translate(0, size.height / 4),
      cursorStart.translate(0, 3 * size.height / 4),
      cursorPaint,
    );
    canvas.restore();
  }
}
