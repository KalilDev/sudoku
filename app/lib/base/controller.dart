import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:utils/utils.dart';
import 'package:value_notifier/value_notifier.dart';
import 'sudoku_data.dart';
import 'package:hive/hive.dart';
import 'package:synchronized/synchronized.dart';

typedef SudokuDb = Box<dynamic>;
Future<SudokuDb> sudokuDbOpen(String name) => Hive.openBox(name);

const Codec<SudokuAppBoardModel, Map<String, dynamic>> codec =
    DoublyLinkedEventSourcedModelCodec();

Future<void> sudokuDbStore(
  SudokuDb db,
  Map<String, dynamic> encodedSudoku,
) =>
    db.putAll(encodedSudoku);
Map<String, dynamic> sudokuDbToMap(SudokuDb db) => db.toMap().cast();

typedef LoadingModel = Maybe<ModelOrError>;
typedef ModelOrError = Either<Object, SudokuAppBoardModel>;

class _SudokuDBController
    extends SubcontrollerBase<SudokuController, _SudokuDBController> {
  ValueNotifier<SudokuAppBoardModel?> _savedState = ValueNotifier(null);
  EventNotifier<SudokuAppBoardModel> _didRequestSave = EventNotifier();
  final SudokuDb db;
  final SudokuAppBoardState? _initialState;

  _SudokuDBController.fromStorage(this.db) : _initialState = null;
  _SudokuDBController.fromInitialState(this.db, this._initialState);

  late final ValueListenable<SudokuAppBoardModel?> _toBeSaved =
      _didRequestSave.view().debounce(wait: const Duration(seconds: 1));

  late final ValueListenable<LoadingModel> _initialModel = dbLock
      .synchronized(() => _initialState == null
          ? _readFromDb(db)
          : _createFromInitialAndSaveToDb(db, _initialState!))
      .toValueListenable(eager: true)
      .map((snap) => snap.hasData
          ? LoadingModel.just(ModelOrError.right(snap.requireData))
          : snap.hasError
              ? LoadingModel.just(ModelOrError.left(snap.error!))
              : LoadingModel.none());

  ValueListenable<SudokuAppBoardModel?> get savedState => _savedState.view();
  ValueListenable<SudokuAppBoardState?> get savedSnapshot =>
      savedState.map((s) => s?.snapshot);

  ValueListenable<LoadingModel> get initialModel => _initialModel.view();

  static Future<void> _rawSaveToDb(SudokuDb db, Map<String, dynamic> encoded) =>
      sudokuDbStore(db, encoded);

  static Future<Map<String, dynamic>> _rawReadFromDb(SudokuDb db) async =>
      sudokuDbToMap(db);

  static Future<SudokuAppBoardModel> _readFromDb(SudokuDb db) =>
      _rawReadFromDb(db).then(codec.decode);

  static Future<void> _saveToDb(SudokuDb db, SudokuAppBoardModel model) =>
      _rawSaveToDb(db, codec.encode(model));

  static Future<SudokuAppBoardModel> _createFromInitialAndSaveToDb(
      SudokuDb db, SudokuAppBoardState initialState) async {
    final model = SudokuAppBoardModel(initialState);
    await _saveToDb(db, model);
    return model;
  }

  late final requestSave = _didRequestSave.add;

  final dbLock = Lock();

  Future<void> _save(SudokuAppBoardModel state) {
    print("saving!!");
    return dbLock
        .synchronized(() => _saveToDb(db, state))
        .then((_) => _savedState.value = state);
  }

  void _onInitialModel(LoadingModel model) {
    _savedState.value = model.visit(
      just: (v) => v.visit(
        left: (err) => null,
        right: (v) => v,
      ),
      none: () => null,
    );
  }

  void init() {
    initialModel.connect(_onInitialModel);
    _toBeSaved.tap((e) => e == null ? null : _save(e));
    super.init();
  }
}

extension AAAA on SudokuController {
  SudokuAppBoardModel changeNumber(SudokuBoardIndex index, int to) =>
      addE(snapshot.value!.changeNumberE(index, to));
  SudokuAppBoardModel addPossibility(SudokuBoardIndex index, int number) =>
      addE(snapshot.value!.addPossibilityE(index, number));
  SudokuAppBoardModel removePossibility(SudokuBoardIndex index, int number) =>
      addE(snapshot.value!.removePossibilityE(index, number));
  SudokuAppBoardModel commitNumber(SudokuBoardIndex index, int number) =>
      addE(snapshot.value!.commitNumberE(index, number));
  SudokuAppBoardModel clearTile(SudokuBoardIndex index) =>
      addE(snapshot.value!.clearTileE(index));
}

class SudokuController extends ControllerBase<SudokuController> {
  final _SudokuDBController _db;
  final ActionNotifier _didModifyModel = ActionNotifier();

  SudokuController.fromStorage(SudokuDb db)
      : _db = ControllerBase.create(() => _SudokuDBController.fromStorage(db));

  SudokuController.fromInitialState(
      SudokuDb db, SudokuAppBoardState initialState)
      : _db = ControllerBase.create(
            () => _SudokuDBController.fromInitialState(db, initialState));

  ValueListenable<ModelOrError?> get initialModel => _db.initialModel
      .map((loading) => loading.visit(just: (v) => v, none: () => null));

  ValueListenable<ModelOrError?> get model =>
      initialModel.bind((model) => _didModifyModel.view().map((_) => model));

  ValueListenable<SudokuAppBoardModel?> get modelOrNull =>
      model.map((modelOrError) => modelOrError?.visit(
            left: (err) => null,
            right: (model) => model,
          ));

  ValueListenable<SudokuAppBoardState?> get snapshot =>
      modelOrNull.map((model) => model?.snapshot);

  ValueListenable<ModelUndoState?> get undoState =>
      modelOrNull.map((model) => model?.undoState);

  // todo: return SudokuAppBoardModel or SudokuAppBoardState
  SudokuAppBoardModel addE(SudokuAppBoardChange e) {
    final model = modelOrNull.value!;
    final r = model.addE(e);
    _didModifyModel.notify();
    _db.requestSave(model);
    return r;
  }

  void undo() {
    final model = modelOrNull.value;
    if (model?.undo() ?? false) {
      _didModifyModel.notify();
      _db.requestSave(model!);
    }
  }

  void init() {
    addSubcontroller(_db);
  }

  // TODO: improve this
  void reset() {
    bool didUndo = false;
    final model = modelOrNull.value;
    while (model?.canUndo() ?? false) {
      didUndo = didUndo || (model!.undo());
    }
    if (didUndo) {
      _didModifyModel.notify();
      _db.requestSave(model!);
    }
  }
}
