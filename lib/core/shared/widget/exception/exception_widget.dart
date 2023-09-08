import 'package:flutter/material.dart';

import '../../../config/extensions.dart';

class ExceptionWidget extends StatelessWidget {
  final String exceptionMessage;

  const ExceptionWidget(String? error,
      {Key? key, required this.exceptionMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.info_outline,
            size: context.dw * .3,
          ),
          SizedBox(height: context.dp(22)),
          Text(
            exceptionMessage,
            textAlign: TextAlign.center,
            style: context.text.titleMedium,
          ),
        ],
      ),
    );
  }
}

class SliverExceptionWidget extends StatelessWidget {
  final String exceptionMessage;

  const SliverExceptionWidget(String s,
      {Key? key, required this.exceptionMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 30.0,
                ),
                SizedBox(width: 5.0),
                Text(
                  'Oops...',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 15.0),
            Text(
              exceptionMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
