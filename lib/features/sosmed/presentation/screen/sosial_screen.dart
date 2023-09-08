import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../module/feed/presentation/screen/feed_screen.dart';
import '../../module/friends/presentation/widget/friends_widget.dart';
import '../../module/leaderboard/screen/leaderboard_friends_screen.dart';
import '../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/empty/basic_empty.dart';

class SosialScreen extends StatefulWidget {
  const SosialScreen({Key? key}) : super(key: key);

  @override
  State<SosialScreen> createState() => _SosialScreenState();
}

class _SosialScreenState extends State<SosialScreen> {
  late final AuthOtpProvider _authProvider = context.read<AuthOtpProvider>();
  String? noregistrasi, userType, namaLengkap;
  bool? isUserLogin;
  late Widget profile;

  @override
  void initState() {
    super.initState();
    noregistrasi = _authProvider.userData?.noRegistrasi;
    userType = _authProvider.userData?.siapa ?? _authProvider.userType;
    isUserLogin = _authProvider.userData != null;
    namaLengkap = _authProvider.userData?.namaLengkap;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TabBar(
              onTap: (int index) {
                setState(() {
                  FocusManager.instance.primaryFocus?.unfocus();
                });
              },
              // dividerColor: Colors.transparent,
              indicatorColor: context.onPrimary,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: EdgeInsets.zero,
              indicatorWeight: 2,
              labelColor: context.onPrimary,
              labelPadding: EdgeInsets.zero,
              labelStyle: context.text.titleMedium,
              padding: EdgeInsets.symmetric(horizontal: context.dp(24)),
              unselectedLabelStyle: context.text.titleMedium,
              unselectedLabelColor: context.onPrimary.withOpacity(0.54),
              tabs: const [
                Tab(text: 'Feed'),
                Tab(text: 'Leaderboard'),
                Tab(text: 'Friends')
              ],
            ),
            Expanded(
              child: (isUserLogin!)
                  ? TabBarView(
                      physics: const ClampingScrollPhysics(),
                      children: [
                        FeedScreen(
                            noRegistrasi: noregistrasi!,
                            namaLengkap: namaLengkap!,
                            userType: userType!),
                        const LeaderboardFriends(),
                        const FriendsWidget()
                      ],
                    )
                  : TabBarView(
                      physics: const ClampingScrollPhysics(),
                      children: [
                        _buildStoryBoard(
                          context,
                          'ilustrasi_sosial_feed.png'.illustration,
                          'Stay Connected',
                          'Sosial Flexing',
                          'Hi Sobat, fitur ini adalah tempat kamu dan teman-teman kamu bersosialisasi. '
                              'Kamu bisa pamerin Ranking kamu, dan kamu juga bisa pamerin hasil TryOut kamu loh Sobat.',
                        ),
                        _buildStoryBoard(
                          context,
                          'ilustrasi_sosial_leaderboard.png'.illustration,
                          'Leaderboard',
                          'Leaderboard Circle Kamu',
                          'Disini akan tampil peringkat kamu dan teman-teman kamu Sobat. '
                              'Kamu bisa tau siapa yang paling jago diantara kalian.',
                        ),
                        _buildStoryBoard(
                          context,
                          'ilustrasi_sosial_friends.png'.illustration,
                          'Sobat Friends',
                          'Perluas Pergaulanmu Sobat!',
                          'Disini kamu nantinya akan bisa mencari dan menambahkan teman sesama Sobat GO loohh. '
                              'Jadi kamu dan teman-teman kamu bisa saling memotivasi.',
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  SingleChildScrollView _buildStoryBoard(BuildContext context, String image,
      String title, String subtitle, String message) {
    return SingleChildScrollView(
      child: Container(
        constraints: context.isMobile
            ? BoxConstraints(
                minHeight: 450, maxHeight: context.dh - (context.dw / 2) - 20)
            : BoxConstraints(minHeight: 450, maxHeight: context.dh + 100),
        child: BasicEmpty(
          title: title,
          imageUrl: image,
          imageWidth: context.isMobile ? context.dp(220) : context.dp(100),
          subTitle: subtitle,
          emptyMessage: message,
        ),
      ),
    );
  }
}
