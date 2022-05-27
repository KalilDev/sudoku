import 'dart:typed_data';

import 'package:app/base/controller.dart';
import 'package:app/base/sudoku_data.dart';
import 'package:app/base/sudoku_db.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  sudokuDbInitialize();
  Hive.registerAdapter(SudokuHomeInfoAdapter());
  Hive.registerAdapter(SudokuHomeItemAdapter());
  Hive.registerAdapter(SudokuDifficultyAdapter());
  Hive.init(await pp.getTemporaryDirectory().then((d) => d.path));

  runPlatformThemedApp(
    const MyApp(),
    initialOrFallback: () =>
        PlatformPalette.fallback(primaryColor: Color(0xDEADBEEF)),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MD3Themes(
      monetThemeForFallbackPalette: MonetTheme.baseline3p,
      builder: (context, light, dark) => MaterialApp(
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
