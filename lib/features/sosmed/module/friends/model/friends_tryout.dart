class FriendsTryout {
  final String kodesoal;
  final String kodetob;

  FriendsTryout({required this.kodesoal, required this.kodetob});

  factory FriendsTryout.fromJson(Map<String, dynamic> json) {
    return FriendsTryout(
      kodesoal: json['kodesoal'],
      kodetob: json['kodetob'],
    );
  }
}
