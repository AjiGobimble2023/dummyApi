import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../../../core/config/extensions.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/config/constant.dart';
import '../../../../../../core/shared/widget/button/custom_animated_icon_button.dart';
import '../../model/feed.dart';
import '../provider/feed_provider.dart';

class FeedActionAndCaption extends StatefulWidget {
  const FeedActionAndCaption({
    Key? key,
    required this.feed,
    required this.isComment,
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

  /// [isCommment] merupakan variable untuk
  /// membedakan tampilan widget dari FeedActionAndCaption
  final bool isComment;

  @override
  State<FeedActionAndCaption> createState() => _FeedActionAndCaptionState();
}

class _FeedActionAndCaptionState extends State<FeedActionAndCaption> {
  /// Kumpulan variable untuk keperluan like
  bool like = false;
  int totalLike = 0;
  bool visibleLove = false;
  @override
  void initState() {
    super.initState();

    /// Initialization value variable like
    like = widget.feed.isLike!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (context.isMobile)
          ? (widget.isComment)
              ? context.dw - (context.pd * 2)
              : context.dw - (context.pd * 4)
          : context.dw - context.dp(132) - (context.pd * 4),
      padding: (widget.isComment)
          ? EdgeInsets.zero
          : EdgeInsets.only(bottom: context.pd),
      child: (!widget.isComment)
          ? Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAction(context),
                _buildCaption(context),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCaption(context),
                SizedBox(
                  height: context.isMobile ? context.pd : context.pd / 2,
                ),
                _buildAction(context),
              ],
            ),
    );
  }

  Container _buildAction(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          bottom: context.isMobile ? context.pd : context.pd / 2),
      child: Row(
        children: [
          Row(
            children: [
              /// Widget Action Like
              _buildActionLike(context),
              SizedBox(
                width: context.pd,
              ),

              /// Widget Action comment
              Visibility(
                visible: !widget.isComment,
                child: GestureDetector(
                  onTap: () {
                    widget.feed.isLike = like;
                    Navigator.pushNamed(
                      context,
                      Constant.kRouteFeedComment,
                      arguments: {
                        "feed": widget.feed,
                        "noRegistrasi": widget.noRegistrasi,
                        "namaLengkap": widget.namaLengkap,
                        "userType": widget.userType,
                      },
                    );
                  },
                  child: Icon(
                    CupertinoIcons.chat_bubble,
                    color: Colors.black,
                    size: context.isMobile ? 24 : 36,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),

          /// Widget Total Like
          Text(
            "${widget.feed.totalLike} suka",
            style: context.isMobile
                ? context.text.bodySmall
                : context.text.bodyMedium?.copyWith(
                    color: Colors.black,
                  ),
          )
        ],
      ),
    );
  }

  Text _buildCaption(BuildContext context) {
    return Text(
      widget.feed.content!,
      style: context.text.bodyMedium,
      textAlign: TextAlign.left,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  CustomAnimatedIconButton _buildActionLike(BuildContext context) {
    return CustomAnimatedIconButton(
      key: Key(widget.feed.feedId!),
      initialState: like,
      isLike: like,
      size: context.isMobile ? 24 : 36,
      icondata: (like) ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
      onTap: (state) async {
        if (state && totalLike <= widget.feed.totalLike!) {
          setState(() {
            if (!like) {
              widget.feed.totalLike;
              widget.feed.totalLike = (widget.feed.totalLike ?? 0) + 1;
              like = state;
            }
          });
        } else if ((like && !state)) {
          setState(() {
            like = state;
            widget.feed.totalLike;
            widget.feed.totalLike = (widget.feed.totalLike ?? 0) - 1;
          });
        }

        String love = (state == true) ? "like" : "unliked";
        context.read<FeedProvider>().responseFeed(
            userId: widget.noRegistrasi,
            feedId: widget.feed.feedId,
            type: love);
      },
    );
  }
}
