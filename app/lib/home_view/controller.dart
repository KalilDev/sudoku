import 'package:app/base/controller.dart';
import 'package:app/base/sudoku_db.dart';
import 'package:app/home_view/data.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:utils/utils.dart';
import 'package:value_notifier/value_notifier.dart';

import '../generation/impl/data.dart';
import 'home_db.dart';

class CreateSudoku {
  final int sideSqrt;
  final SudokuDifficulty difficulty;
  final SudokuDb db;

  CreateSudoku(this.sideSqrt, this.difficulty, this.db);
}

class ResumeSudoku {
  final int sideSqrt;
  final SudokuDifficulty difficulty;
  final SudokuDb db;

  ResumeSudoku(this.sideSqrt, this.difficulty, this.db);
}

typedef SudokuNavigationPopInfo
    = Tuple<SudokuNavigationTarget, SudokuController>;

// This is actually quite smart, because HomeViewController controls the db, it
// can listen to changes on it and use the info to update itself.
//
// data SudokuNavigationTarget = CreateSudoku Int SudokuDifficulty Db
//                             | ResumeSudoku Int Db
typedef SudokuNavigationTarget = Either<CreateSudoku, ResumeSudoku>;

class HomeViewController extends ControllerBase<HomeViewController> {
  final ValueNotifier<SudokuHomeDb?> _db = ValueNotifier(null);
  final EventNotifier<int> _didChangeSideSqrt = EventNotifier();
  final EventNotifier<SudokuDifficulty> _didChangeDifficulty = EventNotifier();
  final EventNotifier<SidesInfo> _didChangeSidesInfo = EventNotifier();
  final EventNotifier<SudokuNavigationTarget> _didRequestNavigation =
      EventNotifier();
  final EventNotifier<SudokuNavigationPopInfo> _didPopTarget = EventNotifier();
  final ActionNotifier _didContinue = ActionNotifier();
  final ActionNotifier _didStartNewGame = ActionNotifier();

  ValueListenable<SudokuHomeDb?> get db => _db.view();
  ValueListenable<int?> get didChangeSideSqrt => _didChangeSideSqrt.view();
  ValueListenable<SidesInfo?> get didChangeSidesInfo =>
      _didChangeSidesInfo.view();
  ValueListenable<SudokuDifficulty?> get didChangeDifficulty =>
      _didChangeDifficulty.view();
  ValueListenable<SudokuNavigationTarget> get didRequestNavigation =>
      _didRequestNavigation.viewNexts();
  ValueListenable<SudokuNavigationPopInfo> get didPopTarget =>
      _didPopTarget.viewNexts();
  ValueListenable<void> get didContinue => _didContinue.view();
  ValueListenable<void> get didStartNewGame => _didStartNewGame.view();

  ValueListenable<bool> get isLocked => db.map((db) => db == null);

  ValueListenable<bool> get canContinue => viewData.map((view) {
        final activeSideSqrt = view.e1.sideSqrt;
        final activeDifficulty = view.e1.difficulty;
        final canContinueMap = view.e0.info;
        return canContinueMap[activeSideSqrt]![activeDifficulty]!;
      });

  static const int _defaultSideSqrt = 3;
  static const SudokuDifficulty _defaultDifficulty = SudokuDifficulty.medium;
  static const SidesInfo _defaultHomeSideInfoWithHoles =
      SidesInfo({2: {}, 3: {}, 4: {}});

  late final ValueListenable<int> _sideSqrt =
      db.bind((db) => didChangeSideSqrt.map((e) => e == null
          ? db == null
              ? _defaultSideSqrt
              : sudokuHomeDbGetActiveSideSqrtOr(db, _defaultSideSqrt)
          : e));
  ValueListenable<int> get sideSqrt => _sideSqrt.view();

  late final ValueListenable<SudokuDifficulty> _difficulty = db.bind((db) =>
      didChangeDifficulty.map((change) => db == null
          ? _defaultDifficulty
          : change ??
              sudokuHomeDbGetActiveDifficultyOr(db, _defaultDifficulty)));
  ValueListenable<SudokuDifficulty> get difficulty => _difficulty.view();

  ValueListenable<ActiveInfo> get activeInfo =>
      ActiveInfo.new.curry.asValueListenable >> difficulty >> sideSqrt;

  late final ValueListenable<SidesInfo> _sidesInfo = db
      .bind((db) => didChangeSidesInfo.map((change) => db == null
          ? _defaultHomeSideInfoWithHoles
          : change ??
              sudokuHomeDbGetSidesInfoOr(db, _defaultHomeSideInfoWithHoles)))
      .map((sideInfoWithHoles) => sideInfoWithHoles.info.map((k, v) => MapEntry(
            k,
            sudokuHomeItemFillRemaining(v),
          )))
      .map(SidesInfo.new);

  ValueListenable<SidesInfo> get sidesInfo => _sidesInfo.view();

  ValueListenable<SudokuHomeViewData> get viewData =>
      SudokuHomeViewData.new.curry.asValueListenable >> sidesInfo >> activeInfo;

  late final startNewGame = _didStartNewGame.notify;
  late final continueA = _didContinue.notify;
  late final changeSideSqrt = _didChangeSideSqrt.add;
  late final changeDifficulty = _didChangeDifficulty.add;
  late final popTarget = _didPopTarget.add;

  static String boxNameFromSideSqrtAndDifficulty(
      int sideSqrt, SudokuDifficulty difficulty) {
    final side = sideSqrt * sideSqrt;
    return 'sudoku-board-db-$side-${difficulty.name}';
  }

  void _onStartNewGame(_) async {
    final sideSqrt = this.sideSqrt.value;
    final difficulty = this.difficulty.value;
    final db = await sudokuDbOpen(
        boxNameFromSideSqrtAndDifficulty(sideSqrt, difficulty));
    _didRequestNavigation.add(
        SudokuNavigationTarget.left(CreateSudoku(sideSqrt, difficulty, db)));
  }

  void _onContinue(_) async {
    final sideSqrt = this.sideSqrt.value;
    final difficulty = this.difficulty.value;
    final db = await sudokuDbOpen(
        boxNameFromSideSqrtAndDifficulty(sideSqrt, difficulty));
    _didRequestNavigation.add(
        SudokuNavigationTarget.right(ResumeSudoku(sideSqrt, difficulty, db)));
  }

  Future<void> _onChangeSideSqrt(int? sideSqrt) {
    final newInfo = ActiveInfo(difficulty.value, sideSqrt!);
    return sudokuHomeDbStoreActiveInfo(db.value!, newInfo);
  }

  Future<void> _onChangeDifficulty(SudokuDifficulty? difficulty) {
    final newInfo = ActiveInfo(difficulty!, sideSqrt.value);
    return sudokuHomeDbStoreActiveInfo(db.value!, newInfo);
  }

  Future<void> _onChangeHomeSideInfo(SidesInfo? info) =>
      sudokuHomeDbStoreSidesInfo(db.value!, info!);

  void _onPopTarget(SudokuNavigationPopInfo popInfo) async {
    final target = popInfo.left;
    final sudokuController = popInfo.right;
    final db = target.visit(
      left: (create) => create.db,
      right: (resume) => resume.db,
    );
    final sideSqrt = target.visit(
      left: (create) => create.sideSqrt,
      right: (resume) => resume.sideSqrt,
    );
    final difficulty = target.visit(
      left: (create) => create.difficulty,
      right: (resume) => resume.difficulty,
    );
    final canContinue = !sudokuController.isFinished.value;
    final oldAtSideSqrt = sidesInfo.value.info[sideSqrt]!;
    final newAtSideSqrt = Map.of(oldAtSideSqrt)..[difficulty] = canContinue;
    _didChangeSidesInfo.add(
      SidesInfo(Map.of(sidesInfo.value.info)..[sideSqrt] = newAtSideSqrt),
    );
    // Ensure we flush the db to disk
    if (canContinue) {
      await sudokuDbFlush(db);
    }
  }

  void init() {
    super.init();
    _initDb();
    didStartNewGame.tap(_onStartNewGame);
    didContinue.tap(_onContinue);
    didChangeSideSqrt.tap(_onChangeSideSqrt);
    didChangeDifficulty.tap(_onChangeDifficulty);
    sidesInfo.tap(_onChangeHomeSideInfo);
    didPopTarget.tap(_onPopTarget);
  }

  void dispose() {
    sudokuHomeDbClose(db.value!);
    IDisposable.disposeAll([
      _db,
      _didChangeSideSqrt,
      _didChangeDifficulty,
      _didChangeSidesInfo,
      _didRequestNavigation,
      _didPopTarget,
      _didContinue,
      _didStartNewGame,
      _sideSqrt,
      _difficulty,
      _sidesInfo,
    ]);
    super.dispose();
  }

  Future<void> _initDb() async {
    print("init db");
    final db = await sudokuHomeDbOpen();
    print("loaded db");
    _db.value = db;
    print("set db");
  }
}
