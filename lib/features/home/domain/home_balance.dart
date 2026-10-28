/// A demo wallet valuation: asset quantities multiplied by current KES prices.
class HomeBalance {
  final double usdt;
  final double btc;
  final double totalKes;

  const HomeBalance({
    required this.usdt,
    required this.btc,
    required this.totalKes,
  });

  factory HomeBalance.valued({
    required double usdt,
    required double btc,
    required double usdtKes,
    required double btcKes,
  }) {
    return HomeBalance(
      usdt: usdt,
      btc: btc,
      totalKes: (usdt * usdtKes) + (btc * btcKes),
    );
  }
}
