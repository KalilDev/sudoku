library app.view.preferences_dialog;

import 'package:app/util/l10n.dart';
import 'package:flutter/material.dart';

import 'preferences_dialog/show_dialog.dart';

export 'preferences_dialog/show_dialog.dart';

class PreferencesButton extends StatelessWidget {
  const PreferencesButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Tooltip(
        message: context.l10n.settings,
        child: IconButton(
          onPressed: () => showPreferencesDialogAndUpdateModules(context),
          icon: const Icon(Icons.settings_outlined),
        ),
      );
}
