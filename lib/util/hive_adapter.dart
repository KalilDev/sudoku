library app.util.hive_adapter;

import 'package:hive/hive.dart';
import 'package:utils/utils.dart';

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
