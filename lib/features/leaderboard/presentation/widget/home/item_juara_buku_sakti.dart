part of 'leaderboard_home_widget.dart';

class ItemJuaraBukuSakti extends StatelessWidget {
  final bool isLoading;
  final String noRegistrasi;
  final String name;
  final String score;
  final String juaraType;
  final String? photoUrl;

  const ItemJuaraBukuSakti({
    Key? key,
    required this.noRegistrasi,
    required this.name,
    required this.score,
    required this.juaraType,
    this.photoUrl,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double maxWidth = (context.dw - context.dp(72)) / 3;

    if (!context.isMobile) {
      maxWidth = (context.dw > 1100) ? context.dp(68) : context.dp(61);
    }

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: CustomCard(
            backgroundColor:
                (isLoading) ? context.primaryColor : context.background,
            padding: (isLoading)
                ? EdgeInsets.zero
                : EdgeInsets.only(
                    top: min(42, context.dp(20)),
                  ),
            margin: EdgeInsets.only(
                top: (context.isMobile) ? context.dp(16) : context.dp(10)),
            borderRadius: BorderRadius.circular(
              (context.isMobile) ? max(12, context.dp(12)) : context.dp(10),
            ),
            onTap: () {
              if (context.read<AuthOtpProvider>().isLogin &&
                  !context.read<AuthOtpProvider>().isTamu) {
                Navigator.pushNamed(
                    context, Constant.kRouteJuaraBukuSaktiScreen,
                    arguments: {'juaraType': juaraType});
              } else {
                Navigator.pushNamed(
                  context,
                  Constant.kRouteStoryBoardScreen,
                  arguments: Constant.kStoryBoard['Juara Buku Sakti'],
                );
              }
            },
            child: (isLoading)
                ? ShimmerWidget.rounded(
                    width: maxWidth,
                    height:
                        (context.isMobile) ? context.dp(126) : context.dp(82),
                    borderRadius: BorderRadius.circular(
                      (context.isMobile)
                          ? max(12, context.dp(12))
                          : context.dp(10),
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        ' $name ',
                        style: context.text.bodySmall
                            ?.copyWith(color: context.onBackground),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                      ),
                      FittedBox(
                        child: Text('($score)',
                            style: context.text.labelMedium
                                ?.copyWith(color: context.onBackground),
                            maxLines: 1),
                      ),
                      SizedBox(
                        height: (context.isMobile) ? max(6, context.dp(6)) : 8,
                      ),
                      LayoutBuilder(builder: (context, constraint) {
                        return ProfilePictureWidget.rounded(
                          key: ValueKey(
                              'PHOTO_PROFILE_ROUNDED-$noRegistrasi-$name'),
                          noRegistrasi: noRegistrasi,
                          // userType: 'SISWA',
                          name: name,
                          photoUrl: photoUrl,
                          // width: (context.dw - (24 * 3)) / 3,
                          width: constraint.maxWidth,
                          height: (context.isMobile)
                              ? context.dp(126)
                              : context.dp(82),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(
                              (context.isMobile)
                                  ? max(12, context.dp(12))
                                  : context.dp(10),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: (context.isMobile) ? context.dp(89) : context.dp(48),
            alignment: Alignment.center,
            padding: EdgeInsets.all(max(6, context.dp(6))),
            decoration: BoxDecoration(
              color: context.primaryColor,
              borderRadius: BorderRadius.circular(max(6, context.dp(6))),
              boxShadow: [
                BoxShadow(
                  color: context.disableColor,
                  offset: const Offset(1, 1),
                  blurRadius: 3,
                ),
              ],
            ),
            child: Text(
              juaraType,
              style:
                  context.text.bodyMedium?.copyWith(color: context.onPrimary),
            ),
          ),
        ),
      ],
    );
  }
}
