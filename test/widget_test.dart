import 'package:flutter_test/flutter_test.dart';
import 'package:binance/features/home/domain/home_balance.dart';

void main() {
  test('USDT and BTC holdings are both included in KES total', () {
    final result = HomeBalance.valued(
      usdt: 2.5,
      btc: 0.01,
      usdtKes: 130,
      btcKes: 10000000,
    );
    expect(result.totalKes, 100325);
  });

  test('zero balances yield zero valuation', () {
    final result = HomeBalance.valued(
      usdt: 0,
      btc: 0,
      usdtKes: 130,
      btcKes: 10000000,
    );
    expect(result.totalKes, 0);
  });
}
