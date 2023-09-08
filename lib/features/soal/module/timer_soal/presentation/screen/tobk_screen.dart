import 'package:flutter/material.dart';
import '../../../../../../core/config/extensions.dart';
import 'package:provider/provider.dart';

import '../widget/tob_list.dart';
import '../provider/tob_provider.dart';
import '../../../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../../../core/shared/screen/basic_screen.dart';

class TobkScreen extends StatelessWidget {
  final int idJenisProduk;
  final String namaJenisProduk;

  /// [selectedKodeTOB] merupakan kodeTOB yang didapat dari rencana belajar
  /// atau onClick Notification
  final String? selectedKodeTOB;

  /// [selectedKodeTOB] merupakan namaTOB yang didapat dari rencana belajar
  /// atau onClick Notification
  final String? selectedNamaTOB;

  /// Untuk keperluan handle push and pop
  final String? diBukaDari;

  const TobkScreen({
    Key? key,
    required this.idJenisProduk,
    required this.namaJenisProduk,
    this.selectedKodeTOB,
    this.selectedNamaTOB,
    this.diBukaDari,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasicScreen(
      title: 'TOBK',
      jumlahBarisTitle: 2,
      subTitle: 'Try Out Berbasis Komputer',
      actions: [
        IconButton(
          onPressed: () async {
            final authOtpProvider = context.read<AuthOtpProvider>();
            // Function load and refresh data
            await context.read<TOBProvider>().getDaftarTOB(
                  isRefresh: true,
                  noRegistrasi: authOtpProvider.userData?.noRegistrasi,
                  idSekolahKelas: authOtpProvider.userData?.idSekolahKelas ??
                      authOtpProvider.idSekolahKelas.value ??
                      '14',
                  idJenisProduk: idJenisProduk,
                  isProdukDibeli:
                      authOtpProvider.isProdukDibeliSiswa(idJenisProduk),
                  roleTeaser: authOtpProvider.teaserRole,
                );
          },
          icon: const Icon(Icons.refresh_rounded),
          style: IconButton.styleFrom(foregroundColor: context.onPrimary),
        ),
      ],
      body: TOBList(
        idJenisProduk: idJenisProduk,
        namaJenisProduk: namaJenisProduk,
        selectedKodeTOB: selectedKodeTOB,
        selectedNamaTOB: selectedNamaTOB,
        diBukaDari: diBukaDari,
      ),
    );
  }
}
