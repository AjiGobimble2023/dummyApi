import 'package:flutter/material.dart';

import '../provider/friends_provider.dart';
import '../screen/friends_profile_screen.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/widget/image/profile_picture_widget.dart';

class ScoreImagePostWidget extends StatelessWidget {
  const ScoreImagePostWidget({
    Key? key,
    required this.widget,
    required this.context,
    required this.value,
  }) : super(key: key);

  final FriendsProfileScreen widget;
  final BuildContext context;
  final FriendsProvider value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              widget.score,
              style: context.text.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold, color: context.background),
            ),
            Text(
              "Skor",
              style:
                  context.text.bodyMedium?.copyWith(color: context.background),
            ),
          ],
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(bottom: 10, right: 30, left: 30),
          child: CircleAvatar(
            radius: context.dp(42),
            backgroundColor: context.secondaryColor,
            child: ProfilePictureWidget.circle(
              name: widget.namaLengkap,
              width: context.dp(78),
              noRegistrasi: widget.noRegistrasi,
              // userType: widget.userType,
            ),
          ),
        ),
        Column(
          children: [
            Text(
              value.listFriendFeeds.length.toString(),
              style: context.text.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold, color: context.background),
            ),
            Text(
              "Post",
              style:
                  context.text.bodyMedium?.copyWith(color: context.background),
            ),
          ],
        ),
      ],
    );
  }
}
