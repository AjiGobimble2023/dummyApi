import 'package:flutter/material.dart';
import '../../../../../../core/config/constant.dart';
import '../../../../../../core/config/extensions.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../../../core/shared/widget/image/custom_image_network.dart';
import '../provider/friends_provider.dart';
import '../screen/friends_profile_screen.dart';

class FriendFeedWidget extends StatelessWidget {
  const FriendFeedWidget({
    Key? key,
    required this.widget,
  }) : super(key: key);

  final FriendsProfileScreen widget;

  @override
  Widget build(BuildContext context) {
    return Consumer<FriendsProvider>(
      builder: (context, value, _) {
        return (value.listFriendFeeds.isNotEmpty)
            ? SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.only(top: context.pd, left: 12, right: 12),
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 12,
                    runSpacing: 12,
                    children: <Widget>[
                      for (int i = 0; i < value.listFriendFeeds.length; i++)
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Constant.kRouteFeedComment,
                              arguments: {
                                "feed": value.listFriendFeeds[i],
                                'noRegistrasi': widget.noRegistrasi,
                                'namaLengkap': widget.namaLengkap,
                                'userType': widget.userType,
                              },
                            );
                          },
                          child: SizedBox(
                            width: (context.dw / 2) - 20,
                            height: (context.dw / 2) - 20,
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12)),
                              child: CustomImageNetwork.rounded(
                                value.listFriendFeeds[i].image!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                    // isLandscape: !context.isMobile,
                    imageUrl:
                        'ilustrasi_sosial_feed_not_found.png'.illustration,
                    title: 'Feeds',
                    subTitle: "Belum ada postingan",
                    emptyMessage:
                        "${widget.namaLengkap} belum memposting progress tryout dan rangking yang diraihnya",
                  ),
                ),
              );
      },
    );
  }
}
