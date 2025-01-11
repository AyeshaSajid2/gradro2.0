import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LedControlButton extends StatefulWidget {
  final String ipAddres;

  const LedControlButton({super.key, required this.ipAddres});

  @override
  _LedControlButtonState createState() => _LedControlButtonState();
}

class _LedControlButtonState extends State<LedControlButton> {
  bool isLedOn = false;
  bool isContinuous = false;
  Timer? _ledTimer;

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

  // Function to toggle the LED state
  void _toggleLedState() {
    if (isLedOn) {
      _stopClEDommand(); // Send /ledoff once and stop the continuous command
    } else {
      _startContinuousCommand(); // Start the continuous sending of /ledon command
    }
  }

  // Function to start sending the /ledon command continuously
  void _startContinuousCommand() {
    isLedOn = true;
    isContinuous = true;
    _ledTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (isLedOn) {
        print("/ledon");
        _sendCommand(
            'ledon'); // Replace with actual command logic to send /ledon
      }
    });
    setState(() {});
  }

  // Function to stop sending the /ledon command continuously and send /ledoff once
  void _stopClEDommand() {
    print("/ledoff"); // Send the /ledoff command (this stops the LED)
    _stopContinuousCommand(); // Stop the continuous sending of /ledon
    setState(() {
      isLedOn = false; // Update the LED state to off
      isContinuous = false; // Stop the continuous command
    });
  }

  // Function to stop the continuous sending of /ledon
  void _stopContinuousCommand() {
    _ledTimer?.cancel();
    _sendCommand('ledoff'); // Cancel the periodic timer
  }

  // Function to handle the behavior when the button is pressed down
  void _onTapDown() {
    // You can add visual feedback for button press down here if needed
  }

  // Handle the behavior when the button is released
  void _onTapUp() {
    // You can add visual feedback for button release here if needed
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: _toggleLedState, // Toggle LED state on button press
        onTapDown: (_) =>
            _onTapDown(), // Handle when the button is pressed down
        onTapUp: (_) => _onTapUp(), // Handle when the button is released
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
          child: Icon(
            Icons.electric_bolt_sharp,
            color: isLedOn
                ? Colors.green
                : Colors.white, // LED is green if on, white if off
            size: 40, // Icon size can be adjusted as per your design
          ),
        ),
      ),
    );
  }
}
