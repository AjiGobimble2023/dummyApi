import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/friends_provider.dart';
import '../../../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/constant.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../../../core/shared/widget/loading/loading_widget.dart';
import '../../../../../../core/shared/widget/image/profile_picture_widget.dart';

class FriendsWidget extends StatefulWidget {
  const FriendsWidget({super.key});

  @override
  State<FriendsWidget> createState() => _FriendsWidgetState();
}

class _FriendsWidgetState extends State<FriendsWidget> {
  final textCariTeman = TextEditingController();
  late FocusNode focusNode;
  late final AuthOtpProvider _authProvider = context.read<AuthOtpProvider>();
  late final FriendsProvider _friendProvider = context.read<FriendsProvider>();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _friendScrollController = ScrollController();
  final friendsProvider = FriendsProvider();
  String? _userId, _classLevelId;
  bool startAnimation = false;
  bool isLoading = false;
  bool loadMore = true;
  @override
  void initState() {
    _userId = _authProvider.userData!.noRegistrasi;
    _classLevelId = _authProvider.userData!.idSekolahKelas;
    Future.delayed(gDelayedNavigation, () async {
      context.read<FriendsProvider>().loadFriend(
            _userId!,
          );
    });
    _scrollController.addListener(() {
      if (_scrollController.offset >
          _scrollController.position.maxScrollExtent + 50) {
        _onLoadmoreSearchFriend(_userId!, textCariTeman.text);
      }
    });

    // tidak berfungsi di android
    /*
    _friendScrollController.addListener(() {
      if (_friendScrollController.offset >
          _friendScrollController.position.maxScrollExtent + 50) {
        _onLoadmoreFriend(_userId!);
      }
    });
    */
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    _scrollController.dispose();
    _friendScrollController.dispose();
    focusNode.dispose();
    textCariTeman.dispose();
    super.dispose();
  }

  Future<void> _onLoadmoreSearchFriend(
      String userId, String searchFriends) async {
    try {
      if (searchFriends.isNotEmpty) {
        await context
            .read<FriendsProvider>()
            .loadmoreSearchFriend(searchFriends: searchFriends, userId: userId);
        setState(() {
          loadMore = true;
        });
      } else {
        gShowTopFlash(context, "Inputkan nama terlebih dahulu Sobat");
        setState(() {
          loadMore = false;
        });
      }
    } catch (e) {
      setState(() {
        loadMore = false;
      });
      gShowTopFlash(context, "Seluruh data sudah dimuat Sobat");
    }
  }
  //Belum digunakan
  // Future<void> _onLoadmoreFriend(String userId) async {
  //   try {
  //     await context.read<FriendsProvider>().loadmoreFriend(userId);
  //   } catch (e) {
  //     if (kDebugMode) {
  //       logger.log("Seluruh data sudah diload");
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<FriendsProvider>(
      builder: (context, friends, _) => Stack(
        children: [
          GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Column(
              children: [
                // Searchbar Widget
                Padding(
                  padding: EdgeInsets.all(context.pd),
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.background,
                      borderRadius: BorderRadius.circular(300),
                    ),
                    child: TextField(
                      focusNode: focusNode,
                      controller: textCariTeman,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        border: OutlineInputBorder(
                            gapPadding: 0,
                            borderRadius: BorderRadius.circular(300),
                            borderSide: const BorderSide(
                                width: 0, color: Colors.transparent)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(300),
                            borderSide: const BorderSide(
                                width: 0, color: Colors.transparent)),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Icon(
                            Icons.search,
                            color: context.hintColor,
                            size: 24,
                          ),
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(
                              right: 10, top: 10, bottom: 10),
                          child: InkWell(
                            onTap: () async {
                              setState(() {
                                isLoading = true;
                              });
                              await context.read<FriendsProvider>().loadMyScore(
                                    noregistrasi: _userId,
                                    classLevelId: _classLevelId,
                                  );
                              // ignore: use_build_context_synchronously
                              Navigator.pushNamed(
                                context,
                                Constant.kRouteFriendsProfile,
                                arguments: {
                                  "nama": _authProvider.userData!.namaLengkap,
                                  "noregistrasi":
                                      _authProvider.userData!.noRegistrasi,
                                  "role": _authProvider.userType,
                                  "kelas":
                                      _authProvider.userData!.namaKelasGO.first,
                                  "score": _friendProvider.myScore,
                                },
                              );
                              setState(() {
                                isLoading = false;
                              });
                            },
                            child: CircleAvatar(
                              radius: (context.isMobile)
                                  ? context.dp(18)
                                  : context.dp(8),
                              backgroundColor: context.secondaryColor,
                              child: ProfilePictureWidget.circle(
                                name: _authProvider.userData!.namaLengkap,
                                noRegistrasi:
                                    _authProvider.userData!.noRegistrasi,
                                // userType: _authProvider.userType,
                                isUserLogin: _authProvider.userData != null,
                              ),
                            ),
                          ),
                        ),
                        hintText: "Cari teman",
                      ),
                      onSubmitted: (value) async {
                        Future.delayed(gDelayedNavigation, () {
                          setState(() {
                            startAnimation = true;
                            loadMore = true;
                          });
                        });
                        if (textCariTeman.text.isNotEmpty) {
                          await context.read<FriendsProvider>().searchFriend(
                              searchFriends: textCariTeman.text,
                              userId: _userId!);
                        } else {
                          gShowTopFlash(
                              context, "Sobat belum menginputkan nama");
                        }
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: hasilPencarian(),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading) const LoadingWidget()
        ],
      ),
    );
  }

  Widget hasilPencarian() {
    return Consumer<FriendsProvider>(
      builder: (context, friends, _) => (friends.isLoadingSearch)
          ? SizedBox(
              height: context.dh * 0.5,
              child: const LoadingWidget(),
            )
          : Container(
              padding: EdgeInsets.symmetric(horizontal: context.pd),
              child: (friends.listFriendsSearch.isNotEmpty)
                  ? Column(mainAxisSize: MainAxisSize.max, children: [
                      ListView.builder(
                          shrinkWrap: true,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          itemCount: friends.listFriendsSearch.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                Visibility(
                                  visible: index == 0,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Hasil Pencarian",
                                          style: context.text.bodySmall
                                              ?.copyWith(
                                                  color: context.background,
                                                  fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                            "${friends.listFriendsSearch.length} hasil",
                                            style: context.text.bodySmall
                                                ?.copyWith(
                                                    color: context.background))
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    await context
                                        .read<FriendsProvider>()
                                        .loadMyScore(
                                          noregistrasi: friends
                                              .listFriendsSearch[index]
                                              .friendId,
                                          classLevelId: friends
                                              .listFriendsSearch[index]
                                              .classLevelId,
                                        );
                                    // ignore: use_build_context_synchronously
                                    Navigator.pushNamed(
                                      context,
                                      Constant.kRouteFriendsProfile,
                                      arguments: {
                                        "nama": friends
                                            .listFriendsSearch[index].fullName,
                                        "noregistrasi": friends
                                            .listFriendsSearch[index].friendId,
                                        "role": friends
                                            .listFriendsSearch[index].role,
                                        "kelas": friends
                                            .listFriendsSearch[index].className,
                                        "status": friends
                                            .listFriendsSearch[index].status,
                                        "score": _friendProvider.myScore,
                                      },
                                    );
                                    setState(() {
                                      isLoading = false;
                                    });
                                  },
                                  child:
                                      itemFriendSearch(context, friends, index),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Visibility(
                                    visible: (index + 1 ==
                                            friends.listFriendsSearch.length &&
                                        loadMore),
                                    child: SizedBox(
                                      height: 300,
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: TextButton(
                                          onPressed: () async {
                                            setState(() {
                                              isLoading = true;
                                            });
                                            await _onLoadmoreSearchFriend(
                                                _userId!, textCariTeman.text);
                                            setState(() {
                                              isLoading = false;
                                            });
                                          },
                                          child: Container(
                                              padding:
                                                  EdgeInsets.all(context.pd),
                                              decoration: BoxDecoration(
                                                color: context.background,
                                                borderRadius:
                                                    BorderRadius.circular(300),
                                                boxShadow:
                                                    kElevationToShadow[2],
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.add_circle_outline,
                                                    color: context.primaryColor,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  const Text("Load more"),
                                                ],
                                              )),
                                        ),
                                      ),
                                    )),
                              ],
                            );
                          }),
                    ])
                  : BasicEmpty(
                      shrink: true,
                      imageUrl: 'ilustrasi_sosial_friends.png'.illustration,
                      title: 'Friends',
                      subTitle: 'Perluas Pergaulanmu Sobat!',
                      emptyMessage:
                          "SobatGO bisa menambahkan teman sesama SobatGO lain se-Indonesia, jadikan mereka circle yang memberikan kamu positive vibes dalam belajar ya!",
                    ),
            ),
    );
  }

  Container itemFriendSearch(
    BuildContext context,
    FriendsProvider friends,
    int index,
  ) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
          boxShadow: kElevationToShadow[2],
          borderRadius: BorderRadius.circular(12),
          color: context.background),
      child: Row(children: [
        Container(
          margin: const EdgeInsets.all(10),
          child: CircleAvatar(
            backgroundColor: context.secondaryColor,
            child: ProfilePictureWidget.circle(
              name: friends.listFriendsSearch[index].fullName,
              noRegistrasi: friends.listFriendsSearch[index].friendId,
              // userType: friends.listFriendsSearch[index].role,
              isUserLogin: _authProvider.userData != null,
            ),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: RichText(
                  text: TextSpan(
                    text: friends.listFriendsSearch[index].fullName,
                    style: context.text.bodySmall
                        ?.copyWith(color: Colors.black, fontSize: 14),
                    children: <TextSpan>[
                      TextSpan(
                        text:
                            " (Kelas ${friends.listFriendsSearch[index].className})",
                        style: context.text.bodySmall
                            ?.copyWith(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textScaleFactor: context.textScale12,
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(right: 10),
              //   child: Visibility(
              //     visible:
              //         friends.listFriendsSearch[index].status != "approved",
              //     child: (friends.listFriendsSearch[index].status !=
              //             "requested")
              //         ? InkWell(
              //             onTap: () async {
              //               await context.read<FriendsProvider>().requestFriend(
              //                   sourceId: _userId,
              //                   destId:
              //                       friends.listFriendsSearch[index].friendId);
              //               setState(() {});
              //               if (mounted) return;
              //               await context.read<FriendsProvider>().searchFriend(
              //                   searchFriends: textCariTeman.text,
              //                   userId: _userId!);

              //               if (mounted) return;
              //               gShowTopFlash(context,
              //                   "Permintaan pertemanan berhasil dikirimkan",
              //                   dialogType: DialogType.success);
              //             },
              //             child: const Icon(
              //               Icons.add_circle_outline,
              //               color: Colors.green,
              //             ),
              //           )
              //         : InkWell(
              //             onTap: () async {
              //               await context.read<FriendsProvider>().deleteFriends(
              //                   userId: gNoRegistrasi,
              //                   friendId:
              //                       friends.listFriendsSearch[index].friendId);
              //               setState(() {});

              //               gShowTopFlash(context,
              //                   "Permintaan pertemanan berhasil dibatalkan",
              //                   dialogType: DialogType.success);
              //             },
              //             child: Icon(
              //               Icons.cancel_outlined,
              //               color: context.primaryColor,
              //             ),
              //           ),
              //   ),
              // )
            ],
          ),
        )
      ]),
    );
  }
}
