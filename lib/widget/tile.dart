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

class MD3ListTile extends StatelessWidget {
  const MD3ListTile({
    Key? key,
    this.onTap,
    this.title,
    this.subtitle,
    this.trailing,
    this.contentPadding,
  }) : super(key: key);
  final VoidCallback? onTap;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final EdgeInsets? contentPadding;

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: onTap,
        title: title != null
            ? DefaultTextStyle(
                style: context.textTheme.titleMedium.copyWith(
                  color: context.colorScheme.onSurface,
                ),
                child: title!,
              )
            : null,
        subtitle: subtitle != null
            ? DefaultTextStyle(
                style: context.textTheme.labelLarge.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                child: subtitle!,
              )
            : null,
        trailing: trailing != null
            ? IconTheme.merge(
                data: IconThemeData(
                  color: context.colorScheme.onSurface,
                  opacity: 1,
                ),
                child: trailing!,
              )
            : null,
        contentPadding: contentPadding,
      );
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
        child: MD3ListTile(
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
