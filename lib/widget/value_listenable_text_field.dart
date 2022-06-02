import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:value_notifier/value_notifier.dart';

class ValueListenableTextField extends StatelessWidget {
  const ValueListenableTextField({
    Key? key,
    required this.value,
    required this.onChanged,
    this.decoration,
    this.maxLength,
  }) : super(key: key);
  final ValueListenable<String> value;
  final ValueChanged<String> onChanged;
  final InputDecoration? decoration;
  final int? maxLength;

  @override
  Widget build(BuildContext context) => value
      .map((value) => ValueTextField(
            value: value,
            onChanged: onChanged,
            decoration: decoration,
            maxLength: maxLength,
          ))
      .build();
}

class ValueTextField extends StatefulWidget {
  const ValueTextField({
    Key? key,
    required this.value,
    required this.onChanged,
    this.decoration,
    this.maxLength,
  }) : super(key: key);
  final String value;
  final ValueChanged<String> onChanged;
  final InputDecoration? decoration;
  final int? maxLength;

  @override
  State<ValueTextField> createState() => _ValueTextFieldState();
}

class _ValueTextFieldState extends State<ValueTextField> {
  late final TextEditingController controller;
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value);
    controller.addListener(_onControllerChange);
  }

  void _onControllerChange() {
    if (widget.value == controller.text) {
      return;
    }
    widget.onChanged(controller.text);
  }

  void didUpdateWidget(ValueTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == controller.text) {
      return;
    }
    controller.text = widget.value;
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        maxLength: widget.maxLength,
        decoration: widget.decoration,
      );
}
