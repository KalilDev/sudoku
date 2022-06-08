part of 'sudoku_db.dart';

class _SudokuAppBoardStateAdapter extends TypeAdapter<SudokuAppBoardState> {
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

class _ChangeNumberAdapter extends TypeAdapter<ChangeNumber> {
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

class _AddPossibilityAdapter extends TypeAdapter<AddPossibility> {
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

class _RemovePossibilityAdapter extends TypeAdapter<RemovePossibility> {
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

class _CommitNumberAdapter extends TypeAdapter<CommitNumber> {
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

class _ClearTileAdapter extends TypeAdapter<ClearTile> {
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

class _ChangeFromNumberToPossibility
    extends TypeAdapter<ChangeFromNumberToPossibility> {
  @override
  int get typeId => 16;

  @override
  void write(BinaryWriter writer, ChangeFromNumberToPossibility obj) {
    writer
      ..writeInt(0)
      ..writeIndex(obj.index)
      ..writeInt(obj.oldNumber)
      ..writeInt(obj.possibility);
  }

  @override
  ChangeFromNumberToPossibility read(BinaryReader reader) {
    final version = reader.readInt();
    return ChangeFromNumberToPossibility(
      reader.readIndex(),
      reader.readInt(),
      reader.readInt(),
    );
  }
}

class _ClearBoardAdapter extends TypeAdapter<ClearBoard> {
  @override
  int get typeId => 17;

  @override
  void write(BinaryWriter writer, ClearBoard obj) {
    writer
      ..writeInt(0)
      ..write(obj.oldState);
  }

  @override
  ClearBoard read(BinaryReader reader) {
    final version = reader.readInt();
    return ClearBoard(
      reader.read() as SudokuAppBoardState,
    );
  }
}
