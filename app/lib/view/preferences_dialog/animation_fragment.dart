import 'package:app/module/animation.dart';
import 'package:app/util/l10n.dart';
import 'package:app/viewmodel/preferences_dialog.dart';
import 'package:app/widget/switch_tile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:utils/utils.dart';
import 'package:value_notifier/value_notifier.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension on AppLocalizations {
  String speedString(AnimationSpeed speed) {
    switch (speed) {
      case AnimationSpeed.disabled:
        return animation_speed_disabled;
      case AnimationSpeed.fastest:
        return animation_speed_fastest;
      case AnimationSpeed.fast:
        return animation_speed_fast;
      case AnimationSpeed.normal:
        return animation_speed_normal;
      case AnimationSpeed.slow:
        return animation_speed_slow;
    }
  }

  String speedSelectedS(AnimationSpeed speed) =>
      animation_speed_selected.replaceAll('%s', speedString(speed));
}

class PreferencesDialogAnimationFragment
    extends ControllerWidget<PreferencesDialogAnimationController> {
  PreferencesDialogAnimationFragment({
    Key? key,
    required ControllerHandle<PreferencesDialogAnimationController> controller,
  }) : super(
          key: key,
          controller: controller,
        );

  @override
  Widget build(
      ControllerContext<PreferencesDialogAnimationController> context) {
    ValueListenable<AnimationOptions> opts() => controller.animationOptions;
    final use = context.use;
    void setS(SelectionAnimationOptions options) =>
        controller.setSelection(options);
    void setT(TextAnimationOptions options) => controller.setText(options);
    void setSp(AnimationSpeed speed) => controller.setSpeed(speed);
    final l10n = context.l10n;
    final selection = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SwitchTile(
          value: use(opts().mguS((s) => s.size)),
          setValue: (v) => setS.compL(opts().value.e0.withSize)(v),
          title: Text(l10n.animation_selection_size),
        ),
        SwitchTile(
          value: use(opts().mguS((s) => s.color)),
          setValue: (v) => setS.compL(opts().value.e0.withColor)(v),
          title: Text(l10n.animation_selection_color),
        ),
      ],
    );
    final text = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SwitchTile(
          value: use(opts().mguT((s) => s.position)),
          setValue: (v) => setT.compL(opts().value.e1.withPosition)(v),
          title: Text(l10n.animation_text_position),
        ),
        SwitchTile(
          value: use(opts().mguT((s) => s.opacity)),
          setValue: (v) => setT.compL(opts().value.e1.withOpacity)(v),
          title: Text(l10n.animation_text_opacity),
        ),
        SwitchTile(
          value: use(opts().mguT((s) => s.color)),
          setValue: (v) => setT.compL(opts().value.e1.withColor)(v),
          title: Text(l10n.animation_text_color),
        ),
        SwitchTile(
          value: use(opts().mguT((s) => s.string)),
          setValue: (v) => setT.compL(opts().value.e1.withString)(v),
          title: Text(l10n.animation_text_text),
        ),
        SwitchTile(
          value: use(opts().mguT((s) => s.size)),
          setValue: (v) => setT.compL(opts().value.e1.withSize)(v),
          title: Text(l10n.animation_text_size),
        ),
      ],
    );
    final margin = context.sizeClass.minimumMargins;
    final gutter = margin / 2;
    final marginW = SizedBox.square(
      dimension: margin,
    );
    final gutterW = SizedBox.square(
      dimension: gutter,
    );
    final speed = use(opts().muSp())
        .map(
          (speed) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MD3Slider(
                value: speed.index.toDouble(),
                max: (AnimationSpeed.values.length - 1).toDouble(),
                onChanged: (v) => setSp(AnimationSpeed.values[v.round()]),
                divisions: AnimationSpeed.values.length,
              ),
              Text(l10n.speedSelectedS(speed))
            ],
          ),
        )
        .build();
    final headerStyle = context.textTheme.titleLarge;
    final sectionTitle = context.textTheme.titleMedium;
    return ListTileTheme(
      data: ListTileThemeData(contentPadding: EdgeInsets.only(left: 8)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.animation,
            style: headerStyle,
          ),
          gutterW,
          Text(
            l10n.animation_selection,
            style: sectionTitle,
          ),
          gutterW,
          selection,
          marginW,
          Text(
            l10n.animation_text,
            style: sectionTitle,
          ),
          gutterW,
          text,
          marginW,
          Text(
            l10n.animation_speed,
            style: sectionTitle,
          ),
          gutterW,
          speed,
        ],
      ),
    );
  }
}

extension on SelectionAnimationOptions {
  SelectionAnimationOptions withSize(bool size) =>
      SelectionAnimationOptions(size, color);
  SelectionAnimationOptions withColor(bool color) =>
      SelectionAnimationOptions(size, color);
}

extension on TextAnimationOptions {
  TextAnimationOptions withPosition(bool position) =>
      TextAnimationOptions(position, opacity, color, string, size);
  TextAnimationOptions withOpacity(bool opacity) =>
      TextAnimationOptions(position, opacity, color, string, size);
  TextAnimationOptions withColor(bool color) =>
      TextAnimationOptions(position, opacity, color, string, size);
  TextAnimationOptions withString(bool string) =>
      TextAnimationOptions(position, opacity, color, string, size);
  TextAnimationOptions withSize(bool size) =>
      TextAnimationOptions(position, opacity, color, string, size);
}

SelectionAnimationOptions _selection(AnimationOptions opts) => opts.e0;
TextAnimationOptions _text(AnimationOptions opts) => opts.e1;
AnimationSpeed _speed(AnimationOptions opts) => opts.e2;

extension _ on ValueListenable<AnimationOptions> {
  ValueListenable<T2> mguS<T2>(
    T2 Function(SelectionAnimationOptions) get,
  ) =>
      map(_selection).map(get).unique();
  ValueListenable<T2> mguT<T2>(
    T2 Function(TextAnimationOptions) get,
  ) =>
      map(_text).map(get).unique();
  ValueListenable<AnimationSpeed> muSp() => map(_speed).unique();
}
