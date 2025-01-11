import 'package:hive/hive.dart';
import 'track_model.dart';

class TrackService {
  static const String _trackBox = 'trackBox';

  // Initialize Hive and register adapter
  static Future<void> initHive() async {
    Hive.registerAdapter(TrackAdapter());
    await Hive.openBox<Track>(_trackBox);
  }

  // Save a new track
  static Future<void> saveTrack(Track track) async {
    var box = Hive.box<Track>(_trackBox);
    await box.add(track);
  }

  // Get all saved tracks
  static List<Track> getTracks() {
    var box = Hive.box<Track>(_trackBox);
    return box.values.toList();
  }

  // Alias for getTracks to match the expected method name
  static List<Track> getAllTracks() {
    var box = Hive.box<Track>('trackBox');
    return box.values.toList(); // Get all tracks from the box
  }

  // Delete a track by index
  static Future<void> deleteTrack(int index) async {
    var box = Hive.box<Track>(_trackBox);
    await box.deleteAt(index);
  }

  // Update a track by index
  static Future<void> updateTrack(int index, Track updatedTrack) async {
    var box = Hive.box<Track>(_trackBox);
    await box.putAt(index, updatedTrack);
  }
}
