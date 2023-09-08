import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/appbar/custom_app_bar.dart';
import '../../../../core/shared/widget/refresher/custom_smart_refresher.dart';
import '../../../auth/model/user_model.dart';
import '../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../entity/berita.dart';
import '../provider/berita_provider.dart';
import '../widget/go_news/go_news_item.dart';

class GoNewsScreen extends StatefulWidget {
  const GoNewsScreen({Key? key}) : super(key: key);

  @override
  State<GoNewsScreen> createState() => _GoNewsScreenState();
}

class _GoNewsScreenState extends State<GoNewsScreen> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Future<void> _onRefresh(
    BuildContext context, {
    UserModel? userData,
    bool refresh = false,
  }) async {
    // monitor network fetch
    await context.read<BeritaProvider>().loadBerita(
          userType: userData?.siapa ?? 'UMUM',
          isRefresh: refresh,
        );
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  @override
  void reassemble() {
    _refreshController.dispose();
    super.reassemble();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.primaryColor,
      appBar: CustomAppBar(
        context,
        centerTitle: true,
        implyLeadingDark: false,
        title: Image.asset(
          'assets/img/txt_go_news.png',
          height: context.dp(32),
        ),
      ),
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
        child: Container(
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
          child: ValueListenableBuilder<UserModel?>(
            valueListenable: context.read<AuthOtpProvider>().userModel,
            builder: (context, userData, child) {
              return Selector<BeritaProvider, List<Berita>>(
                selector: (_, berita) => berita.allNews,
                builder: (context, allNews, child) {
                  return CustomSmartRefresher(
                    isDark: true,
                    controller: _refreshController,
                    onRefresh: () async => await _onRefresh(
                      context,
                      userData: userData,
                      refresh: true,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.only(
                        top: context.dp(8),
                        bottom: context.dp(18),
                      ),
                      itemCount: allNews.length,
                      itemBuilder: (_, index) =>
                          GoNewsItem(berita: allNews[index]),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
