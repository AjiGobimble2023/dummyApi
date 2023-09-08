import 'package:flutter/material.dart';

class CustomWillPopScope extends StatelessWidget {
  final Future<bool> Function()? onWillPop;
  final VoidCallback onDragRight;
  final Widget child;
  final int swipeSensitivity;

  const CustomWillPopScope({
    Key? key,
    this.onWillPop,
    required this.child,
    required this.onDragRight,
    this.swipeSensitivity = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: onWillPop,
        child: GestureDetector(
            onHorizontalDragUpdate: (details) async {
              //set the sensitivity for your ios gesture anywhere between 10-50 is good
              int sensitivity = swipeSensitivity;

              if (details.delta.dx > sensitivity) {
                //SWIPE FROM RIGHT DETECTION
                onDragRight();
              }
            },
            child: child));
  }
}
