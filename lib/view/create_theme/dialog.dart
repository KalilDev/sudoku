import 'package:app/module/theme.dart';
import 'package:app/util/l10n.dart';
import 'package:app/util/monadic.dart';
import 'package:app/viewmodel/create_theme.dart';
import 'package:app/widget/hue_picker.dart';
import 'package:app/widget/switch_tile.dart';
import 'package:app/widget/theme_override.dart';
import 'package:app/widget/value_listenable_text_field.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:value_notifier/value_notifier.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class PopCommitingThemeIntent extends Intent {
  const PopCommitingThemeIntent();
}

class PopNotCommitingThemeIntent extends Intent {
  const PopNotCommitingThemeIntent();
}

class PoppedNotCommitingThemeAction
    extends ContextAction<PopCommitingThemeIntent> {
  @override
  Object? invoke(PopCommitingThemeIntent intent, [BuildContext? context]) {
    Navigator.of(context!).pop<SudokuSeededTheme>();
  }
}

class PoppedCommitingThemeAction
    extends ContextAction<PopCommitingThemeIntent> {
  final CreateThemeController controller;

  PoppedCommitingThemeAction(this.controller);

  @override
  Object? invoke(PopCommitingThemeIntent intent, [BuildContext? context]) {
    Navigator.of(context!).pop<SudokuSeededTheme>(controller.finalTheme.value);
  }
}

abstract class CreateThemeDialog {
  static Widget builder(BuildContext context, Widget body) => Actions(
        actions: {
          PopCommitingThemeIntent: PoppedCommitingThemeAction(
              InheritedController.of<CreateThemeController>(context).unwrap),
          PopNotCommitingThemeIntent: PoppedNotCommitingThemeAction(),
        },
        child: Builder(
          builder: (context) => _theme(
            context,
            controller: InheritedController.of<CreateThemeController>(context),
            child: body,
          ),
        ),
      );
  static Widget buildTitle(BuildContext context) =>
      Text(context.l10n.create_theme);
  static Widget buildSave(BuildContext context) =>
      InheritedController.of<CreateThemeController>(context)
          .unwrap
          .canSave
          .map((canSave) => TextButton(
                onPressed: canSave
                    ? () => Actions.invoke(
                          context,
                          PopCommitingThemeIntent(),
                        )
                    : null,
                child: Text(context.l10n.save),
              ))
          .build();
  static Widget buildBody(BuildContext context) => _CreateThemeDialogBody(
        controller: InheritedController.of<CreateThemeController>(context),
      );

  static Widget _theme(
    BuildContext context, {
    required ControllerHandle<CreateThemeController> controller,
    required Widget child,
  }) =>
      controller.unwrap.overrideTheme
          .map((theme) => ThemeOverride(
                theme: theme,
                child: child,
              ))
          .build();
}

class _CreateThemeDialogBody extends ControllerWidget<CreateThemeController> {
  const _CreateThemeDialogBody({
    Key? key,
    required ControllerHandle<CreateThemeController> controller,
  }) : super(
          key: key,
          controller: controller,
        );

  static final ContextfulAction<InputDecoration> _nameFieldDecoration =
      readC.map(
    (context) => InputDecoration(
      filled: true,
      labelText: context.l10n.theme_name,
    ),
  );

  static Color _colorFromHue(double hue) =>
      HSVColor.fromAHSV(1, hue, 0.6, 0.6).toColor();

  static double _hueFromColor(Color color) => HSVColor.fromColor(color).hue;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          controller.name
              .map((name) => ValueTextField(
                    value: name,
                    onChanged: controller.setName,
                    maxLength: CreateThemeController.maxNameLength,
                    decoration: _nameFieldDecoration(context),
                  ))
              .build(),
          MD3ValueListenableSwitchTile(
            title: Text(context.l10n.theme_dark),
            value: controller.brightness
                .map((brightness) => brightness == Brightness.dark),
            setValue: (isDark) => controller.setBrightness(
              isDark ? Brightness.dark : Brightness.light,
            ),
          ),
          ListTile(title: Text(context.l10n.theme_primary)),
          controller.seed
              .map(_hueFromColor)
              .map(
                (seedHue) => HuePicker(
                  current: seedHue,
                  onChanged: (hue) => controller.setSeed(
                    _colorFromHue(hue),
                  ),
                ),
              )
              .build(),
          controller.secondarySeed
              .map((s) => s == null ? null : _hueFromColor(s))
              .map(
                (seedHue) => _DisablableHuePicker(
                  title: Text(context.l10n.theme_secondary),
                  defaultValue: _hueFromColor(context.colorScheme.secondary),
                  value: seedHue,
                  onChanged: (hue) => controller.setSecondarySeed(
                    hue == null ? null : _colorFromHue(hue),
                  ),
                ),
              )
              .build(),
          controller.background
              .map(
                (background) => _DisablableColorPicker(
                  title: Text(context.l10n.theme_background),
                  defaultValue: context.colorScheme.background,
                  value: background,
                  onChanged: controller.setBackground,
                ),
              )
              .build(),
        ],
      ),
    );
  }
}

class _DisablableHuePicker extends StatefulWidget {
  const _DisablableHuePicker({
    Key? key,
    required this.title,
    this.defaultValue,
    this.value,
    required this.onChanged,
  }) : super(key: key);
  final Widget title;
  final double? defaultValue;
  final double? value;
  final ValueChanged<double?> onChanged;

  @override
  State<_DisablableHuePicker> createState() => __DisablableHuePickerState();
}

class __DisablableHuePickerState extends State<_DisablableHuePicker> {
  late double lastValue;
  late bool usingDefault;
  double get defaultValue => widget.defaultValue ?? 0.0;
  double get value => usingDefault ? defaultValue : lastValue;
  @override
  void initState() {
    super.initState();
    lastValue = widget.value ?? defaultValue;
    usingDefault = widget.value == null;
  }

  @override
  void didUpdateWidget(_DisablableHuePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      lastValue = widget.value ?? defaultValue;
      usingDefault = widget.value == null;
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MD3SwitchTile(
            title: widget.title,
            value: widget.value != null,
            setValue: (willEnable) => willEnable
                ? widget.onChanged(usingDefault ? defaultValue : lastValue)
                : widget.onChanged(null),
          ),
          HuePicker(
            current: usingDefault ? defaultValue : widget.value!,
            onChanged: widget.value == null ? null : widget.onChanged,
          ),
        ],
      );
}

class _DisablableColorPicker extends StatefulWidget {
  const _DisablableColorPicker({
    Key? key,
    required this.title,
    this.defaultValue,
    this.value,
    required this.onChanged,
  }) : super(key: key);
  final Widget title;
  final Color? defaultValue;
  final Color? value;
  final ValueChanged<Color?> onChanged;

  @override
  State<_DisablableColorPicker> createState() => __DisablableColorPicker();
}

class __DisablableColorPicker extends State<_DisablableColorPicker> {
  late Color lastValue;
  late bool usingDefault;
  Color get defaultValue => widget.defaultValue ?? Colors.grey;
  Color get value => usingDefault ? defaultValue : lastValue;
  @override
  void initState() {
    super.initState();
    lastValue = widget.value ?? defaultValue;
    usingDefault = widget.value == null;
  }

  @override
  void didUpdateWidget(_DisablableColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      lastValue = widget.value ?? defaultValue;
      usingDefault = widget.value == null;
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MD3SwitchTile(
            title: widget.title,
            value: widget.value != null,
            setValue: (willEnable) =>
                willEnable ? widget.onChanged(value) : widget.onChanged(null),
          ),
          IgnorePointer(
            ignoring: widget.value == null,
            child: AnimatedOpacity(
              opacity: widget.value == null ? 0.6 : 1.0,
              duration: kThemeAnimationDuration,
              child: ColorPicker(
                portraitOnly: true,
                pickerColor: value,
                enableAlpha: false,
                labelTypes: [],
                onColorChanged:
                    widget.value == null ? (_) {} : widget.onChanged,
              ),
            ),
          ),
        ],
      );
}
