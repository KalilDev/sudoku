import 'dart:ui' as ui;

import 'package:flutter/material.dart';

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
          DecoratedBox(
            decoration: _HuePickerDecoration(
              current: current,
            ),
            child: SizedBox(height: 24.0, width: double.infinity),
          ),
          Slider(
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

  _HuePickerDecoration({
    required this.current,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _HuePickerDecorationPainter(current);
}

class _HuePickerDecorationPainter extends BoxPainter {
  final double current;

  _HuePickerDecorationPainter(this.current);

  static const _stepCount = 36;
  static const _hsvSaturation = 1.0;
  static const _hsvValue = 1.0;
  static final _hueGradientSteps = List.generate(
    _stepCount,
    (i) => _stepCount / i,
  );
  static final _hueGradientColors = List.generate(
    _stepCount,
    (i) =>
        HSVColor.fromAHSV(1, i.toDouble(), _hsvSaturation, _hsvValue).toColor(),
  );

  @override
  void paint(
    Canvas canvas,
    Offset startOffset,
    ImageConfiguration configuration,
  ) {
    final size = configuration.size!;
    final gradientPaint = Paint()
      ..shader = ui.Gradient.linear(
        startOffset,
        startOffset.translate(size.width, 0),
        _hueGradientColors,
        _hueGradientSteps,
      );
    canvas.save();
    canvas.clipRect(startOffset & size);
    canvas.drawPaint(gradientPaint);
    canvas.restore();
    final currentContrasting = HSVColor.fromAHSV(
            1,
            current > 180.0 ? current - 180 : current + 180,
            _hsvSaturation,
            _hsvValue)
        .toColor();
    final cursorPaint = Paint()
      ..color = currentContrasting
      ..strokeCap = StrokeCap.round;
    final cursorOffset = (current / 360.0) * size.width;
    final cursorStart = startOffset.translate(cursorOffset, 0);
    canvas.drawLine(
      cursorStart,
      cursorStart.translate(0, size.height),
      cursorPaint,
    );
  }
}
