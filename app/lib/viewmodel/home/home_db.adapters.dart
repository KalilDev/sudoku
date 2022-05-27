part of 'home_db.dart';

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

class _SidesInfoAdapter extends TypeAdapter<SidesInfo> {
  @override
  int get typeId => 11;
  static Map<K, V> _mapFromDyn<K, V>(dynamic v) =>
      (v as Map<dynamic, dynamic>).cast();

  void write(BinaryWriter writer, SidesInfo obj) {
    writer.writeInt(0);
    writer.write(obj.info);
  }

  SidesInfo read(BinaryReader reader) {
    final version = reader.readInt();
    return SidesInfo(
      _mapFromDyn<int, dynamic>(reader.read()).map((sideSqrt, v) => MapEntry(
            sideSqrt,
            _mapFromDyn<SudokuDifficulty, bool>(v),
          )),
    );
  }
}
