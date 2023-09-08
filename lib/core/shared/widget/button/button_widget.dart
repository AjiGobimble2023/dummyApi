import 'package:flutter/material.dart';

import '../../../config/extensions.dart';

// ignore: constant_identifier_names
enum ButtonType { Simple, Icon, Flat }

class ButtonWidget extends StatefulWidget {
  final Color? color;
  final IconData? icon;
  final String? label;
  final void Function() onTap;
  final ButtonType type;

  const ButtonWidget({
    super.key,
    this.color,
    this.icon,
    this.label,
    required this.onTap,
    required this.type,
  });

  @override
  State<ButtonWidget> createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case ButtonType.Icon:
        return ElevatedButton.icon(
          icon: Icon(
            widget.icon ?? Icons.add,
            color: Colors.white,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color ?? context.primaryColor,
            shape: const StadiumBorder(),
          ),
          label: Text(
            widget.label ?? 'OK',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 4.0,
            ),
          ),
          onPressed: widget.onTap,
        );

      case ButtonType.Simple:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color ?? context.primaryColor,
            shape: const StadiumBorder(),
          ),
          onPressed: widget.onTap,
          child: Text(
            widget.label ?? 'OK',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 4.0,
            ),
          ),
        );

      default:
        return ButtonTheme(
          minWidth: 50.0,
          height: 30.0,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color ?? context.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            onPressed: widget.onTap,
            child: Text(
              widget.label ?? 'OK',
              style: const TextStyle(color: Colors.white, fontSize: 12.0),
            ),
          ),
        );
    }
  }
}
