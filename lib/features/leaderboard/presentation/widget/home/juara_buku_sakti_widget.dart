part of 'leaderboard_home_widget.dart';

class JuaraBukuSaktiWidget extends StatelessWidget {
  final bool isLogin;
  final bool isNotTamu;
  final UserModel? userData;
  final String? idSekolahKelas;
  final String tahunAjaran;

  const JuaraBukuSaktiWidget({
    Key? key,
    required this.isLogin,
    required this.isNotTamu,
    this.userData,
    this.idSekolahKelas,
    required this.tahunAjaran,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double padding = (context.isMobile) ? context.dp(12) : context.dp(8);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        // bottom: padding,
        left: padding,
        right: padding,
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            (context.isMobile) ? max(24, context.dp(24)) : context.dp(18),
          ),
          border: Border.all(
              color: context.secondaryColor.withOpacity(0.87), width: 2)),
      child: Transform.translate(
        offset: Offset(0, padding * -1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              // transform: vector.Matrix4.translation(vector.Vector3(0, padding * -1, 0)),
              margin: EdgeInsets.only(
                top: (!context.isMobile) ? context.dp(4) : 0,
                bottom: min(14, context.dp(6)),
              ),
              decoration: BoxDecoration(
                  color: context.secondaryColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8))),
              child: Text(
                'Leaderboard',
                style: context.text.labelSmall,
              ),
            ),
            CustomImageNetwork(
              'top_skor_header.png'.imgUrl,
              height: (context.isMobile) ? context.dp(54) : context.dp(32),
              width: double.infinity,
              fit: BoxFit.contain,
            ),
            _buildJuaraSatuBukuSakti(context),
            if (!isLogin || !isNotTamu) const BelumMengerjakanSoalCard(),
            // TODO: Jika User login, maka tampilkan capaian score dia (jika ada).
            if (isLogin && isNotTamu) const CapaianScoreCard(),
            if (isLogin && isNotTamu) const GrafikHasilLatihanCard(),
          ],
        ),
      ),
    );
  }

  Padding _buildJuaraSatuBukuSakti(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: (context.isMobile) ? context.dp(14) : context.dp(8),
      ),
      child: Selector<LeaderboardProvider, List<RankingSatuModel>>(
        selector: (_, leaderboardProvider) =>
            leaderboardProvider.listRankingSatu,
        builder: (_, listJuara, __) {
          return FutureBuilder<void>(
            future: context.read<LeaderboardProvider>().getFirstRankBukuSakti(
                  idSekolahKelas:
                      userData?.idSekolahKelas ?? idSekolahKelas ?? '14',
                  idKota: userData?.idKota ?? '1',
                  idGedung: userData?.idGedung ?? '2',
                  tahunAjaran: tahunAjaran,
                ),
            builder: (context, snapshot) {
              bool isLoading =
                  snapshot.connectionState == ConnectionState.waiting ||
                      context.select<LeaderboardProvider, bool>(
                          (leaderboard) => leaderboard.isLoadingFirstRank);

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: (listJuara.isEmpty || isLoading)
                    ? List<ItemJuaraBukuSakti>.generate(
                        3,
                        (index) => ItemJuaraBukuSakti(
                              isLoading: isLoading,
                              noRegistrasi: '-',
                              name: '......',
                              score: '...',
                              juaraType: index == 0
                                  ? 'Nasional'
                                  : index == 1
                                      ? 'Kota'
                                      : 'Gedung',
                            ))
                    : listJuara
                        .map<Widget>(
                          (list) => ItemJuaraBukuSakti(
                            noRegistrasi: list.noRegistrasi,
                            name: list.namaLengkap,
                            score: list.score,
                            photoUrl: list.photoUrl,
                            juaraType: list.tipe,
                          ),
                        )
                        .toList(),
              );
            },
          );
        },
      ),
    );
  }
}
