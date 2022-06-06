import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';

class SiderWithTitle extends StatelessWidget {
  const SiderWithTitle({
    Key? key,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    required this.label,
    this.onChanged,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    required this.semanticFormatterCallback,
  }) : super(key: key);

  final double value;
  final double min;
  final double max;
  final int? divisions;
  final Widget label;
  final ValueChanged<double>? onChanged;
  final CrossAxisAlignment crossAxisAlignment;
  final String Function(double) semanticFormatterCallback;

  @override
  Widget build(BuildContext context) {
    final margin = context.sizeClass.minimumMargins;
    final gutter = margin / 2;
    return MergeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          BlockSemantics(child: label),
          SizedBox(height: gutter),
          MD3Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            semanticFormatterCallback: semanticFormatterCallback,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
