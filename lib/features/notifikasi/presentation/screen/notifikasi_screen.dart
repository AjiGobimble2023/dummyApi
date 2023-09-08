import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../widget/notification_basic.dart';
import '../provider/notifikasi_provider.dart';
import '../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../sosmed/module/friends/presentation/provider/friends_provider.dart';
import '../../../../core/config/enum.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/screen/basic_screen.dart';
import '../../../../core/shared/widget/empty/no_data_found.dart';
import '../../../../core/shared/widget/loading/loading_widget.dart';
import '../../../../core/shared/widget/image/profile_picture_widget.dart';
import '../../../../core/shared/widget/refresher/custom_smart_refresher.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({Key? key}) : super(key: key);

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  /// [_refreshController] merupakan variable untuk controller refresh item notifikasi
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  /// [authProvider] merupakan variabel provider untuk memanggil data login user
  late final AuthOtpProvider authProvider = context.read<AuthOtpProvider>();

  /// Kumpulan variable data user
  String? userId, userType;

  Future<void> _onRefresh({bool isRefresh = false}) async {
    await Future.delayed(Duration.zero, () async {
      context.read<NotificationProvider>().loadNotification(gNoRegistrasi);
    });
    _refreshController.refreshCompleted();
  }

  /// [deleteNotification] method untuk menghapus notifikasi yang diterima
  deleteNotification(
    String notifId,
  ) async {
    await context.read<NotificationProvider>().deleteNotifikasi(notifId);
    await _onRefresh();
  }

  @override
  void initState() {
    userId = authProvider.userData!.noRegistrasi;
    userType = authProvider.userData!.noRegistrasi;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BasicScreen(
      title: 'Notifikasi',
      body: Consumer<NotificationProvider>(
        builder: (context, value, _) {
          int lengthNotification = value.currentListNotification.length;
          for (int i = 0; i < value.currentListNotification.length; i++) {
            if (value.currentListNotification[i].sourceId == gNoRegistrasi) {
              --lengthNotification;
            }
          }
          return Stack(
            children: [
              (value.currentListNotification.isNotEmpty &&
                      lengthNotification > 0)
                  ? listItemNotification(context, value)
                  : CustomSmartRefresher(
                      isDark: true,
                      controller: _refreshController,
                      onRefresh: () => _onRefresh(isRefresh: true),
                      child: Visibility(
                        visible: !value.isLoading,
                        child: NoDataFoundWidget(
                          isLandscape: !context.isMobile,
                          imageUrl: 'ilustrasi_notifikasi.png'.illustration,
                          subTitle: 'Tidak Ada Notifikasi',
                          emptyMessage:
                              'Saat ini belum ada notifikasi untuk kamu Sobat. '
                              'Stay up to date dengan MinGO yaa!',
                        ),
                      ),
                    ),
              if (value.isLoading) const LoadingWidget(),
            ],
          );
        },
      ),
    );
  }

  /// [listItemNotification] merupakan widget untuk menampilkan seluruh list notifikasi yang di dapatkan oleh user
  CustomSmartRefresher listItemNotification(
      BuildContext context, NotificationProvider value) {
    return CustomSmartRefresher(
      isDark: true,
      controller: _refreshController,
      onRefresh: () => _onRefresh(isRefresh: true),
      child: ListView.builder(
        padding: EdgeInsets.only(top: context.pd),
        itemCount: value.currentListNotification.length,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: Key(
                "${value.currentListNotification[index].notifId}-${value.currentListNotification[index].notifType}"),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) =>
                (direction == DismissDirection.endToStart)
                    ? deleteNotification(
                        value.currentListNotification[index].notifId)
                    : null,
            confirmDismiss: (direction) => (direction ==
                    DismissDirection.endToStart)
                ? (value.currentListNotification[index].notifType ==
                        "friend request")
                    ? gShowBottomDialogInfo(context,
                        title: 'Konfirmasi Hapus Notifikasi',
                        message:
                            'Sobat harus melakukan konfirmasi atau mengabaikan permintaan pertemanan ini terlebih dahulu',
                        dialogType: DialogType.warning)
                    : gShowBottomDialog(context,
                        title: 'Konfirmasi Hapus Notifikasi',
                        message: 'Sobat yakin ingin menghapus notifikasi ini?',
                        dialogType: DialogType.warning)
                : Future<bool>.value(false),
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.all(context.dp(8)),
              color: context.primaryContainer,
              child:
                  Icon(Icons.delete_rounded, color: context.onPrimaryContainer),
            ),
            child: (value.currentListNotification[index].notifType ==
                    "friend request")
                ? buildFriendRequest(context, value, index)
                : (value.currentListNotification[index].notifType ==
                            "comment new" &&
                        value.currentListNotification[index].sourceId !=
                            gNoRegistrasi)
                    ? NoificationBasic(
                        context: context,
                        value: value,
                        index: index,
                        type: 'comment',
                      )
                    : (value.currentListNotification[index].notifType ==
                                "friend accept" &&
                            value.currentListNotification[index].sourceId !=
                                gNoRegistrasi)
                        ? NoificationBasic(
                            context: context,
                            value: value,
                            index: index,
                            type: 'accept',
                          )
                        : const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  /// [buildFriendRequest] merupakan widget untuk membangun item notifikasi
  /// dengan tipe notifikasi = permintaan pertemanan
  Container buildFriendRequest(
      BuildContext context, NotificationProvider value, int index) {
    return Container(
      margin: EdgeInsets.only(
          left: context.pd, right: context.pd, bottom: context.pd),
      decoration: BoxDecoration(
        color: context.background,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.only(
            top: context.dp(10),
            left: context.dp(10),
            right: context.dp(10),
            bottom: context.dp(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(right: context.dp(12)),
                  child: CircleAvatar(
                    radius: context.dp(18),
                    backgroundColor: context.secondaryColor,
                    child: ProfilePictureWidget.circle(
                      name: value.currentListNotification[index].sourceName,
                      width: context.dw,
                      noRegistrasi:
                          value.currentListNotification[index].sourceId,
                      // userType: value.currentListNotification[index].role,
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: context.dw * 0.6,
                    child: RichText(
                      textScaleFactor: context.textScale12,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                "${value.currentListNotification[index].sourceName}\t",
                            style: context.text.titleSmall,
                          ),
                          TextSpan(
                            text: "meminta untuk berteman dengan sobat\n",
                            style: context.text.bodySmall,
                          ),
                          TextSpan(
                            text: DateFormat.yMMMMd('ID').format(
                              DateTime.parse(
                                value.currentListNotification[index].date,
                              ),
                            ),
                            style: context.text.bodySmall
                                ?.copyWith(color: context.hintColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                buildButtonConfirmation(
                    context,
                    value.currentListNotification[index].sourceId,
                    value.currentListNotification[index].sourceName,
                    'Konfirmasi'),
                const SizedBox(
                  width: 10,
                ),
                buildButtonConfirmation(
                    context,
                    value.currentListNotification[index].sourceId,
                    value.currentListNotification[index].sourceName,
                    'Abaikan'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// [buildButtonConfirmation] merupakan widget untuk menampilkan button konfirmasi pertemanan
  InkWell buildButtonConfirmation(
      BuildContext context, String sourceId, String sourceName, String type) {
    return InkWell(
      onTap: () async {
        if (type == "Konfirmasi") {
          await context.read<FriendsProvider>().responseFriend(
              destId: gNoRegistrasi, sourceId: sourceId, status: "approved");
        } else {
          await context.read<FriendsProvider>().deleteFriends(
                friendId: sourceId,
                userId: gNoRegistrasi,
              );
        }
        await _onRefresh();
        if (!mounted) return;
        gShowTopFlash(
            context,
            (type == "Konfirmasi")
                ? "Selamat, Sobat dan $sourceName sekarang sudah berteman"
                : "Permitaan pertemanan $sourceName sudah diabaikan",
            dialogType: DialogType.success);
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: (type == 'Konfirmasi')
            ? BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(6),
              )
            : BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(6)),
        child: Text(
          type,
          style: context.text.bodySmall?.copyWith(
            color: (type == 'Konfirmasi') ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
