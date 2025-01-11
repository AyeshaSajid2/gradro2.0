// ignore_for_file: file_names

import 'package:flutter/material.dart';

import 'led_button.dart';

class AutomationControlsWidget extends StatelessWidget {
  final Function(String) onSendCommand;
  final VoidCallback startMoving;
  final VoidCallback stopMoving;
  final TextEditingController distanceController;
  final VoidCallback onLeftMove;
  final VoidCallback onRightMove;
  final String ipAddres; // Accept IP address as a parameter

  const AutomationControlsWidget({
    super.key,
    required this.onSendCommand,
    required this.startMoving,
    required this.stopMoving,
    required this.distanceController,
    required this.onLeftMove,
    required this.onRightMove,
    required this.ipAddres,
  });

  Widget _buildGradientContainer({
    required Widget child,
    double borderRadius = 20,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7F7F7F), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(4, 4),
            blurRadius: 4,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.2),
            offset: const Offset(-4, -4),
            blurRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: child,
    );
  }

  Widget _buildGradientButton(
      String label, VoidCallback onPressed, Color color, double fontSize) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7F7F7F), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(4, 4),
              blurRadius: 4,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.2),
              offset: const Offset(-4, -4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade500,
            offset: const Offset(4, 4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-4, -4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Automation Controls",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: isSmallScreen ? 8 : 16),
          Row(
            children: [
              Tooltip(
                message: "Press this button to automate the left turn",
                child: GestureDetector(
                  onTap: onLeftMove,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7F7F7F), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(4, 4),
                          blurRadius: 4,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          offset: const Offset(-4, -4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    child: const Icon(Icons.u_turn_left_outlined,
                        color: Colors.white),
                  ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 16),
              Expanded(
                child: GestureDetector(
                  onLongPress: () {
                    // You no longer need to manually invoke the tooltip here.
                    // The Tooltip widget will automatically handle it on long press.
                  },
                  child: Tooltip(
                    message:
                        "Enter distance in meter to start the forward automation",
                    child: _buildGradientContainer(
                      child: TextField(
                        controller: distanceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Enter Distance (meters)",
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 16),
              Tooltip(
                message:
                    "Press this button to automate the right turn for 5 sec",
                child: GestureDetector(
                  onTap: onRightMove,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7F7F7F), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(4, 4),
                          blurRadius: 4,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          offset: const Offset(-4, -4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    child: const Icon(Icons.u_turn_right_outlined,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Tooltip(
                message: "Press this to activate forward smart drive",
                child: _buildGradientButton("Smart Drive", startMoving,
                    Colors.green, isSmallScreen ? 12 : 16),
              ),
              Tooltip(
                message: "Continues weed cutting",
                child: LedControlButton(
                  ipAddres: ipAddres,
                ),
                //"Stop", stopMoving, Colors.red, isSmallScreen ? 12 : 16),
              ),
              Tooltip(
                message: "Stop and reset every motion",
                child: _buildGradientButton(
                    "Stop", stopMoving, Colors.red, isSmallScreen ? 12 : 16),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          for (int row = 0; row < 6; row++)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                10,
                (col) => Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 0.005 * screenWidth),
                  child: Container(
                    width: isSmallScreen ? 10 : 12,
                    height: isSmallScreen ? 15 : 12,
                    decoration: BoxDecoration(
                      color: ((col ~/ 2) % 2 == 0)
                          ? Colors.green[700]
                          : Colors.brown[400],
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          SizedBox(height: screenHeight * 0.02),
        ],
      ),
    );
  }
}
