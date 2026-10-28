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
