import 'dart:typed_data';

import 'package:app/home_view/data.dart';
import 'package:hive/hive.dart';
import 'package:utils/utils.dart';

import '../generation/impl/data.dart';
import 'sudoku_data.dart';

class SudokuAppBoardStateAdapter extends TypeAdapter<SudokuAppBoardState> {
  @override
  int get typeId => 0;

  @override
  void write(BinaryWriter writer, SudokuAppBoardState obj) {
    writer
      ..write(0)
      ..write(obj.side);
    for (var c = 0; c < obj.side; c++) {
      writer.writeIntList(obj.solvedBoard[c]);
    }
    for (var c = 0; c < obj.side; c++) {
      writer.writeIntList(obj.fixedNumbers[c]);
    }
    for (var c = 0; c < obj.side; c++) {
      writer.writeIntList(obj.currentNumbers[c]);
    }
    for (var c = 0; c < obj.side; c++) {
      for (var l = 0; l < obj.side; l++) {
        writer.writeIntList(obj.currentPossibilities[c][l]);
      }
    }
  }

  @override
  SudokuAppBoardState read(BinaryReader reader) {
    final version = reader.readInt();
    final side = reader.readInt();
    final bdr = SudokuAppBoardStateBuilder(side);
    for (var c = 0; c < side; c++) {
      bdr.solvedBoard[c] = Uint8List.fromList(reader.readIntList());
    }
    for (var c = 0; c < side; c++) {
      bdr.fixedNumbers[c] = Uint8List.fromList(reader.readIntList());
    }
    for (var c = 0; c < side; c++) {
      bdr.currentNumbers[c] = Uint8List.fromList(reader.readIntList());
    }
    for (var c = 0; c < side; c++) {
      for (var l = 0; l < side; l++) {
        final ps = reader.readIntList();
        bdr.currentPossibilities[c][l] = ps;
      }
    }
    return bdr.build();
  }
}

extension on BinaryWriter {
  void writeIndex(SudokuBoardIndex index) => writeTuple<int, int>(
        this,
        index,
        (w, i) => w.writeInt(i),
        (w, j) => w.writeInt(j),
      );
  void writeOtherInfo(OtherInfo otherInfo) {
    writeInt(0);
    write(otherInfo.difficulty);
    writeInt(otherInfo.activeSideSqrt);
  }
}

extension on BinaryReader {
  SudokuBoardIndex readIndex() =>
      readTuple<int, int>(this, (l) => l.readInt(), (r) => r.readInt());
  OtherInfo readOtherInfo() {
    final version = readInt();
    final difficulty = read() as SudokuDifficulty;
    final activeSideSqrt = readInt();
    return OtherInfo(difficulty, activeSideSqrt);
  }
}

class ChangeNumberAdapter extends TypeAdapter<ChangeNumber> {
  @override
  int get typeId => 1;

  @override
  void write(BinaryWriter writer, ChangeNumber obj) {
    writer
      ..writeInt(0)
      ..writeIndex(obj.index)
      ..writeInt(obj.from)
      ..writeInt(obj.to);
  }

  @override
  ChangeNumber read(BinaryReader reader) {
    final version = reader.readInt();
    return ChangeNumber(
      reader.readIndex(),
      reader.readInt(),
      reader.readInt(),
    );
  }
}

class AddPossibilityAdapter extends TypeAdapter<AddPossibility> {
  @override
  int get typeId => 2;

  @override
  void write(BinaryWriter writer, AddPossibility obj) {
    writer
      ..writeInt(0)
      ..writeIndex(obj.index)
      ..writeInt(obj.number);
  }

  @override
  AddPossibility read(BinaryReader reader) {
    final version = reader.readInt();
    return AddPossibility(
      reader.readIndex(),
      reader.readInt(),
    );
  }
}

class RemovePossibilityAdapter extends TypeAdapter<RemovePossibility> {
  @override
  int get typeId => 3;

  @override
  void write(BinaryWriter writer, RemovePossibility obj) {
    writer
      ..writeInt(0)
      ..writeIndex(obj.index)
      ..writeInt(obj.number);
  }

  @override
  RemovePossibility read(BinaryReader reader) {
    final version = reader.readInt();
    return RemovePossibility(
      reader.readIndex(),
      reader.readInt(),
    );
  }
}

class CommitNumberAdapter extends TypeAdapter<CommitNumber> {
  @override
  int get typeId => 4;

  @override
  void write(BinaryWriter writer, CommitNumber obj) {
    writer
      ..writeInt(0)
      ..writeIndex(obj.index)
      ..writeIntList(obj.oldPossibilities)
      ..writeInt(obj.number);
  }

  @override
  CommitNumber read(BinaryReader reader) {
    final version = reader.readInt();
    return CommitNumber(
      reader.readIndex(),
      reader.readIntList(),
      reader.readInt(),
    );
  }
}

class ClearTileAdapter extends TypeAdapter<ClearTile> {
  @override
  int get typeId => 5;

  @override
  void write(BinaryWriter writer, ClearTile obj) {
    writer
      ..writeInt(0)
      ..writeIndex(obj.index)
      ..writeIntList(obj.oldPossibilities)
      ..writeInt(obj.oldNumber);
  }

  @override
  ClearTile read(BinaryReader reader) {
    final version = reader.readInt();
    return ClearTile(
      reader.readIndex(),
      reader.readIntList(),
      reader.readInt(),
    );
  }
}

void writeTuple<L, R>(
  BinaryWriter writer,
  Tuple<L, R> tuple,
  void Function(BinaryWriter, L) writeLeft,
  void Function(BinaryWriter, R) writeRight,
) {
  writer.writeInt(0);
  writeLeft(writer, tuple.left);
  writeRight(writer, tuple.right);
}

Tuple<L, R> readTuple<L, R>(
  BinaryReader reader,
  L Function(BinaryReader) readLeft,
  R Function(BinaryReader) readRight,
) {
  final version = reader.readInt();
  final l = readLeft(reader);
  final r = readRight(reader);
  return Tuple(l, r);
}

void writeEither<L, R>(
  BinaryWriter writer,
  Either<L, R> either,
  void Function(BinaryWriter, L) writeLeft,
  void Function(BinaryWriter, R) writeRight,
) {
  writer.writeInt(0);
  either.visit(a: (l) {
    writer.writeBool(true);
    writeLeft(writer, l);
  }, b: (r) {
    writer.writeBool(false);
    writeRight(writer, r);
  });
}

Either<L, R> readEither<L, R>(
  BinaryReader reader,
  L Function(BinaryReader) readLeft,
  R Function(BinaryReader) readRight,
) {
  final version = reader.readInt();
  final isLeft = reader.readBool();
  if (isLeft) {
    return Left(readLeft(reader));
  }
  return Right(readRight(reader));
}

class SudokuHomeInfoAdapter extends TypeAdapter<SudokuHomeInfo> {
  @override
  int get typeId => 7;

  @override
  void write(BinaryWriter writer, SudokuHomeInfo obj) {
    writer.writeInt(0);
    writer.writeInt(0);
    final isSideInfo = obj is SideInfo;
    writer.write(isSideInfo);
    obj.visit(
      sideInfo: (sideInfo) => writer.write(sideInfo.info),
      otherInfo: (otherInfo) => writer.writeOtherInfo(otherInfo),
    );
  }

  @override
  SudokuHomeInfo read(BinaryReader reader) {
    final version = reader.readInt();
    final union_version = reader.readInt();
    final isSideInfo = reader.readBool();
    if (isSideInfo) {
      return SudokuHomeInfo.sideInfo(
          (reader.read() as Map<dynamic, dynamic>).cast());
    }
    return reader.readOtherInfo();
  }
}

class SudokuHomeItemAdapter extends TypeAdapter<SudokuHomeItem> {
  @override
  int get typeId => 8;

  @override
  void write(BinaryWriter writer, SudokuHomeItem obj) {
    writer.writeInt(0);
    writeTuple<int, SudokuHomeItemInfo>(
      writer,
      obj,
      (w, sideSqrt) => w.writeInt(sideSqrt),
      (w, itemInfo) => w.write(itemInfo),
    );
  }

  @override
  SudokuHomeItem read(BinaryReader reader) {
    final version = reader.readInt();
    return readTuple<int, SudokuHomeItemInfo>(
      reader,
      (r) => r.readInt(),
      (r) => (r.read() as Map<dynamic, dynamic>).cast(),
    );
  }
}

class SudokuDifficultyAdapter extends TypeAdapter<SudokuDifficulty> {
  @override
  int get typeId => 9;

  @override
  void write(BinaryWriter writer, SudokuDifficulty obj) {
    writer.writeInt(0);
    writer.writeString(obj.name);
  }

  @override
  SudokuDifficulty read(BinaryReader reader) {
    final version = reader.readInt();
    final name = reader.readString();
    return SudokuDifficulty.values.singleWhere((e) => name == e.name);
  }
}
