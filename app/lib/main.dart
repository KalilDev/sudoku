import 'dart:typed_data';

import 'package:app/base/controller.dart';
import 'package:app/base/sudoku_data.dart';
import 'package:app/home_view/controller.dart';
import 'package:app/home_view/view.dart';
import 'package:app/view/controller.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:path_provider/path_provider.dart' as pp;
import 'package:value_notifier/value_notifier.dart';

import 'base/hive.dart';
import 'ui/view.dart';
import 'view/data.dart';

void main() async {
  Hive.registerAdapter(SudokuAppBoardStateAdapter());
  Hive.registerAdapter(ChangeNumberAdapter());
  Hive.registerAdapter(AddPossibilityAdapter());
  Hive.registerAdapter(RemovePossibilityAdapter());
  Hive.registerAdapter(CommitNumberAdapter());
  Hive.registerAdapter(ClearTileAdapter());
  Hive.registerAdapter(SudokuBoardIndexAdapter());
  Hive.init(await pp.getTemporaryDirectory().then((d)=>d.path));
  final fooBox = await Hive.openBox('foo');
  final bdr = SudokuAppBoardStateBuilder(9);
  bdr.solvedBoard = [
    Uint8List.fromList([8,4,2,7,1,3,6,9,5]),
    Uint8List.fromList([3,6,1,9,5,4,8,2,7]),
    Uint8List.fromList([5,7,9,6,8,2,4,3,1]),
    Uint8List.fromList([2,1,6,3,7,5,9,4,8]),
    Uint8List.fromList([3,5,8,2,9,6,7,1,3]),
    Uint8List.fromList([7,9,3,1,4,8,5,6,2]),
    Uint8List.fromList([9,8,5,4,2,1,3,7,6]),
    Uint8List.fromList([1,3,4,8,6,7,2,5,9]),
    Uint8List.fromList([6,2,7,5,3,9,1,8,4]),
  ];
  bdr.fixedNumbers = [
    Uint8List.fromList([0,0,0,7,1,3,6,9,5]),
    Uint8List.fromList([0,0,0,9,5,4,8,2,7]),
    Uint8List.fromList([0,0,0,6,8,2,4,3,1]),
    Uint8List.fromList([0,0,0,3,7,5,9,4,8]),
    Uint8List.fromList([0,0,0,2,9,6,7,1,3]),
    Uint8List.fromList([0,0,0,1,4,8,5,6,2]),
    Uint8List.fromList([0,0,0,4,2,1,3,7,6]),
    Uint8List.fromList([0,0,0,8,6,7,2,5,9]),
    Uint8List.fromList([0,0,0,5,3,9,1,8,4]),
  ];
  bdr.currentNumbers = [
    Uint8List.fromList([8,4,2,0,0,0,0,0,0]),
    Uint8List.fromList([3,6,1,0,0,0,0,0,0]),
    Uint8List.fromList([5,7,9,0,0,0,0,0,0]),
    Uint8List.fromList([0,0,0,0,0,0,0,0,0]),
    Uint8List.fromList([0,0,0,0,0,0,0,0,0]),
    Uint8List.fromList([0,0,0,0,0,0,0,0,0]),
    Uint8List.fromList([0,0,0,0,0,0,0,0,0]),
    Uint8List.fromList([0,0,0,0,0,0,0,0,0]),
    Uint8List.fromList([0,0,0,0,0,0,0,0,0]),
  ];
  bdr.currentPossibilities = [
    [[],[],[],[],[],[],[],[],[]],
    [[],[],[],[],[],[],[],[],[]],
    [[],[],[],[],[],[],[],[],[]],
    [[],[],[],[],[],[],[],[],[]],
    [[],[],[],[],[],[],[],[],[]],
    [[],[],[],[],[],[],[],[],[]],
    [[1],[2],[3],[],[],[],[],[],[]],
    [[],[],[],[],[],[],[],[],[]],
    [[1,2],[1,2,3],[1,2,3,4],[],[],[],[],[],[]],
  ];
  final boardState = bdr.build();
  final m = tileMatrixFromState(boardState);
  controller = SudokuViewController(SudokuController.fromInitialState(fooBox, boardState), 9);
  controller.init();
  
  runPlatformThemedApp(
    const MyApp(),
    initialOrFallback: () => PlatformPalette.fallback(primaryColor: Color(0xDEADBEEF)),
  );
}

late final SudokuViewController controller;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MD3Themes(
      monetThemeForFallbackPalette: MonetTheme.baseline3p,
      builder:(context, light, dark) =>  MaterialApp(
        title: 'Flutter Demo',
        theme: light,
        darkTheme: dark,
        home: const MyHomePage(),
      ),
    );
  }
}

final homeController = ControllerBase.create(() => HomeViewController());

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MD3AdaptativeScaffold(
      appBar: const MD3CenterAlignedAppBar(
        title: Text("Sudoku"),
      ),
      body: MD3ScaffoldBody.noMargin(
        child: HomeView(
          controller: homeController.handle,
        ),
      ),
    );
  }
}
