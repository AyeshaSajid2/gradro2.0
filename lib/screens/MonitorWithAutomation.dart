import 'dart:async';

import 'package:back_pressed/back_pressed.dart';
import 'package:connect/utils/router_helper.dart';
import 'package:connect/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../hive_data/track_model.dart';
import '../hive_data/track_service.dart';
import '../widgets/AutomationControlsWidget.dart';

class MonitoringPageAutomate extends StatefulWidget {
  final String ipAddres;

  const MonitoringPageAutomate({super.key, required this.ipAddres});

  @override
  _MonitoringPageAutomateState createState() => _MonitoringPageAutomateState();
}

class _MonitoringPageAutomateState extends State<MonitoringPageAutomate> {
  bool holdingButton = false;
  List<String> recordedCommands = []; // To store recorded commands
  List<Duration> recordedPressDurations =
      []; // To store how long the button is being pressed
  List<Duration> recordedClickIntervals =
      []; // To store durations between clicks
  bool isRecording = false; // To track recording state
  bool isReplaying = false;
  bool stopReplayRequested = false; // Track playback state

  DateTime? buttonPressStartTime;
  DateTime? lastClickTime; // Store last click time

  String errorMessage = ''; // Variable to store error message
  final TextEditingController _distanceController = TextEditingController();
  bool isMoving = false;
  double remainingDistance = 0.0;
  double totalDistanceInMeters = 0.0;
  double distanceCovered = 0.0;
  Timer? _moveTimer;

  Future<void> _sendCommand(String command) async {
    try {
      final response = await http.get(
        Uri.parse('http://${widget.ipAddres}$command'),
      );

      if (response.statusCode == 200) {
        print('Command sent successfully: $command');
      } else {
        print('Failed to send command: http://${widget.ipAddres}$command');
      }
    } catch (error) {
      print('Error sending command: $error');
    }
  }

  Future<void> checkDeviceConnectivity(String ipAddress) async {
    final url =
        'http://${widget.ipAddres}:81'; // Replace with your ESP32-CAM's IP and port
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print('Device is reachable!');
      } else {
        setState(() {
          errorMessage = 'Server responded with status: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error connecting to device : $e';
      });
    }
  }

// Send command when the button is pressed
  // Send command to device

  void _startCommand(String command) {
    if (!holdingButton) {
      _sendCommand(command); // Send the command
      holdingButton = true;
      buttonPressStartTime = DateTime.now(); // Start timing the button press

      // If recording, capture the command and duration
      if (isRecording) {
        recordedCommands.add(command);

        // Calculate the time interval between the last click and this click
        if (lastClickTime != null) {
          recordedClickIntervals
              .add(buttonPressStartTime!.difference(lastClickTime!));
        } else {
          recordedClickIntervals.add(Duration.zero); // For the first command
        }

        lastClickTime = buttonPressStartTime;
        print('Start command: $command at $buttonPressStartTime');
      }
    }
  }

  // Send stop command when the button is released
  void _stopCommand({String stopCommand = '/stop'}) {
    if (holdingButton) {
      _sendCommand(stopCommand); // Send stop command
      holdingButton = false;

      var stopTime = DateTime.now();

      // If recording, capture the duration of the button press
      if (isRecording && buttonPressStartTime != null) {
        var pressDuration = stopTime.difference(buttonPressStartTime!);
        recordedPressDurations.add(pressDuration);
        print('Stop command: Button held for $pressDuration');
      }

      buttonPressStartTime = null; // Reset start time
      if (stopCommand == '/ledoff') print("weed cutting stoped");
    }
  }

  void _startMoving() {
    if (isMoving) {
      snackBarOverlay("Already moving!", context);
      return;
    }
    totalDistanceInMeters = double.tryParse(_distanceController.text) ?? 0.0;
    remainingDistance = totalDistanceInMeters * 100; // Convert to centimeters
    distanceCovered = 0.0;

    if (totalDistanceInMeters <= 0) {
      snackBarOverlay("Enter a valid distance to start automation", context);
      setState(() {
        isMoving = false;
      });
    } else {
      // Calculate time to cover the total distance (in seconds)
      double timeInSeconds =
          totalDistanceInMeters * 100 * 0.1; // 0.1 sec per cm
      snackBarOverlay(
          "Automation activated. Estimated time: $timeInSeconds seconds.",
          context);

      setState(() {
        isMoving = true;
      });
      _moveForward();
    }
  }

  void _moveForward() {
    if (!isMoving || remainingDistance <= 0) {
      _stopMoving();
      return;
    }

    _sendCommand('/go');
    setState(() {
      remainingDistance -= 1; // 1 cm per step
      distanceCovered += 1;
    });

    if (distanceCovered % 100 == 0) {
      snackBarOverlay(
          "${(distanceCovered / 100).floor()} meters covered.", context);
    }

    _moveTimer = Timer(const Duration(milliseconds: 100),
        _moveForward); // Move every 0.1 second
  }

  void _stopMoving() {
    if (_moveTimer != null && _moveTimer!.isActive) {
      _moveTimer?.cancel();
      _moveTimer = null; // Ensure the timer is cleared
    }
    setState(() {
      isMoving = false;
    });
    _sendCommand('/stop');
    snackBarOverlay("Automation deactivated", context);
    print("Stopped moving.");
  }

  void _moveInDirection(String direction) {
    _sendCommand('/$direction');
    snackBarOverlay("$direction Automation started", context); //

    Timer(const Duration(seconds: 5), () {
      _sendCommand('/stop');
      snackBarOverlay("Automation completed", context);
    });
  }

// Toggle recording mode

// Function to show edit dialog for track name

  void _toggleRecording() {
    if (isReplaying) {
      // Show warning if replay is running
      snackBarOverlay("Cannot start recording while replaying!.", context);
    } else {
      // Toggle recording state
      setState(() {
        isRecording = !isRecording;
        if (isRecording) {
          recordedCommands.clear();
          recordedPressDurations
              .clear(); // Clear press durations on new recording
          recordedClickIntervals
              .clear(); // Clear click intervals on new recording
          buttonPressStartTime = null;
          lastClickTime = null; // Reset last click time
          print("Recording started...");
        } else {
          print("Recording stopped. Recorded commands: $recordedCommands");
          print("Recorded press durations: $recordedPressDurations");
          print("Recorded click intervals: $recordedClickIntervals");
          if (recordedCommands.isNotEmpty) {
            _showTrackSaveDialog();
          } else {
            snackBarOverlay(
                "No commands recorded. Track cannot be saved..", context);
          }
        }
      });
    }
  }

// Function to handle button press event and record commands, press durations, and click intervals

  void saveTrack(Track track) async {
    print('Track Name: ${track.trackName}');
    print('Commands: ${track.commands}');
    print('Press Durations: ${track.pressDurations}');
    print('Click Intervals: ${track.clickIntervals}');

    var box = await Hive.openBox<Track>('trackBox');
    await box.add(track);
  }

// Show Bottom Sheet for saving the track
  void _showTrackSaveDialog() {
    TextEditingController trackNameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black87, // Background color of the modal
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Save Track',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: trackNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Track Name',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor:
                        Colors.grey[800], // Fill color for the input field
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  readOnly: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Commands',
                    labelStyle: const TextStyle(color: Colors.white70),
                    hintText: recordedCommands.isEmpty
                        ? 'No commands recorded'
                        : recordedCommands.join(', '), // Auto-fill commands
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (recordedCommands.isNotEmpty) {
                      // Check if commands are recorded
                      if (trackNameController.text.isNotEmpty) {
                        final track = Track(
                          trackName: trackNameController.text,
                          commands: List<String>.from(recordedCommands),
                          pressDurations:
                              List<Duration>.from(recordedPressDurations),
                          clickIntervals:
                              List<Duration>.from(recordedClickIntervals),
                        );

                        // Save track
                        saveTrack(track);

                        print('${track.commands}');
                        print('${track.pressDurations}');
                        print('${track.clickIntervals}');
                        print('${track.trackName}');

                        // Clear recording state
                        setState(() {
                          recordedCommands.clear();
                          recordedPressDurations.clear();
                          recordedClickIntervals.clear();
                        });

                        Navigator.pop(context); // Close the bottom sheet
                        snackBarOverlay("Track saved successfully!..", context);
                      } else {
                        snackBarOverlay(
                            "Please enter a track name...", context);
                      }
                    } else {
                      snackBarOverlay(
                          "No commands recorded. Track cannot be saved..",
                          context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.blueAccent, // Button background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                  ),
                  child:
                      const Text('Done', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Toggle replay
  void _toggleReplay(Track track) async {
    print('Starting replay for track: ${track.trackName}');

    // Check if recording is active
    if (isRecording) {
      print('Cannot replay while recording is active.');
      snackBarOverlay("Cannot replay while recording.", context);

      return;
    }

    // Check if already replaying
    if (isReplaying) {
      // If already replaying, request to stop
      stopReplayRequested = true;
      print('Stop requested for replay: ${track.trackName}');
      return;
    }

    setState(() {
      isReplaying = true;
      stopReplayRequested = false;
    });

    for (int i = 0; i < track.commands.length; i++) {
      // Check if replay has been stopped by user
      if (stopReplayRequested) {
        print('Replay stopped by user');
        _stopReplay(); // Ensure proper cleanup
        break;
      }

      String command = track.commands[i];
      print('Sending command: $command');
      await _sendCommand(command);
      await Future.delayed(track.pressDurations[i]);

      if (command == '/ledon') {
        print('Command /ledon detected, sending /ledoff');
        await _sendCommand('/ledoff');
      } else {
        print('Sending stop command after: $command');
        await _sendCommand('/stop');
      }

      // Wait for the next command interval
      if (i < track.clickIntervals.length) {
        print('Waiting for next command interval: ${track.clickIntervals[i]}');
        await Future.delayed(track.clickIntervals[i]);
      }
    }

    setState(() {
      isReplaying = false; // Set replaying to false after completion
    });
  }

  void _showAutopilotTracks() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      backgroundColor: Colors.black87,
      builder: (context) {
        return FutureBuilder<List<Track>>(
          future: Future.value(TrackService.getAllTracks()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return const Center(
                  child: Text("No tracks available.",
                      style: TextStyle(color: Colors.white)));
            } else {
              List<Track> tracks = snapshot.data!;
              return ListView.builder(
                itemCount: tracks.length,
                itemBuilder: (context, index) {
                  Track track = tracks[index];
                  return Dismissible(
                    key:
                        Key(track.trackName), // Unique key for each dismissible
                    background: Container(
                      color: Colors.redAccent,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) async {
                      // Remove the track from the data source
                      await TrackService.deleteTrack(index);

                      // Show a snackbar to inform the user
                      snackBarOverlay("${track.trackName} deleted.", context);
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(content: Text('${track.trackName} deleted')),
                      // );

                      // Update the UI by fetching tracks again
                      setState(() {
                        tracks.removeAt(index);
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          track.trackName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onTap: () {
                          _toggleReplay(track);
                          Navigator.pop(context);
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.blueAccent),
                              onPressed: () {
                                _showEditTrackNameDialog(track, index);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        );
      },
    );
  }

  void _showEditTrackNameDialog(Track track, int index) {
    TextEditingController nameController =
        TextEditingController(text: track.trackName);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Edit Track Name",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Track Name",
                    labelStyle: const TextStyle(color: Colors.white70),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white70),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (nameController.text.isNotEmpty) {
                          track.trackName = nameController.text;

                          // Update the track in the service
                          await TrackService.updateTrack(index, track);

                          // Refresh the UI
                          setState(() {
                            // Optionally, fetch tracks again if needed
                          });

                          Navigator.pop(context);
                          snackBarOverlay(
                              "Track updated successfully.", context);
                        } else {
                          snackBarOverlay(
                              "Track name cannot be empty.", context);
                        }
                      },
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.greenAccent),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _stopReplay() {
    setState(() {
      isReplaying = false;
      stopReplayRequested = true;
    });
    print('Replay stopped manually'); // Log when replay is manually stopped
    snackBarOverlay("Replay stopped.", context);
  }
// Toggle recording mode

// Function to show edit dialog for track name

  // void _stopReplay() {
  //   // Logic to clean up and stop replaying
  //   setState(() {
  //     stopReplayRequested = true;
  //     isReplaying = false; // Make sure to reset isReplaying
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return OnBackPressed(
      perform: () => Routes.pushNamedAndRemoveUntil(Routes.home),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: <Widget>[
            Positioned(
              top: 20,
              left: 20,
              child: GestureDetector(
                onTap: () => Routes.pushNamedAndRemoveUntil(Routes.home),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 32.0,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 30,
              right: 20,
              child: GestureDetector(
                onTap: isReplaying ? _stopReplay : _showAutopilotTracks,
                child: Container(
                  decoration: BoxDecoration(
                    color: isReplaying ? Colors.white : Colors.black,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: isReplaying ? Colors.black : Colors.white,
                      width: 2.0,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    isReplaying ? 'Stop' : 'Autopilot',
                    style: TextStyle(
                      color: isReplaying ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // Add Record button
            Positioned(
              top: 30,
              right: 130,
              child: GestureDetector(
                onTap: _toggleRecording,
                child: Container(
                  decoration: BoxDecoration(
                    color: isRecording ? Colors.white : Colors.black,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: isRecording ? Colors.black : Colors.white,
                      width: 2.0,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    isRecording ? 'Done' : 'Track',
                    style: TextStyle(
                      color: isRecording ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 80,
              right: 210,
              bottom: 10,
              left: 30,
              child: _buildNormalVideoFeed(),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: GestureDetector(
                onTap: () => Routes.pushNamedAndRemoveUntil(Routes.home),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 32.0,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 00,
              right: 20,
              child: _buildControlButtons(),
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.1, // Start collapsed
              minChildSize: 0.09, // Minimum size
              maxChildSize: 0.8, // Fully expanded size
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 1,
                        margin: const EdgeInsets.only(top: 0),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: [
                            const SizedBox(height: 10),
                            AutomationControlsWidget(
                              onSendCommand: _sendCommand,
                              startMoving: _startMoving,
                              stopMoving: _stopMoving,
                              distanceController: _distanceController,
                              onLeftMove: () => _moveInDirection('left'),
                              onRightMove: () => _moveInDirection('right'),
                              ipAddres: widget.ipAddres,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            if (errorMessage.isNotEmpty)
              Positioned(
                bottom: 100,
                left: 20,
                child: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),

                // Add Replay button
              )
          ],
        ),
      ),
    );
  }

  Widget _buildNormalVideoFeewd() {
    return Container(
      color: Colors.black,
      child: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Mjpeg(
            fit: BoxFit.fill,
            isLive: true,
            stream: 'http://${widget.ipAddres}:81/stream',
            loading: (context) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            },
            error: (context, error, stackTrace) {
              print('Error during streaming: $error');
              print('Stack trace: $stackTrace');
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Error: $error',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Stack Trace:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          stackTrace.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNormalVideoFeed() {
    return Container(
      color: Colors.black,
      child: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height, // Full height
          width:
              MediaQuery.of(context).size.width * 0.50, // 60% of screen width
          child: Mjpeg(
            fit: BoxFit.fill,
            isLive: true,
            stream: 'http://${widget.ipAddres}:81/stream',
            loading: (context) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            },
            error: (context, error, stackTrace) {
              print('Error during streaming: $error');
              print('Stack trace: $stackTrace');
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Error: $error',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Stack Trace:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          stackTrace.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Custom Clipper for VR Glasses

  Widget _buildWeedButton() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTapDown: (_) => _startCommand('/ledon'), // Start command for LED ON
        onTapUp: (_) =>
            _stopCommand(stopCommand: '/ledoff'), // Stop command for LED OFF
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: const Icon(
            Icons.electric_bolt_sharp,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(Icons.arrow_upward, "/go"),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(Icons.arrow_back, "/left"),
            _buildWeedButton(),
            _buildButton(Icons.arrow_forward, "/right"),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(Icons.arrow_downward, "/back"),
          ],
        ),
      ],
    );
  }

  Widget _buildButton(IconData icon, command) {
    // bool holdingButton = false;
    return GestureDetector(
      onTapDown: (_) => _startCommand(command),
      onTapUp: (_) => _stopCommand(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: Colors.white,
            width: 2.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }
}
// Custom Clipper for VR Glasses
