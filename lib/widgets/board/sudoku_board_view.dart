import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku/core/sudoku_state.dart';
import 'package:sudoku/presentation/preferences_bloc.dart';
import 'package:sudoku/presentation/sudoku_bloc/bloc.dart';
import '../prefs_sheet.dart';
import './numbers.dart';
import './board.dart';
import './actions.dart';
class SudokuBoardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreferencesBloc, PrefsState>(
        condition: (prev, next) =>
            prev.animationOptions != next.animationOptions,
        builder: (BuildContext context, PrefsState preferences) =>
            BlocBuilder<SudokuBloc, SudokuSnapshot>(
                builder: (BuildContext context, SudokuSnapshot state) => LayoutBuilder(builder: (context, constraints) {
              final finished = state.validationState == Validation.valid;
              final isPortrait = constraints.biggest.aspectRatio <= 1;
              final appBar = AppBar(
                      title: Text("Sudoku"),
                      actions: [
                        IconButton(
                            icon: Icon(Icons.settings),
                            onPressed: () => openPrefs(context))
                      ],
                    );
              final sudokuActions = Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: SudokuActions(
                            canRewind: state.canRewind,
                            markType: state.markType,
                            isPortrait: isPortrait));
              
              final numberSize = SudokuNumbers.buttonSize;

              final numberConstraints = BoxConstraints(
                minHeight: isPortrait ? numberSize : double.infinity,
                maxHeight: isPortrait ? 3 * numberSize : double.infinity,
                minWidth: !isPortrait ? numberSize : double.infinity,
                maxWidth: !isPortrait ? 3 * numberSize : double.infinity,
              );
              
              final children = [
                    Expanded(
                      child: Padding(
                          padding: EdgeInsets.all(2.0),
                          child: SudokuBoard(
                            state: state.squares,
                            animationOptions:
                                preferences.animationOptions,
                          ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: numberConstraints,
                      child: SudokuNumbers(
                        state: state.numbers,
                        isPortrait: isPortrait),
                    ),
                  ),
                  if (!isPortrait) sudokuActions
                ];




              return Stack(
                fit: StackFit.expand,
                children: [
                  Scaffold(
                    appBar: appBar,
                    bottomNavigationBar: isPortrait ? sudokuActions : null,
                    body: state.isLoading
                        ? Center(child: CircularProgressIndicator())
                        : !isPortrait
                                ? Row(children: children)
                                : Column(children: children),
                          
                  ),
                  Center(
                      child: AnimatedContainer(
                          duration: Duration(milliseconds: 400),
                          height: finished ? null : 0,
                          width: finished ? null : 0,
                          color: finished
                              ? Colors.black87
                              : Colors.black.withAlpha(0),
                          child: AnimatedSwitcher(
                              duration: Duration(milliseconds: 200),
                              child: finished
                                  ? Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AlertDialog(
                                              title: Text("Parabéns"),
                                              content: Text(
                                                  "Você conseguiu resolver esse sudoku!"),
                                              actions: [
                                                FlatButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: Text("Continuar"))
                                              ])
                                        ],
                                      ),
                                    )
                                  : SizedBox()))),
                ],
              );
            })));
  }
}
