import '../../features/home/domain/wallet_display_currency.dart';

/// Consistent formatting for Home and Assets KES estimates.
String formatWalletMoney(double amount) {
  final parts = amount.toStringAsFixed(2).split('.');
  var whole = parts.first;
  final groups = <String>[];
  while (whole.length > 3) {
    groups.insert(0, whole.substring(whole.length - 3));
    whole = whole.substring(0, whole.length - 3);
  }
  groups.insert(0, whole);
  return groups.join(',') + '.' + parts.last;
}

/// Display the full ten fractional digits supported by b_balances NUMERIC(24,10).
String formatWalletQuantity(double amount) => amount.toStringAsFixed(10);

/// Portfolio header: KES has a leading KSh, other denominations have no prefix.
String formatWalletDisplayValue(
    double? amount, WalletDisplayCurrency currency) {
  if (amount == null || !amount.isFinite) {
    return currency == WalletDisplayCurrency.kes ? 'KSh--' : '--';
  }
  if (currency == WalletDisplayCurrency.kes) {
    return 'KSh${formatWalletMoney(amount)}';
  }
  if (currency == WalletDisplayCurrency.usdt) {
    return formatWalletMoney(amount);
  }
  // Coin-sized valuations need more precision than fiat; avoid trailing zeroes.
  final digits = amount.toStringAsFixed(8);
  return digits.replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

/// Smaller balance-card approximations include the selected unit after number.
String formatWalletAssetValue(
    double? amount, WalletDisplayCurrency currency) {
  final number = formatWalletDisplayValue(amount, currency);
  if (currency == WalletDisplayCurrency.kes) return number;
  return amount == null || !amount.isFinite
      ? '--'
      : '$number ${currency.code}';
}
