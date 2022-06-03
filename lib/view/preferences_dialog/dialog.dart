import 'package:app/util/l10n.dart';
import 'package:app/viewmodel/preferences_dialog.dart';
import 'package:app/widget/theme_override.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:value_notifier/value_notifier.dart';

import 'animation_fragment.dart';
import 'flutter_intents.dart';
import 'theme_fragment.dart';

abstract class PreferencesDialog extends StatelessWidget {
  static Widget builder(BuildContext context, Widget body) => Actions(
        actions: {
          PopCommitingPreferencesIntent: PoppedCommitingPreferencesAction(
              InheritedController.of<PreferencesDialogController>(context)
                  .unwrap),
          PopNotCommitingPreferencesIntent:
              PoppedNotCommitingPreferencesAction(),
        },
        child: Builder(
          builder: (context) => _theme(
            context,
            controller:
                InheritedController.of<PreferencesDialogController>(context),
            child: body,
          ),
        ),
      );
  static Widget buildBody(BuildContext context) => _PreferencesDialogBody(
        controller:
            InheritedController.of<PreferencesDialogController>(context),
      );
  static Widget buildTitle(BuildContext context) => Text(context.l10n.settings);
  static Widget buildSave(BuildContext context) => TextButton(
        onPressed: () => Actions.invoke(
          context,
          PopCommitingPreferencesIntent(),
        ),
        child: Text(context.l10n.save),
      );

  static Widget _theme(
    BuildContext context, {
    required ControllerHandle<PreferencesDialogController> controller,
    required Widget child,
  }) =>
      controller.unwrap.currentTheme
          .map((theme) => ThemeOverride(
                theme: theme,
                child: child,
              ))
          .build();
}

class PoppedCommitingPreferencesAction
    extends ContextAction<PopCommitingPreferencesIntent> {
  final PreferencesDialogController controller;

  PoppedCommitingPreferencesAction(this.controller);
  @override
  Object? invoke(PopCommitingPreferencesIntent intent,
      [BuildContext? context]) {
    Navigator.of(context!)
        .pop<PreferencesDialogResult>(controller.buildResult());
  }
}

class PoppedNotCommitingPreferencesAction
    extends ContextAction<PopNotCommitingPreferencesIntent> {
  @override
  Object? invoke(PopNotCommitingPreferencesIntent intent,
      [BuildContext? context]) {
    Navigator.of(context!).pop<PreferencesDialogResult>();
  }
}

class _PreferencesDialogBody extends StatelessWidget {
  const _PreferencesDialogBody({
    Key? key,
    required this.controller,
  }) : super(key: key);
  final ControllerHandle<PreferencesDialogController> controller;

  @override
  Widget build(BuildContext context) {
    final margin = context.sizeClass.minimumMargins;
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PreferencesDialogThemeFragment(controller: controller.unwrap.theme),
          SizedBox(height: margin),
          PreferencesDialogAnimationFragment(
              controller: controller.unwrap.animation),
        ],
      ),
    );
  }
}
