import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/friends_provider.dart';
import '../widget/profile_body_widget.dart';
import '../widget/friend_profile_widget.dart';
import '../widget/score_image_post_widget.dart';
import '../../../../../../core/config/enum.dart';
import '../../../../../../core/config/theme.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/screen/basic_screen.dart';
import '../../../../../../core/shared/builder/responsive_builder.dart';
import '../../../../../../core/shared/widget/loading/loading_widget.dart';
import '../../../../../../core/shared/widget/image/profile_picture_widget.dart';

class FriendsProfileScreen extends StatefulWidget {
  final String namaLengkap, noRegistrasi, userType, kelas, score;
  final String? status;
  const FriendsProfileScreen(
      {super.key,
      required this.kelas,
      required this.noRegistrasi,
      required this.namaLengkap,
      required this.userType,
      this.status,
      required this.score});

  @override
  State<FriendsProfileScreen> createState() => _FriendsProfileScreenState();
}

class _FriendsProfileScreenState extends State<FriendsProfileScreen> {
  /// [statusPertemanan] terdiri dari (approved, requested dan only approve)
  String? statusPertemanan;

  /// [isLoading] variable untuk kebutuhan change state loading
  bool isLoading = false;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      /// [getFriendFeeds] untuk mengambil data feed
      context
          .read<FriendsProvider>()
          .getFriendFeeds(noregistrasi: widget.noRegistrasi);

      /// [loadFriendOfFriends] untuk mengambil list data teman dari teman
      context.read<FriendsProvider>().loadFriendOfFriends(widget.noRegistrasi);

      /// Intialization value untuk status pertemanan
      statusPertemanan = widget.status;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
        mobile: Stack(
          children: [
            BasicScreen(
              logo: true,
              actions: const [
                Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: Icon(
                    Icons.menu,
                    size: 32,
                  ),
                ),
              ],
              title: widget.namaLengkap,
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        context.primaryColor,
                        context.secondaryColor,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.3, 1]),
                ),
                child: Column(
                  children: [
                    profileHeader(),
                    ProfileBodyWidget(widget: widget, context: context),
                  ],
                ),
              ),
            ),
            if (isLoading) const LoadingWidget(),
          ],
        ),
        tablet: Scaffold(
          body: SafeArea(
            child: ProfileFriendWidget(
              headerMenu: _buildHeaderMenu(),
              profileHeader: _buildProfileHeader(),
              friendWidget: widget,
            ),
          ),
        ));
  }

  Padding _buildHeaderMenu() => Padding(
        padding: EdgeInsets.only(
          top: min(24, context.dp(20)),
          bottom: min(16, context.dp(12)),
          right: min(24, context.dp(20)),
          left: min(24, context.dp(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(300),
                child: const Icon(Icons.chevron_left_rounded, size: 32)),
            Image.asset('assets/img/logo.webp',
                height: min(52, context.dp(48)), fit: BoxFit.fitHeight),
            InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(300),
                child: const Icon(Icons.menu_rounded, size: 32)),
          ],
        ),
      );
  Row _buildProfileHeader() => Row(
        children: [
          SizedBox(width: min(24, context.dp(20))),
          Container(
            alignment: Alignment.center,
            child: CircleAvatar(
              radius: (context.isMobile) ? context.dp(18) : context.dp(8),
              backgroundColor: context.secondaryColor,
              child: ProfilePictureWidget.circle(
                name: widget.namaLengkap,
                noRegistrasi: widget.noRegistrasi,
                // userType: widget.userType,
              ),
            ),
          ),
          SizedBox(width: min(14, context.dp(12))),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'Nama-Lengkap-User',
                  key: const Key('Nama-Lengkap-User'),
                  transitionOnUserGestures: true,
                  child: Text(widget.namaLengkap,
                      style: context.text.titleMedium
                          ?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      textScaleFactor: context.textScale12,
                      overflow: TextOverflow.ellipsis),
                ),
                Hero(
                  tag: 'No-Registrasi-User',
                  key: const Key('No-Registrasi-User'),
                  transitionOnUserGestures: true,
                  child: Text('${widget.noRegistrasi} (${widget.userType})',
                      style: context.text.bodyMedium
                          ?.copyWith(color: context.hintColor),
                      maxLines: 1,
                      textScaleFactor: context.textScale12,
                      overflow: TextOverflow.ellipsis),
                ),
                SizedBox(width: min(24, context.dp(20))),
              ],
            ),
          ),
        ],
      );

  Padding profileHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
      child: Consumer<FriendsProvider>(
        builder: (context, value, _) => SizedBox(
          width: context.dw,
          child: Column(
            children: [
              ScoreImagePostWidget(
                  widget: widget, context: context, value: value),
              SizedBox(
                width: context.dw,
                child: Text(
                  widget.namaLengkap,
                  textAlign: TextAlign.center,
                  style: context.text.titleMedium?.copyWith(
                      color: context.background, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                width: context.dw,
                child: Text(
                  (widget.kelas.isEmpty) ? "(Tamu)" : "Kelas (${widget.kelas})",
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.background,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              // Widget Button add Friends and Compare
              if (gNoRegistrasi != widget.noRegistrasi)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    (statusPertemanan == "approved")
                        ? InkWell(
                            onTap: () {
                              setState(() {
                                isLoading = true;
                              });
                              Future.delayed(
                                Duration.zero,
                                () async {
                                  gShowBottomDialog(
                                    context,
                                    message:
                                        "Berhenti berteman dengan ${widget.namaLengkap}?",
                                    actions: (controller) => [
                                      TextButton(
                                        onPressed: () async {
                                          controller.dismiss(true);
                                          Future.delayed(Duration.zero,
                                              () async {
                                            context
                                                .read<FriendsProvider>()
                                                .deleteFriends(
                                                    friendId:
                                                        widget.noRegistrasi,
                                                    userId: gNoRegistrasi);
                                            statusPertemanan = "declined";
                                          });
                                          gShowTopFlash(
                                            context,
                                            'Berhasil',
                                            dialogType: DialogType.success,
                                          );
                                          setState(() {});
                                        },
                                        child: const Text('Ya'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          controller.dismiss(true);
                                        },
                                        child: const Text('Tidak'),
                                      )
                                    ],
                                  );
                                },
                              );
                              setState(() {
                                isLoading = false;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6)),
                              height: context.dp(40),
                              width: (context.dw / 2) - 25,
                              child: Text(
                                "Added",
                                style: context.text.bodyLarge,
                              ),
                            ),
                          )
                        : (statusPertemanan == "requested")
                            ? InkWell(
                                onTap: () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await context
                                      .read<FriendsProvider>()
                                      .deleteFriends(
                                          userId: gNoRegistrasi,
                                          friendId: widget.noRegistrasi);
                                  setState(() {});
                                  statusPertemanan = "allow add";
                                  // ignore: use_build_context_synchronously
                                  gShowTopFlash(context,
                                      "Permintaan pertemanan berhasil dibatalkan",
                                      dialogType: DialogType.success);
                                  setState(() {
                                    isLoading = false;
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6)),
                                  height: context.dp(40),
                                  width: (context.dw / 2) - 25,
                                  child: Text(
                                    "Requested",
                                    style: context.text.bodyLarge,
                                  ),
                                ),
                              )
                            : (statusPertemanan == "only approve")
                                ? InkWell(
                                    onTap: () async {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      Future.delayed(Duration.zero, () async {
                                        await context
                                            .read<FriendsProvider>()
                                            .responseFriend(
                                                destId: gNoRegistrasi,
                                                sourceId: widget.noRegistrasi,
                                                status: "approved");
                                      });
                                      setState(() {});
                                      gShowTopFlash(context,
                                          "Selamat, Sobat dan ${widget.namaLengkap} sekarang sudah berteman",
                                          dialogType: DialogType.success);
                                      setState(() {
                                        isLoading = false;
                                      });
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: context.secondaryColor,
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                      height: context.dp(40),
                                      width: (context.dw / 2) - 25,
                                      child: Text(
                                        "Confirmation",
                                        style: context.text.bodyLarge,
                                      ),
                                    ),
                                  )
                                : InkWell(
                                    onTap: () {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      Future.delayed(
                                        Duration.zero,
                                        () async {
                                          await context
                                              .read<FriendsProvider>()
                                              .requestFriend(
                                                sourceId: gNoRegistrasi,
                                                destId: widget.noRegistrasi,
                                              );
                                          statusPertemanan = "requested";
                                          setState(() {});
                                          // ignore: use_build_context_synchronously
                                          gShowTopFlash(context,
                                              "Permintaan pertemanan berhasil dikirimkan",
                                              dialogType: DialogType.success);
                                        },
                                      );
                                      setState(() {
                                        isLoading = false;
                                      });
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: context.secondaryColor,
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                      height: context.dp(40),
                                      width: (context.dw / 2) - 25,
                                      child: Text(
                                        "Add",
                                        style: context.text.bodyLarge,
                                      ),
                                    ),
                                  ),
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Palette.kPrimarySwatch.shade300,
                          borderRadius: BorderRadius.circular(6)),
                      height: context.dp(40),
                      width: (context.dw / 2) - 25,
                      child: Text(
                        "Compare",
                        style: context.text.bodyMedium
                            ?.copyWith(color: context.background),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
