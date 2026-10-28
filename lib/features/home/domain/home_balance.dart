/// A demo wallet snapshot. Quantities come exclusively from public.b_balances.
/// KES valuations are estimates based on external spot prices.
class HomeBalance {
  const HomeBalance({
    required this.usdt,
    required this.btc,
    required this.totalKes,
    this.usdtValueKes = 0,
    this.btcValueKes = 0,
    this.hasValuation = true,
  });

  const HomeBalance.zero()
      : usdt = 0,
        btc = 0,
        totalKes = 0,
        usdtValueKes = 0,
        btcValueKes = 0,
        hasValuation = true;

  /// Retains the real holdings even if the price service is unavailable.
  const HomeBalance.unpriced({
    required this.usdt,
    required this.btc,
  })  : totalKes = 0,
        usdtValueKes = 0,
        btcValueKes = 0,
        hasValuation = false;

  final double usdt;
  final double btc;
  final double totalKes;
  final double usdtValueKes;
  final double btcValueKes;
  final bool hasValuation;

  factory HomeBalance.valued({
    required double usdt,
    required double btc,
    required double usdtKes,
    required double btcKes,
  }) {
    final tetherKes = usdt * usdtKes;
    final bitcoinKes = btc * btcKes;
    return HomeBalance(
      usdt: usdt,
      btc: btc,
      usdtValueKes: tetherKes,
      btcValueKes: bitcoinKes,
      totalKes: tetherKes + bitcoinKes,
    );
  }
}
