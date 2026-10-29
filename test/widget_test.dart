import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:binance/features/assets/presentation/select_currency_screen.dart';
import 'package:binance/features/assets/presentation/select_method_screen.dart';
import 'package:binance/features/home/domain/home_balance.dart';
import 'package:binance/core/utils/wallet_amount_formatter.dart';
import 'package:binance/features/assets/domain/wallet_allocation.dart';

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
  test('allocation updates with USDT/BTC KES values', () {
    final first = WalletAllocation.fromBalance(HomeBalance.valued(
      usdt: 3,
      btc: 1,
      usdtKes: 100,
      btcKes: 100,
    ));
    expect(first.usdtFraction, closeTo(0.75, 0.00001));
    expect(first.btcFraction, closeTo(0.25, 0.00001));

    final second = WalletAllocation.fromBalance(HomeBalance.valued(
      usdt: 1,
      btc: 3,
      usdtKes: 100,
      btcKes: 100,
    ));
    expect(second.usdtFraction, closeTo(0.25, 0.00001));
    expect(second.btcFraction, closeTo(0.75, 0.00001));
  });

  test('allocation stays empty for zero or unpriced balances', () {
    final zero = WalletAllocation.fromBalance(const HomeBalance.zero());
    final unknown = WalletAllocation.fromBalance(
      const HomeBalance.unpriced(usdt: 3, btc: 0.1),
    );
    expect(zero.hasValuation, false);
    expect(zero.usdtFraction, 0);
    expect(zero.btcFraction, 0);
    expect(unknown.hasValuation, false);
    expect(unknown.usdtFraction, 0);
  });


  testWidgets('Add Funds currency list searches by ticker and name',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SelectCurrencyScreen()),
    );
    expect(find.text('Select Currency'), findsOneWidget);
    expect(find.text('Trending'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('currency-search')), 'Bitcoin',
    );
    await tester.pumpAndSettle();
    expect(find.text('BTC'), findsOneWidget);
    expect(find.text('USDT'), findsNothing);
    await tester.enterText(
      find.byKey(const Key('currency-search')), 'zzzznotfound',
    );
    await tester.pumpAndSettle();
    expect(find.text('No matching currencies'), findsOneWidget);
  });



  testWidgets('USDT shows the equalizer on Select Currency before routing',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SelectCurrencyScreen()),
    );
    expect(find.byKey(const Key('usdt-loading-toast')), findsNothing);
    expect(find.text('Select Method'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('currency-USDT')));
    await tester.pump();

    // Currency list is still visible while the tile animates. The next
    // screen must not be built before the under-one-second delay ends.
    expect(find.text('Select Currency'), findsOneWidget);
    expect(find.byKey(const Key('usdt-loading-toast')), findsOneWidget);
    expect(find.text('Select Method'), findsNothing);

    await tester.pump(const Duration(milliseconds: 450));
    expect(find.byKey(const Key('usdt-loading-toast')), findsOneWidget);
    expect(find.text('Select Method'), findsNothing);

    await tester.pump(const Duration(milliseconds: 460));
    await tester.pumpAndSettle();

    expect(find.text('Select Method'), findsOneWidget);
    expect(find.text('Deposit Asset'), findsOneWidget);
    expect(find.text('Receive Via Binance Pay'), findsOneWidget);
    expect(find.text('P2P Trading'), findsOneWidget);
    expect(find.text('Buy with KES'), findsOneWidget);
    expect(find.byKey(const Key('usdt-loading-toast')), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Select Currency'), findsOneWidget);
    expect(find.byKey(const Key('usdt-loading-toast')), findsNothing);
  });

  testWidgets('Select Method never contains the currency-screen loader',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SelectMethodScreen()),
    );
    expect(find.text('Select Method'), findsOneWidget);
    expect(find.byKey(const Key('usdt-loading-toast')), findsNothing);
    expect(find.byKey(const Key('usdt-equalizer-tile')), findsNothing);
  });


}
