import 'dart:async';
import 'dart:typed_data';

import 'package:localstorage/localstorage.dart';
// The dude who made localstorage didn't export it
// ignore: implementation_imports
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

class LocalStorageBoardRepository extends BoardRepository {
  final LocalStorage info = LocalStorage("BoardsInfo");
  StorageStatus status = const StorageStatus(StorageStatusType.unawaited, "O armazenamento ainda não foi preparado, usa-lo agora é um erro");

  Map<String, LocalStorage> openedStorages = {};
  Map<String, FreedStorageCallback> busyStorages = {};

  FutureOr<StorageStatus> prepareAndGetStatus() async {
    if (status.type != StorageStatusType.unawaited) {
      return status;
    }
    try {
      final result = await info.ready;
      if (result) {
        await info.setItem('noop', <dynamic>[]); // This is so that and PlatformNotSupportedError is thrown in case the platform is not supported
      }
      final status =  result ? const StorageStatus(StorageStatusType.ready, "Pronto") : const StorageStatus(StorageStatusType.error, "O armazenamento não pode ser preparado");
      this.status = status;
      return status;
      // ignore: avoid_catching_errors
    } on PlatformNotSupportedError {
      return const StorageStatus(StorageStatusType.unsupported, "Essa plataforma não é suportada para o armazenamento persistente do Sudoku");
    } catch (e) {
      return StorageStatus(StorageStatusType.error, "O armazenamento não pode ser preparado: $e");
    }
  }

  @override
  Future<bool> hasConfiguration(int side, SudokuDifficulty difficulty) async {
    if (status.type != StorageStatusType.ready) {
      throw Error();
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
    if (status.type != StorageStatusType.ready) {
      throw Error();
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
      solution: null, // Will be computed when needed
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
      await info.setItem("availableConfigurations", configs);
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
    if (status.type != StorageStatusType.ready) {
      throw Error();
    }
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
    await file.setItem("initialState", initialState);
    await file.setItem("state", state);
    await file.setItem("possibleValues", possibleValues);
    await file.setItem("side", snap.side);
    return file;
  }
  
  @override
  Future<void> scheduleSave(int side, SudokuDifficulty difficulty, SudokuSnapshot snap) async {
    if (status.type != StorageStatusType.ready) {
      throw Error();
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
    if (status.type != StorageStatusType.ready) {
      throw Error();
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
      await info.setItem("availableConfigurations", configs);
    }
    await file?.clear();
    busyStorages.remove(filename);
  }

  @override
  Future<void> freeSudoku(int side, SudokuDifficulty difficulty) async {
    if (status.type != StorageStatusType.ready) {
      throw Error();
    }
    final filename = getFilename(side, difficulty);
    busyStorages.remove(filename);
    /*final file = openedStorages[filename];
    file?.dispose();
    openedStorages.remove(file);*/
  }

  @override
  Future<StorageStatus> prepareStorage() async => await prepareAndGetStatus();

  @override
  StorageStatus currentStatus() => status;
}