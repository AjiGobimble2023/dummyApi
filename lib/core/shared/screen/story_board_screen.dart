import 'package:flutter/material.dart';

import '../../config/extensions.dart';
import '../widget/empty/basic_empty.dart';

class StoryBoardScreen extends StatelessWidget {
  final String imgUrl;
  final String title;
  final String subTitle;
  final String storyText;

  const StoryBoardScreen({
    Key? key,
    required this.imgUrl,
    required this.title,
    required this.subTitle,
    required this.storyText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.primaryColor,
              context.secondaryColor,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: const [0.36, 0.8],
          ),
        ),
        child: BasicEmpty(
          imageUrl: imgUrl,
          title: title,
          subTitle: subTitle,
          emptyMessage: storyText,
          textColor: context.onPrimary,
          isLandscape: !context.isMobile,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      floatingActionButton: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.cancel_outlined),
        iconSize: (context.isMobile) ? context.dp(32) : context.dp(20),
        color: context.onSecondary.withOpacity(.8),
        padding: EdgeInsets.symmetric(
          vertical: (context.isMobile) ? context.dp(18) : context.dp(8),
          horizontal: (context.isMobile) ? 0 : context.dp(4),
        ),
      ),
    );
  }
}
