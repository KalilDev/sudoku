import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:value_notifier/value_notifier.dart';

class MD3ValueListenableSwitchTile extends StatelessWidget {
  const MD3ValueListenableSwitchTile({
    Key? key,
    required this.value,
    required this.setValue,
    required this.title,
    this.subtitle,
  }) : super(key: key);
  final ValueListenable<bool> value;
  final ValueSetter<bool> setValue;
  final Widget? title;
  final Widget? subtitle;

  @override
  Widget build(BuildContext context) => value
      .map(
        (value) => MD3SwitchTile(
          value: value,
          setValue: setValue,
          title: title,
          subtitle: subtitle,
        ),
      )
      .build();
}

class MD3SwitchTile extends StatelessWidget {
  const MD3SwitchTile({
    Key? key,
    required this.value,
    required this.setValue,
    required this.title,
    this.subtitle,
  }) : super(key: key);
  final bool value;
  final ValueSetter<bool> setValue;
  final Widget? title;
  final Widget? subtitle;

  @override
  Widget build(BuildContext context) => MergeSemantics(
        child: ListTile(
          onTap: () => setValue(!value),
          title: title,
          subtitle: subtitle,
          trailing: MD3Switch(
            value: value,
            onChanged: setValue,
          ),
        ),
      );
}
