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
  void writeIndex(SudokuBoardIndex index) => writeTupleN2<int, int>(
        this,
        index,
        (w, i) => w.writeInt(i),
        (w, j) => w.writeInt(j),
      );
}

extension on BinaryReader {
  SudokuBoardIndex readIndex() {
    final tuple = readTuple2<int, int>(
      this,
      (l) => l.readInt(),
      (r) => r.readInt(),
    );
    return SudokuBoardIndex.fromTupleN(tuple);
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

void writeTupleN2<L, R>(
  BinaryWriter writer,
  TupleN2<L, R> tuple,
  void Function(BinaryWriter, L) writeLeft,
  void Function(BinaryWriter, R) writeRight,
) {
  writer.writeInt(0);
  writeLeft(writer, tuple.e0);
  writeRight(writer, tuple.e1);
}

Tuple2<L, R> readTuple2<L, R>(
  BinaryReader reader,
  L Function(BinaryReader) readLeft,
  R Function(BinaryReader) readRight,
) {
  final version = reader.readInt();
  final l = readLeft(reader);
  final r = readRight(reader);
  return Tuple2(l, r);
}

void writeEither<L, R>(
  BinaryWriter writer,
  Either<L, R> either,
  void Function(BinaryWriter, L) writeLeft,
  void Function(BinaryWriter, R) writeRight,
) {
  writer.writeInt(0);
  either.visit(left: (l) {
    writer.writeBool(true);
    writeLeft(writer, l);
  }, right: (r) {
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
