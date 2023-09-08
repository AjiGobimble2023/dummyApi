import 'package:flutter/material.dart';
import '../../../../../../core/config/extensions.dart';
import 'friend_feed_widget.dart';
import 'list_friends_from_friend_widget.dart';

import '../screen/friends_profile_screen.dart';

class ProfileBodyWidget extends StatelessWidget {
  const ProfileBodyWidget({
    Key? key,
    required this.widget,
    required this.context,
  }) : super(key: key);

  final FriendsProfileScreen widget;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        // padding: const EdgeInsets.only(right: 12, left: 12),
        decoration: BoxDecoration(
            color: context.background,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(30),
              topLeft: Radius.circular(30),
            )),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 10),
            DefaultTabController(
              length: 2,
              initialIndex: 0,
              child: Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.0),
                        border: Border(
                            bottom: BorderSide(color: context.hintColor)),
                      ),
                      child: TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: context.primaryColor,
                        labelStyle: context.text.bodyMedium,
                        unselectedLabelStyle: context.text.bodyMedium,
                        unselectedLabelColor: context.hintColor,
                        indicatorColor: context.primaryColor,
                        indicator: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                            color: context.primaryColor,
                            width: 2,
                          )),
                        ),
                        tabs: const [
                          Tab(text: 'Feeds'),
                          Tab(text: 'Friends'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        physics: const ClampingScrollPhysics(),
                        children: <Widget>[
                          FriendFeedWidget(widget: widget),
                          ListFriendsFromFriendWidget(widget: widget)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
