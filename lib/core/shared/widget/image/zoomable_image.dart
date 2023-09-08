import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../../config/extensions.dart';

class ZoomableImageWidget extends StatelessWidget {
  const ZoomableImageWidget({
    Key? key,
    this.imageProvider,
    this.backgroundDecoration,
    this.imgUrl,
  }) : super(key: key);

  final String? imgUrl;
  final ImageProvider? imageProvider;
  final BoxDecoration? backgroundDecoration;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(
        height: MediaQuery.of(context).size.height,
      ),
      child: SafeArea(
        child: Stack(
          children: <Widget>[
            PhotoView(
              imageProvider: imageProvider,
              backgroundDecoration: backgroundDecoration,
              minScale: PhotoViewComputedScale.contained * 0.8,
              maxScale: PhotoViewComputedScale.covered * 1.1,
              heroAttributes: PhotoViewHeroAttributes(
                tag: imgUrl ?? "ZoomableImage",
                transitionOnUserGestures: true,
              ),
              errorBuilder: (context, error, stackTrace) {
                if (kDebugMode) {
                  logger.log(
                      'ERROR LOAD ZOOMABLE IMAGE: $error\nSTACK TRACE: $stackTrace');
                }

                return Padding(
                  padding: const EdgeInsets.all(14),
                  child: Image.asset('assets/img/logo_kreasi_inverse.png'),
                );
              },
            ),
            Positioned(
              top: context.dp(20),
              right: context.dp(20),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const CircleAvatar(
                  backgroundColor: Colors.white54,
                  child: Icon(Icons.close_rounded, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
