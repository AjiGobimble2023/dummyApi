part of 'leaderboard_home_widget.dart';

class GrafikHasilLatihanCard extends StatefulWidget {
  const GrafikHasilLatihanCard({Key? key}) : super(key: key);

  @override
  State<GrafikHasilLatihanCard> createState() => _GrafikHasilLatihanCardState();
}

class _GrafikHasilLatihanCardState extends State<GrafikHasilLatihanCard> {
  static const List<String> _filterNilai = [
    'Hari ini',
    'Minggu ini',
    'Bulan ini'
  ];

  late String? _selectedFilter = _filterNilai[0];
  late final _capaianProvider = context.read<CapaianProvider>();
  late final _authProvider = context.read<AuthOtpProvider>();

  Future<List<PengerjaanSoal>> _onRefresh({bool isRefresh = false}) async {
    return await _capaianProvider.getHasilPengerjaanSoal(
      refresh: isRefresh,
      isTamu: !_authProvider.isLogin || _authProvider.isTamu,
      noRegistrasi: _authProvider.userData!.noRegistrasi,
      idSekolahKelas: _authProvider.userData!.idSekolahKelas,
      tahunAjaran: _authProvider.tahunAjaran,
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Gunakan consumer untuk mengetahui apakah user login atau tidak.
    // TODO: Gunakan consumer pada chart grafik untuk mendapatkan data hasil latihan soal User yang login.
    return Selector<CapaianProvider, List<PengerjaanSoal>>(
      selector: (_, capaian) => capaian.hasilPengerjaanSoal,
      builder: (context, hasilPengerjaan, loadingWidget) {
        return FutureBuilder<List<PengerjaanSoal>>(
          future: _onRefresh(),
          builder: (context, snapshot) {
            bool isLoading =
                snapshot.connectionState == ConnectionState.waiting ||
                    context.select<CapaianProvider, bool>(
                        (capaian) => capaian.isPengerjaanSoalLoading);
            String? errorMessage = context.select<CapaianProvider, String?>(
                    (capaian) => capaian.errorGrafikNilai) ??
                snapshot.error?.toString();

            if (isLoading) {
              return loadingWidget!;
            }

            if (errorMessage != null) {
              return _buildRefreshWidget(errorMessage);
            }

            List<PengerjaanSoal> hasilPengerjaanSoal =
                (snapshot.data?.isEmpty ?? true)
                    ? hasilPengerjaan
                    : snapshot.data!;

            if (hasilPengerjaanSoal.isEmpty) {
              return const BelumMengerjakanSoalCard();
            }

            return Container(
              width: context.dw - context.dp(48),
              padding: EdgeInsets.all(min(20, context.dp(12))),
              margin: EdgeInsets.only(top: min(10, context.dp(6))),
              decoration: BoxDecoration(
                color: context.background,
                borderRadius: BorderRadius.circular(
                  (context.isMobile) ? max(12, context.dp(12)) : context.dp(10),
                ),
              ),
              child: _buildGrafikWidget(context),
            );
          },
        );
      },
      child: ShimmerWidget(
        width: context.dw - context.dp(48),
        height: (context.isMobile) ? context.dp(180) : context.dp(120),
        borderRadius: BorderRadius.circular(
          (context.isMobile) ? max(12, context.dp(12)) : context.dp(10),
        ),
      ),
    );
  }

  Widget _buildRefreshWidget(String message) {
    return AspectRatio(
      aspectRatio: 3,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: context.background.withOpacity(0.34),
          borderRadius: BorderRadius.circular(
            (context.isMobile) ? max(12, context.dp(12)) : context.dp(10),
          ),
        ),
        child: RefreshExceptionWidget(
          message: message,
          onTap: () => _onRefresh(isRefresh: true),
        ),
      ),
    );
  }

  /// Jika user login dan sudah mengerjakan buku sakti, maka tampilkan grafik
  Column _buildGrafikWidget(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: min(148, context.dp(103)),
              child: DropdownButtonFormField<String>(
                value: _selectedFilter,
                borderRadius: BorderRadius.circular(max(8, context.dp(8))),
                items: _filterNilai
                    .map<DropdownMenuItem<String>>(
                        (filter) => DropdownMenuItem<String>(
                              value: filter,
                              child: Text(filter),
                              onTap: () {},
                            ))
                    .toList(),
                onChanged: (selectedFilter) {
                  switch (selectedFilter) {
                    case 'Minggu ini':
                      context.read<CapaianProvider>().filterNilai =
                          FilterNilai.mingguan;
                      break;
                    case 'Bulan ini':
                      context.read<CapaianProvider>().filterNilai =
                          FilterNilai.bulanan;
                      break;
                    default:
                      context.read<CapaianProvider>().filterNilai =
                          FilterNilai.harian;
                      break;
                  }
                  setState(() => _selectedFilter = selectedFilter!);
                },
                isDense: true,
                alignment: Alignment.center,
                iconSize: min(24, context.dp(20)),
                icon: const Icon(Icons.expand_more_rounded),
                style: context.text.bodySmall
                    ?.copyWith(color: context.onBackground),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    gapPadding: 0,
                    borderRadius: BorderRadius.circular(max(6, context.dp(6))),
                    borderSide: BorderSide(color: context.onBackground),
                  ),
                  focusedBorder: OutlineInputBorder(
                    gapPadding: 0,
                    borderRadius: BorderRadius.circular(max(6, context.dp(6))),
                    borderSide: BorderSide(color: context.onBackground),
                  ),
                  enabledBorder: OutlineInputBorder(
                    gapPadding: 0,
                    borderRadius: BorderRadius.circular(max(6, context.dp(6))),
                    borderSide: BorderSide(color: context.onBackground),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: (context.isMobile) ? 4 : 10,
                    horizontal: (context.isMobile) ? 6 : 12,
                  ),
                  isDense: true,
                ),
              ),
            ),
            SizedBox(width: min(14, context.dp(6))),
            Expanded(
              child: (context.isMobile || context.dw < 1100)
                  ? FittedBox(
                      child: Text(
                        'Sobat, Gimana hasil latihan kamu?',
                        style: context.text.bodySmall
                            ?.copyWith(color: context.hintColor),
                      ),
                    )
                  : Text(
                      'Sobat, Gimana hasil latihan kamu?',
                      style: context.text.bodySmall
                          ?.copyWith(color: context.hintColor),
                    ),
            ),
          ],
        ),
        SizedBox(height: min(20, context.dp(12))),
        const GrafikBarChart(),
      ],
    );
  }
}
