import 'package:flutter_test/flutter_test.dart';
import 'package:binance/features/home/domain/home_balance.dart';
import 'package:binance/core/utils/wallet_amount_formatter.dart';

void main() {
  test('USDT and BTC holdings are both included in KES total', () {
    final result = HomeBalance.valued(
      usdt: 2.5,
      btc: 0.01,
      usdtKes: 130,
      btcKes: 10000000,
    );
    expect(result.totalKes, 100325);
    expect(result.usdtValueKes, 325);
    expect(result.btcValueKes, 100000);
    expect(result.hasValuation, isTrue);
  });

  test('zero balances yield zero valuation and correct display', () {
    const result = HomeBalance.zero();
    expect(result.usdt, 0);
    expect(result.btc, 0);
    expect(result.totalKes, 0);
    expect(result.hasValuation, isTrue);
    expect(formatWalletMoney(result.totalKes), '0.00');
    expect(formatWalletQuantity(result.usdt), '0.0000000000');
    expect(formatWalletQuantity(result.btc), '0.0000000000');
  });

  test('unavailable market prices must not hide the real holdings', () {
    const result = HomeBalance.unpriced(
      usdt: 3.2683360634,
      btc: 0.0000012437,
    );
    expect(result.hasValuation, isFalse);
    expect(formatWalletQuantity(result.usdt), '3.2683360634');
    expect(formatWalletQuantity(result.btc), '0.0000012437');
  });

  test('KES formatting matches across Home and Assets', () {
    expect(formatWalletMoney(10497860.1), '10,497,860.10');
  });
}
