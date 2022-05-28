part of 'sudoku_animation_db.dart';

class _SelectionAnimationOptionsAdapter
    extends TypeAdapter<SelectionAnimationOptions> {
  int get typeId => 13;

  @override
  void write(BinaryWriter writer, SelectionAnimationOptions obj) {
    writer.writeInt(0);
    writer.writeBool(obj.size);
    writer.writeBool(obj.color);
  }

  @override
  SelectionAnimationOptions read(BinaryReader reader) {
    final version = reader.readInt();
    return SelectionAnimationOptions(
      reader.readBool(),
      reader.readBool(),
    );
  }
}

class _TextAnimationOptionsAdapter extends TypeAdapter<TextAnimationOptions> {
  int get typeId => 14;

  @override
  void write(BinaryWriter writer, TextAnimationOptions obj) {
    writer.writeInt(0);
    writer.writeBool(obj.position);
    writer.writeBool(obj.opacity);
    writer.writeBool(obj.color);
    writer.writeBool(obj.string);
  }

  @override
  TextAnimationOptions read(BinaryReader reader) {
    final version = reader.readInt();
    return TextAnimationOptions(
      reader.readBool(),
      reader.readBool(),
      reader.readBool(),
      reader.readBool(),
    );
  }
}

class _AnimationOptionsAdapter extends TypeAdapter<AnimationOptions> {
  int get typeId => 15;

  static AnimationSpeed _readSpeed(BinaryReader reader) =>
      AnimationSpeed.values[reader.readInt()];
  static void _writeSpeed(BinaryWriter writer, AnimationSpeed obj) =>
      writer.writeInt(obj.index);

  @override
  void write(BinaryWriter writer, AnimationOptions obj) {
    writer.writeInt(0);
    writer.write(obj.e0);
    writer.write(obj.e1);
    _writeSpeed(writer, obj.e2);
  }

  @override
  AnimationOptions read(BinaryReader reader) {
    final version = reader.readInt();
    return AnimationOptions(
      reader.read(),
      reader.read(),
      _readSpeed(reader),
    );
  }
}
