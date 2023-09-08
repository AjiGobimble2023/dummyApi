part of '../buku_soal_menu.dart';

class BukuSaktiWidget extends StatefulWidget {
  final int? idJenisProduk;
  final String? kodeTOB;
  final String? kodePaket;
  final String? diBukaDari;

  const BukuSaktiWidget({
    Key? key,
    this.idJenisProduk,
    this.kodeTOB,
    this.kodePaket,
    this.diBukaDari,
  }) : super(key: key);

  @override
  State<BukuSaktiWidget> createState() => _BukuSaktiWidgetState();
}

class _BukuSaktiWidgetState extends State<BukuSaktiWidget>
    with SingleTickerProviderStateMixin {
  // Initial selected menu index
  late final _initialIndex = (widget.idJenisProduk == null)
      ? 0
      : MenuProvider.listMenuBukuSakti
          .indexWhere((menu) => menu.idJenis == widget.idJenisProduk);

  late final TabController _tabController =
      TabController(length: 3, initialIndex: _initialIndex, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!context.isMobile) SizedBox(height: context.dp(6)),
        TabBar(
          controller: _tabController,
          indicatorWeight: 2,
          labelColor: context.onBackground,
          indicatorColor: context.onBackground,
          labelStyle: context.text.bodyMedium,
          unselectedLabelStyle: context.text.bodyMedium,
          unselectedLabelColor: context.onBackground.withOpacity(0.54),
          padding: EdgeInsets.symmetric(horizontal: context.dp(24)),
          indicatorPadding: EdgeInsets.zero,
          labelPadding: EdgeInsets.zero,
          tabs: const [
            Tab(text: 'Latihan Extra'),
            Tab(text: 'Empati Mandiri'),
            Tab(text: 'Empati Wajib')
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const ClampingScrollPhysics(),
            children: [
              BundelSoalList(
                  idJenisProduk: MenuProvider.listMenuBukuSakti[0].idJenis,
                  namaJenisProduk:
                      MenuProvider.listMenuBukuSakti[0].namaJenisProduk),
              PaketSoalList(
                idJenisProduk: MenuProvider.listMenuBukuSakti[1].idJenis,
                namaJenisProduk:
                    MenuProvider.listMenuBukuSakti[1].namaJenisProduk,
                diBukaDari: widget.diBukaDari ?? Constant.kRouteBukuSoalScreen,
              ),
              PaketSoalList(
                idJenisProduk: MenuProvider.listMenuBukuSakti[2].idJenis,
                namaJenisProduk:
                    MenuProvider.listMenuBukuSakti[2].namaJenisProduk,
                kodeTOB: widget.kodeTOB,
                kodePaket: widget.kodePaket,
                diBukaDari: widget.diBukaDari ?? Constant.kRouteBukuSoalScreen,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
