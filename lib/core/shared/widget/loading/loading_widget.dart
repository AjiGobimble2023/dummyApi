import 'package:flutter/material.dart';
import '../../../config/extensions.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({this.message, super.key, this.sizedBox});
  final String? message;
  final bool? sizedBox;
  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.all(
          context.pd,
        ),
        decoration: (widget.sizedBox ?? true)
            ? BoxDecoration(
                color: context.background,
                borderRadius: BorderRadius.circular(16),
                boxShadow: kElevationToShadow[2],
              )
            : const BoxDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 3,
            ),
            (widget.message != null)
                ? Column(
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        widget.message!,
                        style: context.text.bodyMedium,
                        textAlign: TextAlign.center,
                      )
                    ],
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
