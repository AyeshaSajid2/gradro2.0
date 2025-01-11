import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

class OffsetAdapter extends TypeAdapter<Offset> {
  @override
  final typeId = 1; // Unique typeId for this adapter

  @override
  Offset read(BinaryReader reader) {
    final dx = reader.readDouble();
    final dy = reader.readDouble();
    return Offset(dx, dy);
  }

  @override
  void write(BinaryWriter writer, Offset obj) {
    writer.writeDouble(obj.dx);
    writer.writeDouble(obj.dy);
  }
}
