import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:binance/features/home/domain/wallet_display_currency.dart';
import 'package:binance/features/home/presentation/display_currency_picker.dart';
import 'package:binance/features/home/presentation/home_provider.dart';
import 'package:binance/core/theme/binance_palette.dart';
import 'package:flutter/material.dart';
import 'package:binance/features/assets/presentation/select_currency_screen.dart';
import 'package:binance/features/assets/presentation/select_method_screen.dart';
import 'package:binance/features/assets/presentation/choose_network_screen.dart';
import 'package:binance/features/assets/presentation/deposit_usdt_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:binance/features/home/domain/home_balance.dart';
import 'package:binance/core/utils/wallet_amount_formatter.dart';
import 'package:binance/features/assets/domain/wallet_allocation.dart';

void main() {
  test('selecting a denomination converts KES across all five units', () {
    final balance = HomeBalance.valued(
      usdt: 2,
      btc: 0.01,
      usdtKes: 130,
      btcKes: 10000000,
      ethKes: 300000,
      bnbKes: 100000,
    );
    expect(balance.totalKes, 100260);
    expect(balance.valueIn(balance.totalKes, WalletDisplayCurrency.kes), 100260);
    expect(balance.valueIn(balance.totalKes, WalletDisplayCurrency.usdt),
        closeTo(771.23076923, 0.000001));
    expect(balance.valueIn(balance.totalKes, WalletDisplayCurrency.btc),
        closeTo(0.010026, 1e-9));
    expect(balance.valueIn(balance.totalKes, WalletDisplayCurrency.eth),
        closeTo(0.3342, 1e-9));
    expect(balance.valueIn(balance.totalKes, WalletDisplayCurrency.bnb),
        closeTo(1.0026, 1e-9));
    // The wallet's actual token quantities are never converted or changed.
    expect(balance.usdt, 2);
    expect(balance.btc, 0.01);
  });

  test('missing non-wallet quote is unavailable, not a fabricated rate', () {
    final balance = HomeBalance.valued(
      usdt: 3, btc: 0, usdtKes: 130, btcKes: 10000000,
    );
    expect(balance.valueIn(balance.totalKes, WalletDisplayCurrency.eth), isNull);
    expect(formatWalletDisplayValue(null, WalletDisplayCurrency.eth), '--');
    expect(formatWalletDisplayValue(3.19, WalletDisplayCurrency.usdt), '3.19');
    expect(formatWalletAssetValue(3.09, WalletDisplayCurrency.usdt),
        '3.09 USDT');
    expect(formatWalletDisplayValue(426.87, WalletDisplayCurrency.kes),
        'KSh426.87');
    expect(formatWalletDisplayValue(0.00001234, WalletDisplayCurrency.btc),
        '0.00001234');
  });

  testWidgets('currency dropdown has all five options and remembers choice',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: Scaffold(body: Center(
          child: DisplayCurrencyPicker(child: Text('Choose unit')),
        )),
      ),
    ));
    expect(container.read(displayCurrencyProvider), WalletDisplayCurrency.kes);
    await tester.tap(find.byKey(const Key('display-currency-picker')));
    await tester.pumpAndSettle();
    for (final code in const ['BTC', 'ETH', 'BNB', 'USDT', 'KES']) {
      expect(find.text(code), findsOneWidget);
    }
    await tester.tap(find.text('USDT'));
    await tester.pumpAndSettle();
    expect(container.read(displayCurrencyProvider), WalletDisplayCurrency.usdt);
  });

  test('shared dark palette uses lighter blue-charcoal surfaces on all tabs', () {
    expect(BinancePalette.canvas, const Color(0xFF1F2630));
    expect(BinancePalette.surface, const Color(0xFF272F3A));
    expect(BinancePalette.raised, const Color(0xFF333B48));
    expect(BinancePalette.divider, const Color(0xFF303847));
  });

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
  test('indicative rates keep allocation visible when live prices fail', () {
    final estimate = HomeBalance.valued(
      usdt: 2,
      btc: 12 / 10409400,
      usdtKes: 130,
      btcKes: 10409400,
      indicativeRates: true,
    );
    final allocation = WalletAllocation.fromBalance(estimate);
    expect(estimate.indicativeRates, isTrue);
    expect(allocation.hasValuation, isTrue);
    expect(allocation.usdtFraction, closeTo(260 / 272, 0.000001));
    expect(allocation.btcFraction, closeTo(12 / 272, 0.000001));
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



  testWidgets('Deposit Asset opens the USDT Choose Network screen',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SelectMethodScreen()));

    expect(find.text('Deposit Asset'), findsOneWidget);
    await tester.tap(find.text('Deposit Asset'));
    await tester.pumpAndSettle();

    expect(find.text('Choose Network'), findsOneWidget);
    expect(find.text('BSC'), findsOneWidget);
    expect(find.text('BNB Smart Chain (BEP20)'), findsOneWidget);
    expect(find.text('TRX'), findsOneWidget);
    expect(find.text('Min. deposit >0.01 USDT'), findsWidgets);
    expect(find.byKey(const Key('network-list')), findsOneWidget);

    // Clicking a demo network must not navigate to a fake deposit address.
    await tester.tap(find.byKey(const ValueKey('network-card-BSC')));
    await tester.pump();
    expect(find.text('Choose Network'), findsOneWidget);
    expect(find.textContaining('not configured yet.'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Select Method'), findsOneWidget);
  });

  testWidgets('Choose Network includes the full eleven-network catalogue',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ChooseNetworkScreen()));
    for (final code in <String>[
      'BSC', 'TRX', 'ETH', 'POL', 'PLASMA', 'SOL',
      'APT', 'ARBITRUM', 'TON', 'AVAXC', 'CELO',
    ]) {
      await tester.scrollUntilVisible(
        find.byKey(ValueKey('network-card-$code')),
        150,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.byKey(ValueKey('network-card-$code')), findsOneWidget);
    }
  });



  testWidgets('TRX network opens Deposit USDT with a real QR widget',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ChooseNetworkScreen()));
    await tester.tap(find.byKey(const ValueKey('network-card-TRX')));
    await tester.pumpAndSettle();

    expect(find.text('Deposit USDT'), findsOneWidget);
    expect(find.text('Tron (TRC20)'), findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);
    expect(
      tester.widget<QrImageView>(find.byType(QrImageView)).data,
      DepositUsdtScreen.previewTrc20Address,
    );
    expect(find.byKey(const Key('deposit-demo-warning')), findsNothing);
    expect(find.text('TMZig2yuw3R3XEJN75nwHAh\n3CAWQsvHvbH'), findsOneWidget);
    expect(find.byKey(const Key('save-share-address')), findsOneWidget);
  });

  testWidgets('default address matches QR and is copyable',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DepositUsdtScreen()));
    expect(
      tester.widget<QrImageView>(find.byType(QrImageView)).data,
      DepositUsdtScreen.previewTrc20Address,
    );
    await tester.tap(find.byKey(const Key('copy-deposit-address')));
    await tester.pump();
    expect(find.text('Deposit address copied.'), findsOneWidget);
  });

  testWidgets('backend-supplied TRC20 address feeds the QR exactly',
      (tester) async {
    const address = 'TMZig2yuw3R3XEJN75nwHAh3CAWQsvHvbH';
    await tester.pumpWidget(
      const MaterialApp(
        home: DepositUsdtScreen(trustedDepositAddress: address),
      ),
    );
    expect(
      tester.widget<QrImageView>(find.byType(QrImageView)).data,
      address,
    );
    expect(find.byKey(const Key('deposit-demo-warning')), findsNothing);
    expect(find.text('TMZig2yuw3R3XEJN75nwHAh\n3CAWQsvHvbH'), findsOneWidget);
  });


}
