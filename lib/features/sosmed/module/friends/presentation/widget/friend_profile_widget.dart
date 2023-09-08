import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/friends_provider.dart';
import '../screen/friends_profile_screen.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../../../core/shared/builder/responsive_builder.dart';
import '../../../../../../core/shared/widget/image/custom_image_network.dart';
import '../../../../../../core/shared/widget/image/profile_picture_widget.dart';

class ProfileFriendWidget extends StatefulWidget {
  final Widget? headerMenu;
  final Widget? profileHeader;
  final FriendsProfileScreen? friendWidget;

  const ProfileFriendWidget({
    Key? key,
    this.headerMenu,
    this.profileHeader,
    required this.friendWidget,
  }) : super(key: key);

  @override
  State<ProfileFriendWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileFriendWidget>
    with SingleTickerProviderStateMixin {
  // late final AuthOtpProvider _authOtpProvider =
  //     context.watch<AuthOtpProvider>();
  // Future<void> _onRefreshProfile(RefreshController controller) async {
  //   await _authOtpProvider.login(
  //     otp: '0000',
  //     nomorHpRefresh: _authOtpProvider.isOrtu
  //         ? _authOtpProvider.userData?.nomorHpOrtu
  //         : _authOtpProvider.userData?.nomorHp,
  //     userTypeRefresh: _authOtpProvider.userData?.siapa,
  //     noRegistrasiRefresh: _authOtpProvider.userData?.noRegistrasi,
  //   );
  //   await KreasiSharedPref().simpanDataLokal();
  //   controller.refreshCompleted();
  // }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Expanded(
        child: ResponsiveBuilder(
          mobile: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTabBar(context),
              _buildTabBarView(),
            ],
          ),
          tablet: Row(
            children: [
              Expanded(
                flex: (context.dw > 1100) ? 3 : 4,
                child: Column(
                  children: [
                    widget.headerMenu!,
                    const SizedBox(height: 24),
                    widget.profileHeader!,
                    _buildTabBar(context),
                  ],
                ),
              ),
              const VerticalDivider(indent: 32, endIndent: 32),
              _buildTabBarView(),
            ],
          ),
        ),
      ),
    );
  }

  Expanded _buildTabBarView() {
    return Expanded(
      flex: (context.isMobile) ? 1 : 6,
      child: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Consumer<FriendsProvider>(
            builder: (context, value, _) {
              return (value.listFriendFeeds.isNotEmpty)
                  ? SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.all(context.pd / 2),
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          spacing: 12,
                          runSpacing: 12,
                          children: <Widget>[
                            for (int i = 0;
                                i < value.listFriendFeeds.length;
                                i++)
                              SizedBox(
                                width: ((context.dw - context.dp(132)) / 2) -
                                    context.pd,
                                height: ((context.dw - context.dp(132)) / 2) -
                                    context.pd,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12)),
                                  child: CustomImageNetwork.rounded(
                                    value.listFriendFeeds[i].image!,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: SizedBox(
                        height: context.dh,
                        child: BasicEmpty(
                          shrink: context.isMobile,
                          isLandscape: !context.isMobile,
                          imageUrl: 'ilustrasi_sosial_feed_not_found.png'
                              .illustration,
                          title: 'Feeds',
                          subTitle: "Belum ada postingan",
                          emptyMessage:
                              "${widget.friendWidget!.namaLengkap} belum memposting progress tryout dan rangking yang diraihnya",
                        ),
                      ),
                    );
            },
          ),
          Consumer<FriendsProvider>(
            builder: (context, friends, _) => (friends
                    .currentListFriendsOfFriends.isNotEmpty)
                ? Padding(
                    padding: EdgeInsets.all(context.pd / 2),
                    child: ListView.builder(
                        shrinkWrap: true,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: friends.currentListFriendsOfFriends.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 10, right: 10),
                                    child: CircleAvatar(
                                      radius: context.dp(12),
                                      backgroundColor: context.secondaryColor,
                                      child: ProfilePictureWidget.circle(
                                        name: friends
                                            .currentListFriendsOfFriends[index]
                                            .fullName,
                                        noRegistrasi: friends
                                            .currentListFriendsOfFriends[index]
                                            .friendId,
                                        // userType: friends
                                        //     .currentListFriendsOfFriends[index]
                                        //     .role,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    friends
                                                        .currentListFriendsOfFriends[
                                                            index]
                                                        .fullName,
                                                    style: context
                                                        .text.bodySmall
                                                        ?.copyWith(
                                                            color: Colors.black,
                                                            fontSize: 14),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    "Kelas ${friends.currentListFriendsOfFriends[index].className}",
                                                    style: context
                                                        .text.bodySmall
                                                        ?.copyWith(
                                                            fontSize: 12,
                                                            color: Colors.grey),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Icon(
                                                        Icons.star,
                                                        size: 16,
                                                        color: context
                                                            .secondaryColor,
                                                      ),
                                                      const SizedBox(
                                                        width: 3,
                                                      ),
                                                      Text(
                                                        friends
                                                            .currentListFriendsOfFriends[
                                                                index]
                                                            .score,
                                                        style: context
                                                            .text.labelMedium
                                                            ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                height: 0,
                              )
                            ],
                          );
                        }),
                  )
                : SingleChildScrollView(
                    child: SizedBox(
                      height: context.dh,
                      child: BasicEmpty(
                        shrink: context.isMobile,
                        isLandscape: !context.isMobile,
                        imageUrl: 'ilustrasi_sosial_friends_not_found.png'
                            .illustration,
                        title: 'Friends',
                        subTitle: "Belum ada teman",
                        emptyMessage:
                            "${widget.friendWidget!.namaLengkap} belum memiliki teman, ayo berteman dengannya Sobat!",
                      ),
                    ),
                  ),
          )
        ],
      ),
    );
  }

  Container _buildTabBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: min(24, context.dp(16)),
        right: min(24, context.dp(20)),
        left: min(24, context.dp(20)),
        bottom: min(14, context.dp(10)),
      ),
      decoration: BoxDecoration(
          color: context.background,
          borderRadius: BorderRadius.circular(300),
          boxShadow: const [
            BoxShadow(
                offset: Offset(0, 2), blurRadius: 4, color: Colors.black26)
          ]),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: context.onBackground,
        indicatorColor: context.secondaryColor,
        labelStyle: context.text.bodyMedium,
        unselectedLabelStyle: context.text.bodyMedium,
        unselectedLabelColor: context.hintColor,
        splashBorderRadius: BorderRadius.circular(300),
        indicator: BoxDecoration(
            color: context.secondaryColor,
            borderRadius: BorderRadius.circular(300)),
        indicatorPadding: EdgeInsets.zero,
        labelPadding: (context.isMobile)
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(vertical: 8),
        tabs: const [Tab(text: 'Feeds'), Tab(text: 'Friends')],
      ),
    );
  }
}
