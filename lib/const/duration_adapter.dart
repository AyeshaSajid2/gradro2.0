import 'package:hive/hive.dart';

part 'duration_adapter.g.dart';

@HiveType(typeId: 34) // Ensure this is a unique typeId not used by other adapters
class DurationAdapter extends TypeAdapter<Duration> {
  @override
  Duration read(BinaryReader reader) {
    final microseconds = reader.readInt();
    return Duration(microseconds: microseconds);
  }

  @override
  void write(BinaryWriter writer, Duration obj) {
    writer.writeInt(obj.inMicroseconds);
  }

  @override
  int get typeId => 34; // Implementing the typeId getter
}
