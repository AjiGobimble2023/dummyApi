import 'package:flutter/material.dart';

import '../../entity/bookmark.dart';
import '../../../../core/config/enum.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/extensions.dart';

class BookmarkSoalItem extends StatelessWidget {
  final String namaKelompokUjian;
  final BookmarkSoal bookmarkSoal;
  final VoidCallback? onPress;
  final VoidCallback? onRemove;

  const BookmarkSoalItem(
      {Key? key,
      required this.bookmarkSoal,
      this.onPress,
      this.onRemove,
      required this.namaKelompokUjian})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key ??
          Key('${bookmarkSoal.kodePaket}.${bookmarkSoal.idBundel}.${bookmarkSoal.idSoal}'),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) =>
          (direction == DismissDirection.endToStart && onRemove != null)
              ? onRemove!()
              : null,
      confirmDismiss: (direction) => (direction == DismissDirection.endToStart)
          ? gShowBottomDialog(context,
              title: 'Konfirmasi hapus bookmark soal',
              message:
                  'Sobat yakin ingin menghapus soal ${bookmarkSoal.namaJenisProduk.replaceAll('e-', '')} no.${bookmarkSoal.nomorSoalSiswa} dari $namaKelompokUjian?',
              dialogType: DialogType.warning)
          : Future<bool>.value(false),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.all(context.dp(8)),
        color: context.primaryContainer,
        child: Icon(Icons.delete_rounded, color: context.onPrimaryContainer),
      ),
      child: ListTile(
        onTap: onPress,
        isThreeLine: true,
        leading: Icon(
          Icons.book,
          color: context.primaryColor,
        ),
        title: Text(bookmarkSoal.namaJenisProduk.replaceAll('e-', '')),
        subtitle: RichText(
          text: TextSpan(
            text: 'Nomor Soal : ${bookmarkSoal.nomorSoalSiswa}\n',
            style: context.text.bodyMedium,
            children: [
              TextSpan(
                  text: (bookmarkSoal.namaBab != null)
                      ? 'Bab : ${bookmarkSoal.namaBab}\n'
                      : 'Paket : ${bookmarkSoal.kodePaket}\n'),
              TextSpan(text: 'Last Update : ${bookmarkSoal.lastUpdate}')
            ],
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          textScaleFactor: context.textScale12,
        ),
      ),
    );
  }
}
