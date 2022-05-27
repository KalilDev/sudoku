part of 'home_db.dart';

class _SudokuHomeDbValuesAdapter extends TypeAdapter<_SudokuHomeDbValues> {
  @override
  int get typeId => 7;

  @override
  void write(BinaryWriter writer, _SudokuHomeDbValues obj) {
    writer.writeInt(0);
    writer.writeInt(0);
    final isSidesInfo = obj is SidesInfo;
    writer.writeBool(isSidesInfo);
    obj.visit(
      sidesInfo: (sidesInfo) => writer.write(sidesInfo.info),
      activeInfo: (activeInfo) => writer.write(activeInfo),
    );
  }

  @override
  _SudokuHomeDbValues read(BinaryReader reader) {
    final version = reader.readInt();
    final union_version = reader.readInt();
    final isSideInfo = reader.readBool();
    if (isSideInfo) {
      return _SudokuHomeDbValues.sidesInfo(
          (reader.read() as Map<dynamic, dynamic>).cast());
    }
    return reader.read() as ActiveInfo;
  }
}

class _SudokuHomeItemAdapter extends TypeAdapter<SudokuHomeItem> {
  @override
  int get typeId => 8;

  @override
  void write(BinaryWriter writer, SudokuHomeItem obj) {
    writer.writeInt(0);
    writeTupleN2<int, SudokuHomeItemInfo>(
      writer,
      obj,
      (w, sideSqrt) => w.writeInt(sideSqrt),
      (w, itemInfo) => w.write(itemInfo),
    );
  }

  @override
  SudokuHomeItem read(BinaryReader reader) {
    final version = reader.readInt();
    final tuple = readTuple2<int, SudokuHomeItemInfo>(
      reader,
      (r) => r.readInt(),
      (r) => (r.read() as Map<dynamic, dynamic>).cast(),
    );
    return SudokuHomeItem.fromTupleN(tuple);
  }
}

class _SudokuDifficultyAdapter extends TypeAdapter<SudokuDifficulty> {
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

class _ActiveInfoAdapter extends TypeAdapter<ActiveInfo> {
  @override
  int get typeId => 10;
  void write(BinaryWriter writer, ActiveInfo obj) {
    writer.writeInt(0);
    writer.write(obj.difficulty);
    writer.writeInt(obj.sideSqrt);
  }

  ActiveInfo read(BinaryReader reader) {
    final version = reader.readInt();
    return ActiveInfo(
      reader.read() as SudokuDifficulty,
      reader.readInt(),
    );
  }
}
