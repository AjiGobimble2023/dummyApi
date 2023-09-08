import 'package:flutter/material.dart';
import '../../../../../../core/config/extensions.dart';
import 'feed_action_and_caption.dart';
import 'feed_body_widget.dart';
import 'feed_header_widget.dart';

import '../../model/feed.dart';

class FeedCardWidget extends StatelessWidget {
  const FeedCardWidget({
    Key? key,
    required this.feed,
    required this.noRegistrasi,
    required this.namaLengkap,
    required this.userType,
  }) : super(key: key);

  final String noRegistrasi;
  final String namaLengkap;
  final String userType;

  /// [feed] merupakan variable yang berisi data
  /// dari Class Feed yang teridiri dari (feedId, creatorId, creatorName,
  /// creatorRole, image, content, status, isLike, totalLike dan date)
  final Feed feed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.pd),
      child: Container(
        width: context.dw - (context.pd * 2),
        decoration: BoxDecoration(
          color: context.background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: kElevationToShadow[2],
        ),
        child: Column(
          children: [
            /// Widget FeedHeaderWidget terdiri dari foto profil, nama,
            /// tanggal upload status feed dan button action feed
            FeedHeaderWidget(
              noRegistrasi: noRegistrasi,
              namaLengkap: namaLengkap,
              userType: userType,
              feed: feed,
            ),

            /// Widget FeedBodyWidget berisi gambar feed
            FeedBodyWidget(
              feed: feed,
              isComment: false,
            ),

            /// Widget FeedActionAndCaption terdiri dari
            /// action (like dan comment) dan caption dari feed
            FeedActionAndCaption(
              noRegistrasi: noRegistrasi,
              namaLengkap: namaLengkap,
              userType: userType,
              feed: feed,
              isComment: false,
            ),
          ],
        ),
      ),
    );
  }
}
