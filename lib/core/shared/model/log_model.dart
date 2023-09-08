import '../entity/log.dart';

class LogModel extends Log {
  const LogModel({
    required String userId,
    required String userType,
    required String menu,
    required String info,
    required String accessType,
    required String lastUpdate,
  }) : super(
          userId: userId,
          userType: userType,
          menu: menu,
          info: info,
          accessType: accessType,
          lastUpdate: lastUpdate,
        );

  Map<String, dynamic> toDBMap() => {
        'nis': userId,
        'jenis': userType,
        'menu': menu,
        'keterangan': info,
        'akses': accessType,
        'lastupdate': lastUpdate,
      };
}
