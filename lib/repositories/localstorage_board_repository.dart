import 'dart:async';
import 'dart:typed_data';

import 'package:localstorage/localstorage.dart';
import 'package:localstorage/src/errors.dart';
import 'package:sudoku_presentation/common.dart';
import 'package:sudoku_presentation/repositories.dart';
import 'package:sudoku_presentation/sudoku_bloc.dart';
import 'package:sudoku_core/sudoku_core.dart';

List<List<T>> dynamicTo2dList<T>(dynamic _list) {
  final rows = _list as List<dynamic>;
  return rows.map((dynamic row) => (row as List<dynamic>).cast<T>()).toList();
}

List<List<List<T>>> dynamicTo3dList<T>(dynamic _list) {
  final rows = _list as List<dynamic>;
  return rows.map((dynamic row) => (row as List<dynamic>).map((dynamic inner)=>(inner as List<dynamic>).cast<T>()).toList()).toList();
}

typedef FreedStorageCallback = void Function(LocalStorage);

enum StorageStatus {
  unawaited,
  ready,
  unsupported,
  error
}

class LocalStorageBoardRepository extends BoardRepository {
  final LocalStorage info = LocalStorage("BoardsInfo");
  StorageStatus status = StorageStatus.unawaited;

  Map<String, LocalStorage> openedStorages = {};
  Map<String, FreedStorageCallback> busyStorages = {};

  FutureOr<StorageStatus> prepareStorageIfNeeded() async {
    if (status != StorageStatus.unawaited) {
      return status;
    }
    try {
      final result = await info.ready;
      final status =  result ? StorageStatus.ready : StorageStatus.error;
      this.status = status;
      return status;
    } on PlatformNotSupportedError catch (e) {
      return StorageStatus.unsupported;
    } finally {
      return StorageStatus.error;
    }
  }

  @override
  Future<bool> hasConfiguration(int side, SudokuDifficulty difficulty) async {
    if (await prepareStorageIfNeeded() != StorageStatus.ready) {
      return false;
    }
    final configs = info.getItem("availableConfigurations") as List<dynamic>;
    if (configs == null) {
      return false;
    }
    final difficultyIndex = SudokuDifficulty.values.indexOf(difficulty);
    return configs.any((dynamic _config) {
      final config = _config as Map<String, dynamic>;
      if (config["side"] == side.toString() && config["difficulty"] == difficultyIndex.toString()) {
        return true;
      }
      return false;
    });
  }
  
  @override
  Future<SudokuState> loadSudoku(int side, SudokuDifficulty difficulty) async {
    if (await prepareStorageIfNeeded() != StorageStatus.ready) {
      return null;
    }
    final file = await getStorage(side, difficulty);
    final initialStateRaw = dynamicTo2dList<int>(file.getItem("initialState"));
    final initialState = BidimensionalList<int>.view2d(initialStateRaw);
    final stateRaw = dynamicTo2dList<int>(file.getItem("state"));
    final state = BidimensionalList<int>.view2d(stateRaw);
    final possibleValuesRaw = dynamicTo3dList<int>(file.getItem("possibleValues"));
    final possibleValues = BidimensionalList<List<int>>.view2d(possibleValuesRaw);
    final _side = file.getItem("side") as int;
    final sudokuState = SudokuState.raw(
      initialState: initialState,
      state: state,
      possibleValues: possibleValues,
      side: _side
    );
    await null;
    return sudokuState;
  }

  String getFilename(int side, SudokuDifficulty difficulty) {
    final difficultyIndex = SudokuDifficulty.values.indexOf(difficulty);
    final filename = "${side}x$difficultyIndex";
    return filename;
  }

  Future<LocalStorage> getStorage(int side, SudokuDifficulty difficulty) async {
    if (!await hasConfiguration(side, difficulty)) {
      final difficultyIndex = SudokuDifficulty.values.indexOf(difficulty);
      final configs = info.getItem("availableConfigurations") as List<dynamic> ?? <dynamic>[];
      configs.add({"side": side.toString(), "difficulty": difficultyIndex.toString()});
      info.setItem("availableConfigurations", configs);
    }
    final filename = getFilename(side, difficulty);
    if (!openedStorages.containsKey(filename)) {
      final file = LocalStorage(filename);
      await file.ready;
      openedStorages[filename] = file;
    }
    return openedStorages[filename];
  }

  Future<LocalStorage> save(LocalStorage file, SudokuSnapshot snap) async {
    final initialState = BidimensionalList.view(Uint8List(snap.side*snap.side), snap.side);
    final state = BidimensionalList.view(Uint8List(snap.side*snap.side), snap.side);
    final possibleValues = BidimensionalList<List<int>>.generate(snap.side, (_, __) => <int>[]);
    snap.squares.forEachIndexed((square, x, y) {
      if (square.isInitial) {
        initialState[y][x] = square.number;
      }
      state[y][x] = square.number;
      possibleValues[y][x] = square.possibleNumbers;
    });
    await null;
    file.setItem("initialState", initialState);
    file.setItem("state", state);
    file.setItem("possibleValues", possibleValues);
    file.setItem("side", snap.side);
    return file;
  }
  
  @override
  Future<void> scheduleSave(int side, SudokuDifficulty difficulty, SudokuSnapshot snap) async {
    if (await prepareStorageIfNeeded() != StorageStatus.ready) {
      return null;
    }
    final filename = getFilename(side, difficulty);
    if (busyStorages.containsKey(filename)) {
      busyStorages[filename] = (file) {
        save(file, snap).then((file) => busyStorages[filename]?.call(file));
      };
      return;
    }
    busyStorages[filename] = null;
    final file = await getStorage(side, difficulty);
    await save(file, snap);
    busyStorages[filename]?.call(file);
    busyStorages.remove(filename);
  }

  @override
  Future<void> deleteSudoku(int side, SudokuDifficulty difficulty) async {
    if (await prepareStorageIfNeeded() != StorageStatus.ready) {
      return null;
    }
    final filename = getFilename(side, difficulty);
    final file = openedStorages[filename];
    busyStorages[filename] = null;
    await file?.clear();
    busyStorages[filename] = null;
    final difficultyIndex = SudokuDifficulty.values.indexOf(difficulty);
    if (await hasConfiguration(side, difficulty)) {
      busyStorages[filename] = null;
      final configs = info.getItem("availableConfigurations") as List<dynamic> ?? <dynamic>[];
      configs.removeWhere((dynamic obj) => (obj as Map<String,dynamic>)["side"] == side.toString() && obj["difficulty"] == difficultyIndex.toString());
      info.setItem("availableConfigurations", configs);
    }
    await file?.clear();
    busyStorages.remove(filename);
  }

  @override
  Future<void> freeSudoku(int side, SudokuDifficulty difficulty) async {
    if (await prepareStorageIfNeeded() != StorageStatus.ready) {
      return null;
    }
    final filename = getFilename(side, difficulty);
    busyStorages.remove(filename);
    /*final file = openedStorages[filename];
    file?.dispose();
    openedStorages.remove(file);*/
  }
}