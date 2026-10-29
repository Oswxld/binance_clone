/// Display denominations for the same underlying USDT/BTC demo holdings.
/// Changing the display currency never trades or changes wallet balances.
enum WalletDisplayCurrency {
  btc('BTC'),
  eth('ETH'),
  bnb('BNB'),
  usdt('USDT'),
  kes('KES');

  const WalletDisplayCurrency(this.code);
  final String code;
}
