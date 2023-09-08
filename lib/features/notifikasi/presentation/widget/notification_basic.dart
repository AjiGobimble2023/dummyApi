import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/notifikasi_provider.dart';
import '../../../sosmed/module/friends/presentation/provider/friends_provider.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/image/profile_picture_widget.dart';

class NoificationBasic extends StatefulWidget {
  const NoificationBasic({
    super.key,
    required this.context,
    required this.value,
    required this.index,
    required this.type,
  });

  final BuildContext context;
  final NotificationProvider value;
  final int index;
  final String type;

  @override
  State<NoificationBasic> createState() => _NoificationBasicState();
}

class _NoificationBasicState extends State<NoificationBasic> {
  late final FriendsProvider _friendProvider = context.read<FriendsProvider>();
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (widget.type == "accept") {
          await context.read<FriendsProvider>().loadMyScore(
                noregistrasi:
                    widget.value.currentListNotification[widget.index].sourceId,
                classLevelId: widget
                    .value.currentListNotification[widget.index].classLevelId,
              );
          // ignore: use_build_context_synchronously
          Navigator.pushNamed(
            context,
            Constant.kRouteFriendsProfile,
            arguments: {
              "nama": widget
                  .value.currentListNotification[widget.index].sourceName
                  .toUpperCase(),
              "noregistrasi":
                  widget.value.currentListNotification[widget.index].sourceId,
              "role": widget.value.currentListNotification[widget.index].role,
              "kelas":
                  widget.value.currentListNotification[widget.index].className,
              "status": "approved",
              "score": _friendProvider.myScore,
            },
          );
        } else if (widget.type == "comment") {
          Navigator.pushNamed(
            context,
            Constant.kRouteFeedComment,
            arguments: {
              "feed": widget.value.currentListNotificationInfo[widget.index],
              'noRegistrasi':
                  widget.value.currentListNotification[widget.index].sourceId,
              'namaLengkap':
                  widget.value.currentListNotification[widget.index].sourceName,
              'userType':
                  widget.value.currentListNotification[widget.index].role
            },
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(
            left: context.pd, right: context.pd, bottom: context.pd / 2),
        decoration: BoxDecoration(
          color: context.background,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.only(
            top: context.dp(10),
            left: context.dp(10),
            right: context.dp(10),
            bottom: context.dp(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(right: context.dp(12)),
                decoration: BoxDecoration(
                  color: context.secondaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        offset: const Offset(-1, -1),
                        color: context.secondaryColor.withOpacity(0.42)),
                    BoxShadow(
                        offset: const Offset(1, 1),
                        color: context.secondaryColor.withOpacity(0.42))
                  ],
                ),
                child: CircleAvatar(
                  key: Key(
                      "${widget.value.currentListNotification[widget.index].sourceName}-${widget.value.currentListNotification[widget.index].sourceId}"),
                  radius: context.dp(18),
                  backgroundColor: context.secondaryColor,
                  child: ProfilePictureWidget.circle(
                    name: widget
                        .value.currentListNotification[widget.index].sourceName
                        .toUpperCase(),
                    width: context.dw,
                    noRegistrasi: widget
                        .value.currentListNotification[widget.index].sourceId,
                    // userType:
                    //     widget.value.currentListNotification[widget.index].role,
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                    width: context.dw * 0.6,
                    child: Column(
                      children: [
                        RichText(
                          textScaleFactor: context.textScale12,
                          text: TextSpan(children: [
                            TextSpan(
                              text:
                                  "${widget.value.currentListNotification[widget.index].sourceName}\t",
                              style: context.text.titleSmall,
                            ),
                            TextSpan(
                              text: (widget.type == 'comment')
                                  ? "mengomentari postingan feed Sobat"
                                  : "dan Sobat sekarang sudah berteman",
                              style: context.text.bodySmall,
                            ),
                          ]),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Text(
                              DateFormat.yMMMMd('ID').format(
                                DateTime.parse(
                                  widget
                                      .value
                                      .currentListNotification[widget.index]
                                      .date,
                                ),
                              ),
                              style: context.text.bodySmall
                                  ?.copyWith(color: context.hintColor),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Visibility(
                              visible: !widget.value
                                  .currentListNotification[widget.index].isSeen,
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: context.primaryColor),
                                width: 5,
                                height: 5,
                              ),
                            ),
                          ],
                        )
                      ],
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: context.hintColor,
                  size: 18,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
