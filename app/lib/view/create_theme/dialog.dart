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

class CreateThemeDialog extends StatelessWidget {
  const CreateThemeDialog({
    Key? key,
    required this.controller,
  }) : super(key: key);
  final ControllerHandle<CreateThemeController> controller;

  @override
  Widget build(BuildContext context) => Actions(
        actions: {
          PopCommitingThemeIntent:
              PoppedCommitingThemeAction(controller.unwrap),
          PopNotCommitingThemeIntent: PoppedNotCommitingThemeAction(),
        },
        child: Builder(
          builder: (context) => _theme(
            context,
            child: _layout(
              context,
              child: _CreateThemeDialogBody(
                controller: controller,
              ),
            ),
          ),
        ),
      );

  Widget _layout(
    BuildContext context, {
    required Widget child,
  }) {
    final margin = context.sizeClass.minimumMargins;
    final saveButton = controller.unwrap.canSave
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
    switch (context.sizeClass) {
      case MD3WindowSizeClass.compact:
        return MD3FullScreenDialog(
          action: saveButton,
          title: Text(context.l10n.settings),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: margin,
              vertical: margin / 2,
            ),
            child: child,
          ),
        );
      case MD3WindowSizeClass.medium:
      case MD3WindowSizeClass.expanded:
        return MD3BasicDialog(
          title: Text(context.l10n.settings),
          content: child,
          scrollable: true,
          actions: [
            TextButton(
              onPressed: () => Actions.invoke(
                context,
                PopNotCommitingThemeIntent(),
              ),
              child: Text(context.l10n.cancel),
            ),
            saveButton,
          ],
        );
    }
  }

  Widget _theme(
    BuildContext context, {
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
    return Column(
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
          title: Text("Escuro"),
          value: controller.brightness
              .map((brightness) => brightness == Brightness.dark),
          setValue: (isDark) => controller.setBrightness(
            isDark ? Brightness.dark : Brightness.light,
          ),
        ),
        Text('Primary'),
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
                title: Text("Secondary"),
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
                title: Text("Background"),
                value: background,
                onChanged: controller.setBackground,
              ),
            )
            .build(),
      ],
    );
  }
}

class _DisablableHuePicker extends StatefulWidget {
  const _DisablableHuePicker({
    Key? key,
    required this.title,
    this.value,
    required this.onChanged,
  }) : super(key: key);
  final Widget title;
  final double? value;
  final ValueChanged<double?> onChanged;

  @override
  State<_DisablableHuePicker> createState() => __DisablableHuePickerState();
}

class __DisablableHuePickerState extends State<_DisablableHuePicker> {
  late double value;
  void initState() {
    super.initState();
    value = widget.value ?? 0.0;
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MD3ValueListenableSwitchTile(
            title: widget.title,
            value: (widget.value != null).asValueListenable,
            setValue: (willEnable) =>
                willEnable ? widget.onChanged(value) : widget.onChanged(null),
          ),
          HuePicker(
            current: value,
            onChanged: widget.value == null ? null : widget.onChanged,
          ),
        ],
      );
}

class _DisablableColorPicker extends StatefulWidget {
  const _DisablableColorPicker({
    Key? key,
    required this.title,
    this.value,
    required this.onChanged,
  }) : super(key: key);
  final Widget title;
  final Color? value;
  final ValueChanged<Color?> onChanged;

  @override
  State<_DisablableColorPicker> createState() => __DisablableColorPicker();
}

class __DisablableColorPicker extends State<_DisablableColorPicker> {
  late Color value;
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    value = widget.value ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MD3ValueListenableSwitchTile(
            title: widget.title,
            value: (widget.value != null).asValueListenable,
            setValue: (willEnable) =>
                willEnable ? widget.onChanged(value) : widget.onChanged(null),
          ),
          ColorPicker(
            pickerColor: value,
            onColorChanged: widget.value == null ? (_) {} : widget.onChanged,
          ),
        ],
      );
}
