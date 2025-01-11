// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackAdapter extends TypeAdapter<Track> {
  @override
  final int typeId = 2;

  @override
  Track read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Track(
      trackName: fields[0] as String,
      commands: (fields[1] as List).cast<String>(),
      pressDurations: (fields[2] as List).cast<Duration>(),
      clickIntervals: (fields[3] as List).cast<Duration>(),
    );
  }

  @override
  void write(BinaryWriter writer, Track obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.trackName)
      ..writeByte(1)
      ..write(obj.commands)
      ..writeByte(2)
      ..write(obj.pressDurations)
      ..writeByte(3)
      ..write(obj.clickIntervals);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
