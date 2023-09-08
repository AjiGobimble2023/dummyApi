import 'package:flutter/material.dart';

import '../../../config/extensions.dart';

class RefreshExceptionWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onTap;

  const RefreshExceptionWidget({Key? key, required this.message, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          message,
          textScaleFactor: context.textScale12,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8.0),
        GestureDetector(
          onTap: onTap,
          child: ClipOval(
            child: Container(
              color: Colors.black.withOpacity(0.2),
              height: 32.0,
              width: 32.0,
              child: const Center(child: Icon(Icons.refresh)),
            ),
          ),
        ),
      ],
    );
  }
}
