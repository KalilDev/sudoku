import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_presentation/sudoku_bloc.dart';
import 'package:sudoku_presentation/preferences_bloc.dart';
import 'package:sudoku_core/sudoku_core.dart';
import '../prefs_sheet.dart';
import './numbers.dart';
import './board.dart';
import './actions.dart';

class SudokuBoardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreferencesBloc, PrefsState>(
        condition: (prev, next) {
          if (prev is PrefsSnap && next is PrefsSnap) {
            return prev.animationOptions != next.animationOptions;
          }
          return true;
        },
        builder: (BuildContext context, PrefsState _prefsState) =>
            BlocBuilder<SudokuBloc, SudokuBlocState>(
                builder: (BuildContext context, SudokuBlocState _state) => LayoutBuilder(builder: (context, constraints) {
              final appBar = AppBar(
                      title: Text("Sudoku"),
                      actions: [
                        IconButton(
                            icon: Icon(Icons.settings),
                            onPressed: () => openPrefs(context))
                      ],
                    );
              if (_state is SudokuLoadingState || _prefsState is LoadingPrefsState)   {
                return 
                    Scaffold(
                      appBar: appBar,
                      body: Center(child: CircularProgressIndicator())
                );
              }

              if (_state is SudokuErrorState) {
                return Scaffold(
                  appBar: appBar,
                  body: Center(child: Column(mainAxisSize: MainAxisSize.min,children: [
                  Text(_state.userFriendlyMessage),
                  Text("Mensagem do erro: ${_state.message}")
                ],),),);
              }
              final state = _state as SudokuSnapshot;
              final prefsState = _prefsState as PrefsSnap;
              if (state.validationState == Validation.correct && !state.wasDeleted) {
                BlocProvider.of<SudokuBloc>(context).add(DeleteSudoku());
              }
              if (state.wasDeleted) {
                void pop([dynamic _]) => Navigator.of(context).pop();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showDialog<void>(context: context, builder: (BuildContext context) {
                    return AlertDialog(title: Text("Parabéns"), content: Text("Você completou o Sudoku!"), actions: [
                      FlatButton(onPressed: pop, child: Text("Continuar"))
                    ]);
                  }).then(pop);
                });
              }

              final isPortrait = constraints.biggest.aspectRatio <= 1;
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
                                prefsState.animationOptions,
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




              return 
                  Scaffold(
                    appBar: appBar,
                    bottomNavigationBar: isPortrait ? sudokuActions : null,
                    body: !isPortrait
                              ? Row(children: children)
                              : Column(children: children),
              );
            })));
  }
}
