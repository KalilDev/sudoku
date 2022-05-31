import 'package:app/util/l10n.dart';
import 'package:app/view/home.dart';
import 'package:app/view/preferences_dialog.dart';
import 'package:app/viewmodel/home.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:value_notifier/value_notifier.dart';

class SudokuHomeView extends StatelessWidget {
  const SudokuHomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ControllerInjectorBuilder<HomeViewController>(
      factory: (_) => ControllerBase.create(() => HomeViewController()),
      builder: (context, controller) => MD3AdaptativeScaffold(
        appBar: MD3CenterAlignedAppBar(
          title: Text(context.l10n.sudoku),
          trailing: PreferencesButton(),
        ),
        body: MD3ScaffoldBody.noMargin(
          child: HomeView(
            controller: controller,
          ),
        ),
      ),
    );
  }
}
