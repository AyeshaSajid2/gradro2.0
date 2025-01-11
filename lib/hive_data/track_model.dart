import 'package:hive/hive.dart';

part 'track_model.g.dart'; // Required for Hive type adapter

@HiveType(typeId: 2)
class Track {
  @HiveField(0)
  String trackName;

  @HiveField(1)
  List<String> commands;

  @HiveField(2)
  List<Duration> pressDurations;

  @HiveField(3)
  List<Duration> clickIntervals;


  Track({
    required this.trackName,
    required this.commands,
    required this.pressDurations,
    required this.clickIntervals,
  });
}
