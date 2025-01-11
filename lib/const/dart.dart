// import 'package:back_pressed/back_pressed.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_mjpeg/flutter_mjpeg.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:freeman/src/router_helper.dart';
// import 'package:http/http.dart' as http;
// import 'package:video_player/video_player.dart';
//
// class VrMonitoringPage extends StatefulWidget {
//   final String ipAddres;
//
//   const VrMonitoringPage({super.key, required this.ipAddres});
//
//   @override
//   _VrMonitoringPageState createState() => _VrMonitoringPageState();
// }
//
// class _VrMonitoringPageState extends State<VrMonitoringPage> {
//   bool isVRMode = false;
//   bool holdingButton = false;
//   List<String> recordedCommands = []; // To store recorded commands
//   List<Duration> recordedPressDurations = []; // To store how long the button is being pressed
//   List<Duration> recordedClickIntervals = []; // To store durations between clicks
//   bool isRecording = false; // To track recording state
//   bool isReplaying = false;
//   bool stopReplayRequested = false; // Track playback state
//
//   DateTime? buttonPressStartTime;
//   DateTime? lastClickTime; // Store last click time
//
// // Send command when the button is pressed
//   // Send command to device
//   Future<void> _sendCommand(String command) async {
//     try {
//       final response = await http.get(
//         Uri.parse('http://${widget.ipAddres}$command'),
//       );
//
//       if (response.statusCode == 200) {
//         print('Command sent successfully: $command');
//       } else {
//         print('Failed to send command: http://${widget.ipAddres}$command');
//       }
//     } catch (error) {
//       print('Error sending command: $error');
//     }
//   }
//
//   void _startCommand(String command) {
//     if (!holdingButton) {
//       _sendCommand(command); // Send the command
//       holdingButton = true;
//       buttonPressStartTime = DateTime.now(); // Start timing the button press
//
//       // If recording, capture the command and duration
//       if (isRecording) {
//         recordedCommands.add(command);
//
//         // Calculate the time interval between the last click and this click
//         if (lastClickTime != null) {
//           recordedClickIntervals.add(buttonPressStartTime!.difference(lastClickTime!));
//         } else {
//           recordedClickIntervals.add(Duration.zero); // For the first command
//         }
//
//         lastClickTime = buttonPressStartTime;
//         print('Start command: $command at $buttonPressStartTime');
//       }
//     }
//   }
//
// // Send stop command when the button is released
//   void _stopCommand({String stopCommand = '/stop'}) {
//     if (holdingButton) {
//       _sendCommand(stopCommand); // Send stop command
//       holdingButton = false;
//
//       var stopTime = DateTime.now();
//
//       // If recording, capture the duration of the button press
//       if (isRecording && buttonPressStartTime != null) {
//         var pressDuration = stopTime.difference(buttonPressStartTime!);
//         recordedPressDurations.add(pressDuration);
//         print('Stop command: Button held for $pressDuration');
//       }
//
//       buttonPressStartTime = null; // Reset start time
//       if(stopCommand == '/ledoff')
//         print("weed cutting stped");
//     }
//   }
//
// // Toggle recording mode
//   void _toggleRecording() {
//     if (isReplaying) {
//       // Show warning if replay is running
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Cannot start recording while replaying!', style: TextStyle(color: Colors.black)),
//           backgroundColor: Colors.white,
//         ),
//       );
//     } else {
//       // Toggle recording state
//       setState(() {
//         isRecording = !isRecording;
//         if (isRecording) {
//           recordedCommands.clear();
//           recordedPressDurations.clear(); // Clear press durations on new recording
//           recordedClickIntervals.clear(); // Clear click intervals on new recording
//           buttonPressStartTime = null;
//           lastClickTime = null; // Reset last click time
//           print("Recording started...");
//         } else {
//           print("Recording stopped. Recorded commands: $recordedCommands");
//           print("Recorded press durations: $recordedPressDurations");
//           print("Recorded click intervals: $recordedClickIntervals");
//         }
//       });
//     }
//   }
//
//   void _toggleReplay() async {
//     if (isRecording) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Cannot replay while recording", style: TextStyle(color: Colors.black)),
//           backgroundColor: Colors.white,
//         ),
//       );
//       return;
//     } else if (isReplaying) {
//       _stopReplay();
//       return;
//     }
//
//     if (recordedCommands.isNotEmpty && recordedPressDurations.isNotEmpty) {
//       setState(() {
//         isReplaying = true;
//         stopReplayRequested = false;
//       });
//
//       // Iterate over the recorded commands and durations
//       for (int i = 0; i < recordedCommands.length; i++) {
//         if (stopReplayRequested) {
//           _stopReplay();
//           return;
//         }
//
//         // 1. Send the start command to simulate button press
//         String currentCommand = recordedCommands[i];
//         print("Replaying command: $currentCommand");
//         await _sendCommand(currentCommand);
//
//         // 2. Wait for the duration the button was held down (the press duration)
//         print("Replaying Press Duration: ${recordedPressDurations[i]}");
//         await Future.delayed(recordedPressDurations[i]);
//
//         // 3. Send the appropriate stop command based on the command type
//         if (currentCommand == '/ledon') {
//           // If the command was 'ledon', send 'ledoff' when stopping
//           await _sendCommand('/ledoff');
//           print("LED off command sent");
//         } else {
//           // For all other commands, send the normal 'stop'
//           await _sendCommand('/stop');
//           print("Stop command sent");
//         }
//
//         // 4. If there is a next press, introduce the delay (idle time between presses)
//         if (i < recordedClickIntervals.length) {
//           print("Waiting for next command for duration: ${recordedClickIntervals[i]}");
//           await Future.delayed(recordedClickIntervals[i]);
//         }
//
//         // Check again if stop was requested during the waiting period
//         if (stopReplayRequested) {
//           _stopReplay();
//           return;
//         }
//       }
//
//       setState(() {
//         isReplaying = false;
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("No recorded commands to replay.", style: TextStyle(color: Colors.black)),
//           backgroundColor: Colors.white,
//         ),
//       );
//     }
//   }
//
//
//
//   void _stopReplay() {
//     setState(() {
//       print("Stopeddd");
//       // Mark that a stop has been requested
//       isReplaying = false;
//       stopReplayRequested = true;
//       // _sendCommand('/stop');
//       print("Stopeddd");
//       // Update replay state
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text("Replay stopped", style: TextStyle(color: Colors.black)),
//         backgroundColor: Colors.white,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return OnBackPressed(
//       perform: () => Routes.pushNamedAndRemoveUntil(Routes.home),
//       child: Scaffold(
//         body: Stack(
//           children: <Widget>[
//             Container(
//               color: Colors.black,
//               child: isVRMode
//                   ? _buildVrlVideoFeed()
//                   : _buildNormalVideoFeed(),
//             ),
//             Positioned(
//               top: 20,
//               left: 20,
//               child: GestureDetector(
//                 onTap: () => Routes.pushNamedAndRemoveUntil(Routes.home),
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     color: Colors.black,
//                     shape: BoxShape.circle,
//                   ),
//                   padding: const EdgeInsets.all(16),
//                   child: const Icon(
//                     Icons.arrow_back,
//                     color: Colors.white,
//                     size: 32.0,
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               top: 30,
//               right: 20,
//               child: _buildVRButton(),
//             ),
//             Positioned(
//               top: 30,
//               right: 120,
//               child: GestureDetector(
//                 onTap: _toggleReplay,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: isReplaying ? Colors.white : Colors.black,
//                     borderRadius: BorderRadius.circular(20.0),
//                     border: Border.all(
//                       color: isReplaying ? Colors.black : Colors.white,
//                       width: 2.0,
//                     ),
//                   ),
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: Text(
//                     isReplaying ? 'Stop' : 'Autopilot',
//                     style: TextStyle(
//                       color: isReplaying ? Colors.black : Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             // Add Record button
//             Positioned(
//               top: 30,
//               right: 242,
//               child: GestureDetector(
//                 onTap: _toggleRecording,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: isRecording ? Colors.white : Colors.black,
//                     borderRadius: BorderRadius.circular(20.0),
//                     border: Border.all(
//                       color: isRecording ? Colors.black : Colors.white,
//                       width: 2.0,
//                     ),
//                   ),
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: Text(
//                     isRecording ? 'Done' : 'Track',
//                     style: TextStyle(
//                       color: isRecording ? Colors.black : Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: 00,
//               right: 20,
//               child: _buildControlButtons(),
//             ),
//
//
//             // Add Replay button
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildVRButton() {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           isVRMode = !isVRMode;
//         });
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: isVRMode ? Colors.white : Colors.black,
//           borderRadius: BorderRadius.circular(20.0),
//           border: Border.all(
//             color: isVRMode ? Colors.black : Colors.white,
//             width: 2.0,
//           ),
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         child: Text(
//           isVRMode ? 'VR OFF' : 'VR ON',
//           style: TextStyle(
//             color: isVRMode ? Colors.black : Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNormalVideoFeed() {
//     return Container(
//       color: Colors.black,
//       child: Center(
//         child: SizedBox(
//           height: MediaQuery.of(context).size.height,
//           width: MediaQuery.of(context).size.width,
//           child: Mjpeg(
//             fit: BoxFit.fill,
//             isLive: true,
//             stream: 'http://${widget.ipAddres}:81/stream',
//             loading: (context) {
//               return const Center(
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               );
//             },
//             error: (context, error, stackTrace) {
//               print('Error during streaming: $error');
//               print('Stack trace: $stackTrace');
//               return Center(
//                 child: Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: SvgPicture.asset(
//                     'assets/error.svg',
//                     width: MediaQuery.of(context).size.width * 0.25,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildVrlVideoFeed() {
//     return Container(
//       child: Stack(
//         children: [
//           // Single video stream
//           Positioned.fill(
//             child: Mjpeg(
//               fit: BoxFit.cover, // Make sure video covers the screen
//               isLive: true,
//               stream: 'http://${widget.ipAddres}:81/stream', // Single stream call
//               loading: (context) {
//                 return const Center(
//                   child: CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                   ),
//                 );
//               },
//               error: (context, error, stackTrace) {
//                 print('Error during streaming: $error'); // Debugging line
//                 print('Stack trace: $stackTrace'); // Debugging line
//                 return Center(
//                   child: Padding(
//                     padding: const EdgeInsets.all(20.0),
//                     child: SvgPicture.asset(
//                       'assets/error.svg',
//                       width: MediaQuery.of(context).size.width * 0.25,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//
//           // VR glasses container
//           Positioned.fill(
//             child: ClipPath(
//               clipper: VRGlassesClipper(),
//               child: Container(
//                 color: Colors.black.withOpacity(0.5), // Semi-transparent background
//                 child: Stack(
//                   children: [
//                     // Left eye box
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Container(
//                         width: MediaQuery.of(context).size.width / 2,
//                         color: Colors.black, // Black for the left eye
//                       ),
//                     ),
//                     // Right eye box
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: Container(
//                         width: MediaQuery.of(context).size.width / 2,
//                         color: Colors.black, // Black for the right eye
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//
//           // Vertical line in the middle
//           Positioned(
//             left: MediaQuery.of(context).size.width / 2 - 1, // Center the line
//             top: 0,
//             bottom: 0,
//             child: Container(
//               width: 2, // Width of the vertical line
//               color: Colors.white, // Color of the line
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//
//
//
//
// // Custom Clipper for VR Glasses
//
//
//   Widget _buildWeedButton() {
//     return Padding(
//       padding: const EdgeInsets.all(10.0),
//       child: GestureDetector(
//         onTapDown: (_) => _startCommand('/ledon'),  // Start command for LED ON
//         onTapUp: (_) => _stopCommand(stopCommand: '/ledoff'),  // Stop command for LED OFF
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.black,
//             shape: BoxShape.circle,
//             border: Border.all(
//               color: Colors.white,
//               width: 2.0,
//             ),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//           child: const Icon(
//             Icons.electric_bolt_sharp,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildControlButtons() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spreads elements evenly
//       children: [
//         _buildWeedButton(),
//         SizedBox(width: 550,),
//
//         Column(
//           children: [
//             Row(
//               children: [
//                 _buildButton(Icons.arrow_upward, "/go"),
//               ],
//             ),
//             Row(
//               children: [
//                 _buildButton(Icons.arrow_back, "/left"),
//                 const SizedBox(width: 20),
//                 _buildButton(Icons.arrow_forward, "/right"),
//               ],
//             ),
//             Row(
//               children: [
//                 _buildButton(Icons.arrow_downward, "/back"),
//               ],
//             ),
//           ],
//         ),
//
//       ],
//     );
//   }
//
//
//   Widget _buildButton(IconData icon,command) {
//     // bool holdingButton = false;
//     return GestureDetector(
//       onTapDown: (_) => _startCommand(command),
//       onTapUp: (_) => _stopCommand(),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.black,
//           borderRadius: BorderRadius.circular(10.0),
//           border: Border.all(
//             color: Colors.white,
//             width: 2.0,
//           ),
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
//         child: Icon(
//           icon,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
// }
// // Custom Clipper for VR Glasses
// class VRGlassesClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     Path path = Path();
//     Color: Colors.white;
//     // Create a rounded rectangle for the glasses effect
//     path.addRRect(RRect.fromLTRBR(
//       0,
//       0,
//       size.width,
//       size.height,
//       const Radius.circular(40),
//       // Rounded edges for glasses
//     ));
//
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) {
//     return false;
//   }}
//
// /////////////////////////////////////
// import 'package:back_pressed/back_pressed.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_mjpeg/flutter_mjpeg.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:freeman/src/router_helper.dart';
// import 'package:http/http.dart' as http;
// import 'package:video_player/video_player.dart';
//
// class MonitoringPage extends StatefulWidget {
//   final String ipAddres;
//
//   const MonitoringPage({super.key, required this.ipAddres});
//
//   @override
//   _MonitoringPageState createState() => _MonitoringPageState();
// }
//
// class _MonitoringPageState extends State<MonitoringPage> {
//   bool holdingButton = false;
//   List<String> recordedCommands = []; // To store recorded commands
//   List<Duration> recordedPressDurations = []; // To store how long the button is being pressed
//   List<Duration> recordedClickIntervals = []; // To store durations between clicks
//   bool isRecording = false; // To track recording state
//   bool isReplaying = false;
//   bool stopReplayRequested = false; // Track playback state
//
//   DateTime? buttonPressStartTime;
//   DateTime? lastClickTime; // Store last click time
//
// // Send command when the button is pressed
//   // Send command to device
//   Future<void> _sendCommand(String command) async {
//     try {
//       final response = await http.get(
//         Uri.parse('http://${widget.ipAddres}$command'),
//       );
//
//       if (response.statusCode == 200) {
//         print('Command sent successfully: $command');
//       } else {
//         print('Failed to send command: http://${widget.ipAddres}$command');
//       }
//     } catch (error) {
//       print('Error sending command: $error');
//     }
//   }
//
//   void _startCommand(String command) {
//     if (!holdingButton) {
//       _sendCommand(command); // Send the command
//       holdingButton = true;
//       buttonPressStartTime = DateTime.now(); // Start timing the button press
//
//       // If recording, capture the command and duration
//       if (isRecording) {
//         recordedCommands.add(command);
//
//         // Calculate the time interval between the last click and this click
//         if (lastClickTime != null) {
//           recordedClickIntervals.add(buttonPressStartTime!.difference(lastClickTime!));
//         } else {
//           recordedClickIntervals.add(Duration.zero); // For the first command
//         }
//
//         lastClickTime = buttonPressStartTime;
//         print('Start command: $command at $buttonPressStartTime');
//       }
//     }
//   }
//
// // Send stop command when the button is released
//   void _stopCommand({String stopCommand = '/stop'}) {
//     if (holdingButton) {
//       _sendCommand(stopCommand); // Send stop command
//       holdingButton = false;
//
//       var stopTime = DateTime.now();
//
//       // If recording, capture the duration of the button press
//       if (isRecording && buttonPressStartTime != null) {
//         var pressDuration = stopTime.difference(buttonPressStartTime!);
//         recordedPressDurations.add(pressDuration);
//         print('Stop command: Button held for $pressDuration');
//       }
//
//       buttonPressStartTime = null; // Reset start time
//       if(stopCommand == '/ledoff')
//         print("weed cutting stped");
//     }
//   }
//
// // Toggle recording mode
//   void _toggleRecording() {
//     if (isReplaying) {
//       // Show warning if replay is running
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Cannot start recording while replaying!', style: TextStyle(color: Colors.black)),
//           backgroundColor: Colors.white,
//         ),
//       );
//     } else {
//       // Toggle recording state
//       setState(() {
//         isRecording = !isRecording;
//         if (isRecording) {
//           recordedCommands.clear();
//           recordedPressDurations.clear(); // Clear press durations on new recording
//           recordedClickIntervals.clear(); // Clear click intervals on new recording
//           buttonPressStartTime = null;
//           lastClickTime = null; // Reset last click time
//           print("Recording started...");
//         } else {
//           print("Recording stopped. Recorded commands: $recordedCommands");
//           print("Recorded press durations: $recordedPressDurations");
//           print("Recorded click intervals: $recordedClickIntervals");
//         }
//       });
//     }
//   }
//
//   // void _toggleReplay() async {
//   //   if (isRecording) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(
//   //         content: Text("Cannot replay while recording", style: TextStyle(color: Colors.black)),
//   //         backgroundColor: Colors.white,
//   //       ),
//   //     );
//   //     return;
//   //   } else if (isReplaying) {
//   //     _stopReplay();
//   //     return;
//   //   }
//   //
//   //   if (recordedCommands.isNotEmpty && recordedPressDurations.isNotEmpty) {
//   //     setState(() {
//   //       isReplaying = true;
//   //       stopReplayRequested = false;
//   //     });
//   //
//   //     // Iterate over the recorded commands and durations
//   //     for (int i = 0; i < recordedCommands.length; i++) {
//   //       if (stopReplayRequested) {
//   //         _stopReplay();
//   //         return;
//   //       }
//   //
//   //       // 1. Send the start command to simulate button press
//   //       String currentCommand = recordedCommands[i];
//   //       print("Replaying command: $currentCommand");
//   //       await _sendCommand(currentCommand);
//   //
//   //       // 2. Wait for the duration the button was held down (the press duration)
//   //       print("Replaying Press Duration: ${recordedPressDurations[i]}");
//   //       await Future.delayed(recordedPressDurations[i]);
//   //
//   //       // 3. Send the appropriate stop command based on the command type
//   //       if (currentCommand == '/ledon') {
//   //         // If the command was 'ledon', send 'ledoff' when stopping
//   //         await _sendCommand('/ledoff');
//   //         print("LED off command sent");
//   //       } else {
//   //         // For all other commands, send the normal 'stop'
//   //         await _sendCommand('/stop');
//   //         print("Stop command sent");
//   //       }
//   //
//   //       // 4. If there is a next press, introduce the delay (idle time between presses)
//   //       if (i < recordedClickIntervals.length) {
//   //         print("Waiting for next command for duration: ${recordedClickIntervals[i]}");
//   //         await Future.delayed(recordedClickIntervals[i]);
//   //       }
//   //
//   //       // Check again if stop was requested during the waiting period
//   //       if (stopReplayRequested) {
//   //         _stopReplay();
//   //         return;
//   //       }
//   //     }
//   //
//   //     setState(() {
//   //       isReplaying = false;
//   //     });
//   //   } else {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(
//   //         content: Text("No recorded commands to replay.", style: TextStyle(color: Colors.black)),
//   //         backgroundColor: Colors.white,
//   //       ),
//   //     );
//   //   }
//   // }
//   void _toggleReplay() async {
//     if (isRecording) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Cannot replay while recording", style: TextStyle(color: Colors.black)),
//           backgroundColor: Colors.white,
//         ),
//       );
//       return;
//     } else if (isReplaying) {
//       _stopReplay();
//       return;
//     }
//
//     if (recordedCommands.isNotEmpty && recordedPressDurations.isNotEmpty) {
//       setState(() {
//         isReplaying = true;
//         stopReplayRequested = false;
//       });
//
//       // Create a list to store all replay Futures
//       List<Future<void>> replayTasks = [];
//
//       for (int i = 0; i < recordedCommands.length; i++) {
//         // Record the starting time of each command relative to the first one
//         final Duration initialDelay = recordedClickIntervals[i];
//
//         // Add each replay task to the list
//         replayTasks.add(Future.delayed(initialDelay, () async {
//           if (stopReplayRequested) return;
//
//           String currentCommand = recordedCommands[i];
//           print("Replaying command: $currentCommand");
//
//           // Send the start command
//           await _sendCommand(currentCommand);
//
//           // Wait for the press duration
//           await Future.delayed(recordedPressDurations[i]);
//           print("Replaying Press duration $recordedPressDurations");
//
//           // Send the stop command
//           if (currentCommand == '/ledon') {
//             await _sendCommand('/ledoff');
//           } else {
//             await _sendCommand('/stop');
//           }
//         }));
//       }
//
//       // Wait for all replay tasks to complete
//       await Future.wait(replayTasks);
//
//       setState(() {
//         isReplaying = false;
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("No recorded commands to replay.", style: TextStyle(color: Colors.black)),
//           backgroundColor: Colors.white,
//         ),
//       );
//     }
//   }
//
//
//
//   void _stopReplay() {
//     setState(() {
//       print("Stopeddd");
//       // Mark that a stop has been requested
//       isReplaying = false;
//       stopReplayRequested = true;
//       // _sendCommand('/stop');
//       print("Stopeddd");
//       // Update replay state
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text("Replay stopped", style: TextStyle(color: Colors.black)),
//         backgroundColor: Colors.white,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return OnBackPressed(
//       perform: () => Routes.pushNamedAndRemoveUntil(Routes.home),
//       child: Scaffold(
//         body: Stack(
//           children: <Widget>[
//             Container(
//               color: Colors.black,
//               child: _buildNormalVideoFeed(),
//             ),
//             Positioned(
//               top: 20,
//               left: 20,
//               child: GestureDetector(
//                 onTap: () => Routes.pushNamedAndRemoveUntil(Routes.home),
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     color: Colors.black,
//                     shape: BoxShape.circle,
//                   ),
//                   padding: const EdgeInsets.all(16),
//                   child: const Icon(
//                     Icons.arrow_back,
//                     color: Colors.white,
//                     size: 32.0,
//                   ),
//                 ),
//               ),
//             ),
//
//             Positioned(
//               top: 30,
//               right: 20,
//               child: GestureDetector(
//                 onTap: _toggleReplay,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: isReplaying ? Colors.white : Colors.black,
//                     borderRadius: BorderRadius.circular(20.0),
//                     border: Border.all(
//                       color: isReplaying ? Colors.black : Colors.white,
//                       width: 2.0,
//                     ),
//                   ),
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: Text(
//                     isReplaying ? 'Stop' : 'Autopilot',
//                     style: TextStyle(
//                       color: isReplaying ? Colors.black : Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             // Add Record button
//             Positioned(
//               top: 30,
//               right: 130,
//               child: GestureDetector(
//                 onTap: _toggleRecording,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: isRecording ? Colors.white : Colors.black,
//                     borderRadius: BorderRadius.circular(20.0),
//                     border: Border.all(
//                       color: isRecording ? Colors.black : Colors.white,
//                       width: 2.0,
//                     ),
//                   ),
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: Text(
//                     isRecording ? 'Done' : 'Track',
//                     style: TextStyle(
//                       color: isRecording ? Colors.black : Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: 00,
//               right: 20,
//               child: _buildControlButtons(),
//             ),
//             Positioned(
//               bottom: 30,
//               left: 20,
//               child: _buildWeedButton(),
//             )
//
//
//             // Add Replay button
//           ],
//         ),
//       ),
//     );
//   }
//
//
//   Widget _buildNormalVideoFeed() {
//     return Container(
//       color: Colors.black,
//       child: Center(
//         child: SizedBox(
//           height: MediaQuery.of(context).size.height,
//           width: MediaQuery.of(context).size.width,
//           child: Mjpeg(
//             fit: BoxFit.fill,
//             isLive: true,
//             stream: 'http://${widget.ipAddres}:81/stream',
//             loading: (context) {
//               return const Center(
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               );
//             },
//             error: (context, error, stackTrace) {
//               print('Error during streaming: $error');
//               print('Stack trace: $stackTrace');
//               return Center(
//                 child: Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: SvgPicture.asset(
//                     'assets/error.svg',
//                     width: MediaQuery.of(context).size.width * 0.25,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//
//   // Custom Clipper for VR Glasses
//
//   Widget _buildWeedButton() {
//     return Padding(
//       padding: const EdgeInsets.all(10.0),
//       child: GestureDetector(
//         onTapDown: (_) => _startCommand('/ledon'),  // Start command for LED ON
//         onTapUp: (_) => _stopCommand(stopCommand: '/ledoff'),  // Stop command for LED OFF
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.black,
//             shape: BoxShape.circle,
//             border: Border.all(
//               color: Colors.white,
//               width: 2.0,
//             ),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//           child: const Icon(
//             Icons.electric_bolt_sharp,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
//   Widget _buildControlButtons() {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _buildButton(Icons.arrow_upward, "/go"),
//           ],
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _buildButton(Icons.arrow_back, "/left"),
//             const SizedBox(width: 45),
//             _buildButton(Icons.arrow_forward, "/right"),
//           ],
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _buildButton(Icons.arrow_downward, "/back"),
//           ],
//         ),
//       ],
//     );
//   }
//
//
//
//
//   Widget _buildButton(IconData icon,command) {
//     // bool holdingButton = false;
//     return GestureDetector(
//       onTapDown: (_) => _startCommand(command),
//       onTapUp: (_) => _stopCommand(),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.black,
//           borderRadius: BorderRadius.circular(10.0),
//           border: Border.all(
//             color: Colors.white,
//             width: 2.0,
//           ),
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
//         child: Icon(
//           icon,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
// }
// // Custom Clipper for VR Glasses