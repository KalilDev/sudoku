import 'package:app/base/controller.dart';
import 'package:app/home_view/data.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:utils/utils.dart';
import 'package:value_notifier/value_notifier.dart';

import '../generation/impl/data.dart';

Future<SudokuHomeDb> sudokuHomeDbOpen() => Hive.openBox('sudoku-home');
SudokuDifficulty sudokuDbGetActiveDifficutyOr(
        SudokuHomeDb db, SudokuDifficulty difficulty) =>
    sudokuDbGetOtherInfo(db)?.right ?? difficulty;

int sudokuDbGetActiveSideSqrtOr(SudokuHomeDb db, int sideSqrt) =>
    sudokuDbGetOtherInfo(db)?.left ?? sideSqrt;

SudokuHomeSideInfo sudokuDbGetSudokuHomeSideInfoOr(
        SudokuHomeDb db, SudokuHomeSideInfo info) =>
    sudokuDbGetSudokuHomeSideInfo(db) ?? info;

OtherInfo? sudokuDbGetOtherInfo(SudokuHomeDb db) => db.get('other-info')?.visit(
      a: (_) => throw StateError(
          "Expected it to be OtherInfo, but it is SudokuHomeSideInfo"),
      b: (otherInfo) => otherInfo,
    );

SudokuHomeSideInfo? sudokuDbGetSudokuHomeSideInfo(SudokuHomeDb db) =>
    db.get('home-side-info')?.visit(
          a: (sideInfo) => sideInfo,
          b: (_) => throw StateError(
              "Expected it to be SudokuHomeSideInfo, but it is OtherInfo"),
        );

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
  final EventNotifier<SudokuHomeSideInfo> _didChangeSideInfo = EventNotifier();
  final EventNotifier<SudokuNavigationTarget> _didRequestNavigation =
      EventNotifier();
  final EventNotifier<SudokuNavigationPopInfo> _didPopTarget = EventNotifier();
  final ActionNotifier _didContinue = ActionNotifier();
  final ActionNotifier _didStartNewGame = ActionNotifier();
  ValueListenable<SudokuHomeDb?> get db => _db.view();
  ValueListenable<int?> get didChangeSideSqrt => _didChangeSideSqrt.view();
  ValueListenable<SudokuHomeSideInfo?> get didChangeSideInfo =>
      _didChangeSideInfo.view();
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
        final activeSideSqrt = view.right.left;
        final activeDifficulty = view.right.right;
        final canContinueMap = view.left;
        return canContinueMap[activeSideSqrt]!.right[activeDifficulty]!;
      });

  static const int _defaultSideSqrt = 3;
  static const SudokuDifficulty _defaultDifficulty = SudokuDifficulty.medium;
  static const SudokuHomeSideInfo _defaultHomeSideInfoWithHoles = {
    2: Tuple(2, {}),
    3: Tuple(3, {}),
    4: Tuple(4, {})
  };

  late final ValueListenable<int> _sideSqrt =
      db.bind((db) => didChangeSideSqrt.map((e) => e == null
          ? db == null
              ? _defaultSideSqrt
              : sudokuDbGetActiveSideSqrtOr(db, _defaultSideSqrt)
          : e));
  ValueListenable<int> get sideSqrt => _sideSqrt.view();

  late final ValueListenable<SudokuDifficulty> _difficulty = db.bind((db) =>
      didChangeDifficulty.map((change) => db == null
          ? _defaultDifficulty
          : change ?? sudokuDbGetActiveDifficutyOr(db, _defaultDifficulty)));
  ValueListenable<SudokuDifficulty> get difficulty => _difficulty.view();

  ValueListenable<OtherInfo> get otherInfo =>
      OtherInfo.new.curry.asValueListenable >> sideSqrt >> difficulty;

  late final ValueListenable<SudokuHomeSideInfo> _sideInfo = db
      .bind((db) => didChangeSideInfo.map((change) => db == null
          ? _defaultHomeSideInfoWithHoles
          : change ??
              sudokuDbGetSudokuHomeSideInfoOr(
                  db, _defaultHomeSideInfoWithHoles)))
      .map((sideInfoWithHoles) => sideInfoWithHoles
          .map((k, v) => MapEntry(k, v.second(sudokuHomeItemFillRemaining))));

  ValueListenable<SudokuHomeSideInfo> get sideInfo => _sideInfo.view();

  ValueListenable<SudokuHomeViewData> get viewData =>
      SudokuHomeViewData.new.curry.asValueListenable >> sideInfo >> otherInfo;

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
    final db = await Hive.openBox(
        boxNameFromSideSqrtAndDifficulty(sideSqrt, difficulty));
    _didRequestNavigation.add(
        SudokuNavigationTarget.left(CreateSudoku(sideSqrt, difficulty, db)));
  }

  void _onContinue(_) async {
    final sideSqrt = this.sideSqrt.value;
    final difficulty = this.difficulty.value;
    final db = await Hive.openBox(
        boxNameFromSideSqrtAndDifficulty(sideSqrt, difficulty));
    _didRequestNavigation.add(
        SudokuNavigationTarget.right(ResumeSudoku(sideSqrt, difficulty, db)));
  }

  Future<void> _onChangeSideSqrt(int? sideSqrt) {
    final newInfo = OtherInfo(sideSqrt!, difficulty.value);
    return db.value!.put('other-info', Right(newInfo));
  }

  Future<void> _onChangeDifficulty(SudokuDifficulty? difficulty) {
    final newInfo = OtherInfo(sideSqrt.value, difficulty!);
    return db.value!.put('other-info', Right(newInfo));
  }

  Future<void> _onChangeHomeSideInfo(SudokuHomeSideInfo? info) =>
      db.value!.put('home-side-info', Left(info!));

  void _onPopTarget(SudokuNavigationPopInfo popInfo) async {
    final target = popInfo.left;
    final sudokuController = popInfo.right;
    final db = target.visit(
      a: (create) => create.db,
      b: (resume) => resume.db,
    );
    final sideSqrt = target.visit(
      a: (create) => create.sideSqrt,
      b: (resume) => resume.sideSqrt,
    );
    final difficulty = target.visit(
      a: (create) => create.difficulty,
      b: (resume) => resume.difficulty,
    );
    final canContinue = !sudokuController.isFinished.value;
    _didChangeSideInfo.add(
      Map.of(sideInfo.value)
        ..[sideSqrt] = sideInfo.value[sideSqrt]!.second(
          (diffAndCanContinue) =>
              Map.of(diffAndCanContinue)..[difficulty] = canContinue,
        ),
    );
    // Ensure we flush the db to disk
    if (canContinue) {
      await db.flush();
    }
  }

  void init() {
    super.init();
    _initDb();
    didStartNewGame.tap(_onStartNewGame);
    didContinue.tap(_onContinue);
    didChangeSideSqrt.tap(_onChangeSideSqrt);
    didChangeDifficulty.tap(_onChangeDifficulty);
    sideInfo.tap(_onChangeHomeSideInfo);
    didPopTarget.tap(_onPopTarget);
  }

  Future<void> _initDb() async {
    print("init db");
    final db = await sudokuHomeDbOpen();
    print("loaded db");
    _db.value = db;
    print("set db");
  }
}
