part of 'leaderboard_home_widget.dart';

class BelumMengerjakanSoalCard extends StatelessWidget {
  const BelumMengerjakanSoalCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        Constant.kRouteStoryBoardScreen,
        arguments: Constant.kStoryBoard['Nilaimu'],
      ),
      child: CustomCard(
        padding: EdgeInsets.symmetric(
          vertical: (context.isMobile) ? context.dp(10) : context.dp(5),
          horizontal: (context.isMobile) ? context.dp(12) : context.dp(6),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/icon/ic_report.webp',
              width: (context.isMobile) ? context.dp(32) : context.dp(22),
              fit: BoxFit.fitWidth,
            ),
            SizedBox(
              width: min(8, context.dp(8)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    child: Text('Progres latihan kamu akan tampil disini loh',
                        style: context.text.bodySmall
                            ?.copyWith(color: context.hintColor)),
                  ),
                  FittedBox(
                      child: Text('Ayo Mulai Berlatih Sobat',
                          style: context.text.titleSmall)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
