part of 'sudoku_user_themes_db.dart';

class _SudokuSeededThemeAdapter extends TypeAdapter<SudokuSeededTheme> {
  int get typeId => 12;

  static Brightness _readBrightness(BinaryReader reader) {
    return Brightness.values[reader.readInt()];
  }

  static Color _readColor(BinaryReader reader) {
    return Color(reader.readUint32());
  }

  static Color? _readMaybeColor(BinaryReader reader) {
    final isNull = reader.readBool();
    if (isNull) {
      return null;
    }
    return _readColor(reader);
  }

  static void _writeBrightness(BinaryWriter writer, Brightness obj) {
    writer.writeInt(obj.index);
  }

  static void _writeColor(BinaryWriter writer, Color obj) {
    writer.writeUint32(obj.value);
  }

  static void _writeMaybeColor(BinaryWriter writer, Color? obj) {
    final isNull = obj == null;
    writer.writeBool(isNull);
    if (isNull) {
      return;
    }
    _writeColor(writer, obj);
  }

  @override
  void write(BinaryWriter writer, SudokuSeededTheme obj) {
    writer.writeInt(0);
    writer.writeString(obj.name);
    _writeBrightness(writer, obj.brightness);
    _writeColor(writer, obj.seed);
    _writeMaybeColor(writer, obj.secondarySeed);
    _writeMaybeColor(writer, obj.background);
  }

  @override
  SudokuSeededTheme read(BinaryReader reader) {
    final version = reader.readInt();
    return SudokuSeededTheme(
      reader.readString(),
      _readBrightness(reader),
      _readColor(reader),
      _readMaybeColor(reader),
      _readMaybeColor(reader),
    );
  }
}
