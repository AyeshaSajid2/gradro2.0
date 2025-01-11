// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duration_adapter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DurationAdapterAdapter extends TypeAdapter<DurationAdapter> {
  @override
  final int typeId = 34;

  @override
  DurationAdapter read(BinaryReader reader) {
    return DurationAdapter();
  }

  @override
  void write(BinaryWriter writer, DurationAdapter obj) {
    writer.writeByte(0);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DurationAdapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
