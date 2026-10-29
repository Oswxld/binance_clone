import 'wallet_display_currency.dart';

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
    this.indicativeRates = false,
    this.usdtKesRate = 0,
    this.btcKesRate = 0,
    this.ethKesRate = 0,
    this.bnbKesRate = 0,
  });

  const HomeBalance.zero()
      : usdt = 0,
        btc = 0,
        totalKes = 0,
        usdtValueKes = 0,
        btcValueKes = 0,
        hasValuation = true,
        indicativeRates = false,
        usdtKesRate = 0,
        btcKesRate = 0,
        ethKesRate = 0,
        bnbKesRate = 0;

  /// Retains the real holdings even if the price service is unavailable.
  const HomeBalance.unpriced({
    required this.usdt,
    required this.btc,
  })  : totalKes = 0,
        usdtValueKes = 0,
        btcValueKes = 0,
        hasValuation = false,
        indicativeRates = false,
        usdtKesRate = 0,
        btcKesRate = 0,
        ethKesRate = 0,
        bnbKesRate = 0;

  final double usdt;
  final double btc;
  final double totalKes;
  final double usdtValueKes;
  final double btcValueKes;
  final bool hasValuation;

  /// True when reference/stale KES exchange rates, not fresh quotes, are used.
  final bool indicativeRates;

  /// KES value of one unit of each display denomination.
  /// A zero ETH/BNB quote means that quote is unavailable, not a zero price.
  final double usdtKesRate;
  final double btcKesRate;
  final double ethKesRate;
  final double bnbKesRate;

  /// Returns null when the required market quote has not been obtained.
  /// Conversion changes only the presentation; holdings remain USDT/BTC.
  double? valueIn(double kesValue, WalletDisplayCurrency currency) {
    if (!hasValuation || !kesValue.isFinite) return null;
    if (currency == WalletDisplayCurrency.kes) return kesValue;
    if (kesValue == 0) return 0;
    final kesPerUnit = switch (currency) {
      WalletDisplayCurrency.btc => btcKesRate,
      WalletDisplayCurrency.eth => ethKesRate,
      WalletDisplayCurrency.bnb => bnbKesRate,
      WalletDisplayCurrency.usdt => usdtKesRate,
      WalletDisplayCurrency.kes => 1.0,
    };
    if (!kesPerUnit.isFinite || kesPerUnit <= 0) return null;
    return kesValue / kesPerUnit;
  }

  factory HomeBalance.valued({
    required double usdt,
    required double btc,
    required double usdtKes,
    required double btcKes,
    double ethKes = 0,
    double bnbKes = 0,
    bool indicativeRates = false,
  }) {
    final tetherKes = usdt * usdtKes;
    final bitcoinKes = btc * btcKes;
    return HomeBalance(
      usdt: usdt,
      btc: btc,
      usdtValueKes: tetherKes,
      btcValueKes: bitcoinKes,
      totalKes: tetherKes + bitcoinKes,
      usdtKesRate: usdtKes,
      btcKesRate: btcKes,
      ethKesRate: ethKes,
      bnbKesRate: bnbKes,
      indicativeRates: indicativeRates,
    );
  }
}
