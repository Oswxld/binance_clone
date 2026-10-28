import '../../home/domain/home_balance.dart';

/// KES-value-weighted allocation of the holdings in public.b_balances.
/// Only known positive valuations can produce a nonempty allocation bar.
class WalletAllocation {
  const WalletAllocation({
    required this.usdtFraction,
    required this.btcFraction,
    required this.hasValuation,
  });

  final double usdtFraction;
  final double btcFraction;
  final bool hasValuation;

  factory WalletAllocation.fromBalance(HomeBalance balance) {
    final total = balance.totalKes;
    if (!balance.hasValuation || !total.isFinite || total <= 0) {
      return const WalletAllocation(
        usdtFraction: 0,
        btcFraction: 0,
        hasValuation: false,
      );
    }

    final share = (balance.usdtValueKes / total).clamp(0.0, 1.0).toDouble();
    return WalletAllocation(
      usdtFraction: share,
      btcFraction: 1.0 - share,
      hasValuation: true,
    );
  }
}
