import 'package:equatable/equatable.dart';

class Log extends Equatable {
  final String userId;
  final String userType;
  final String menu;
  final String info;
  final String accessType;
  final String lastUpdate;

  const Log({
    required this.userId,
    required this.userType,
    required this.menu,
    required this.info,
    required this.accessType,
    required this.lastUpdate,
  });

  @override
  List<Object> get props =>
      [userId, userType, menu, info, accessType, lastUpdate];
}
