import 'package:flutter/material.dart';

typedef Factory<T> = T Function();
typedef MemoWidgetBuilder<T> = Widget Function(BuildContext context, T value);

class Memo<T> extends StatefulWidget {
  const Memo({
    Key? key,
    required this.factory,
    required this.builder,
    this.valueKey,
  }) : super(key: key);

  final Factory<T> factory;
  final MemoWidgetBuilder<T> builder;
  final Key? valueKey;

  @override
  State<Memo<T>> createState() => _MemoState<T>();
}

class _MemoState<T> extends State<Memo<T>> {
  late T value;

  @override
  void initState() {
    super.initState();
    value = widget.factory();
  }

  @override
  void didUpdateWidget(Memo<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.valueKey != oldWidget.valueKey) {
      value = widget.factory();
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        value,
      );
}
