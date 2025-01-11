// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FruitAdapter extends TypeAdapter<Fruit> {
  @override
  final int typeId = 0;

  @override
  Fruit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Fruit(
      name: fields[0] as String,
      imagePath: fields[1] as String,
      spacing: fields[2] as int,
      sun: fields[3] as String,
      water: fields[4] as String,
      season: fields[5] as String,
      frost: fields[6] as String,
      description: fields[7] as String,
      position: fields[8] as Offset?,
    );
  }

  @override
  void write(BinaryWriter writer, Fruit obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.spacing)
      ..writeByte(3)
      ..write(obj.sun)
      ..writeByte(4)
      ..write(obj.water)
      ..writeByte(5)
      ..write(obj.season)
      ..writeByte(6)
      ..write(obj.frost)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.position);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FruitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
