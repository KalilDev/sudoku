import 'package:app/util/l10n.dart';
import 'package:app/view/preferences_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';

class BaseSudokuView extends StatelessWidget {
  const BaseSudokuView({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MD3AdaptativeScaffold(
      appBar: MD3SmallAppBar(
        title: Text(context.l10n.sudoku),
        actions: [
          PreferencesButton(),
        ],
      ),
      body: MD3ScaffoldBody.noMargin(
        child: child,
      ),
    );
  }
}
