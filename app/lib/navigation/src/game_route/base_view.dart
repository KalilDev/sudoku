import 'package:app/module/base.dart';
import 'package:app/navigation/src/game_route/data.dart';
import 'package:app/sudoku_generation/sudoku_generation.dart';
import 'package:app/util/l10n.dart';
import 'package:app/view/home.dart';
import 'package:app/view/preferences_dialog.dart';
import 'package:app/view/sudoku_generation.dart';
import 'package:app/viewmodel/sudoku_board.dart';
import 'package:app/viewmodel/sudoku_generation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:value_notifier/value_notifier.dart';

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
