import 'package:flutter/material.dart';

void snackBarOverlay(String msg, BuildContext context,
    {Duration duration = const Duration(seconds: 3),
      Color color = Colors.black, //Color(0xFF00838F),
      Color borderColor = const Color.fromARGB(200, 222, 202, 230)}) {

  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 10.0, // Position at the bottom of the screen
      left: MediaQuery.of(context).size.width * 0.3, // Center horizontally
      right: MediaQuery.of(context).size.width * 0.3, // Center horizontally
      child: Material(
        color: Colors.transparent,
        child: Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.horizontal, // Allow horizontal swipe to dismiss
          onDismissed: (_) {
            overlayEntry.remove(); // Remove overlay when dismissed
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6, // Set fixed width
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(25.0),
              border: Border.all(color: borderColor, width: 2.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(
                    msg,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  // Insert the overlay into the Overlay stack
  Overlay.of(context).insert(overlayEntry);

  // Automatically remove the overlay after the specified duration
  Future.delayed(duration, () {
    overlayEntry.remove();
  });
}


