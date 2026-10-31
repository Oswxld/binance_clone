import 'package:binance/features/assets/data/demo_send_repository.dart';
import 'package:binance/features/assets/presentation/send_amount_screen.dart';
import 'package:binance/features/assets/presentation/send_select_asset_screen.dart';
import 'package:binance/features/home/domain/home_balance.dart';
import 'package:binance/features/home/presentation/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSendRepository implements DemoSendRepository {
  int calls = 0;
  String? lastAsset;
  double? lastAmount;

  @override
  Future<void> deduct({required String asset, required double amount}) async {
    calls++;
    lastAsset = asset;
    lastAmount = amount;
  }
}

void main() {
  testWidgets('Send walks all screens and debits only after Confirm',
      (tester) async {
    final fake = _FakeSendRepository();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        homeBalanceProvider.overrideWith(
          (ref) => Stream.value(HomeBalance.valued(
            usdt: 20, btc: 0.5, usdtKes: 130, btcKes: 10409400))),
        demoSendRepositoryProvider.overrideWithValue(fake),
      ],
      child: const MaterialApp(home: SendSelectAssetScreen()),
    ));
    await tester.pumpAndSettle();

    // Assets picker shows PNG icons from the established local coin folder.
    final usdtIcon = find.byWidgetPredicate((w) =>
      w is Image &&
      w.image is AssetImage &&
      (w.image as AssetImage).assetName ==
        'assets/svgs/home_icons/USDT.png');
    expect(usdtIcon, findsWidgets);
    await tester.tap(find.byKey(const Key('send-select-USDT')));
    await tester.pumpAndSettle();

    expect(find.text('Select Method'), findsOneWidget);
    await tester.tap(find.byKey(const Key('send-to-binance-users')));
    await tester.pumpAndSettle();

    // Any numerical recipient accepted, no API lookup.
    await tester.enterText(
      find.byKey(const Key('send-recipient-id')), '123456789');
    await tester.pump();
    await tester.tap(find.byKey(const Key('send-recipient-continue')));
    await tester.pumpAndSettle();

    expect(find.text('Payee will Receive'), findsOneWidget);
    final amountField = tester.widget<TextField>(
      find.byKey(const Key('send-amount-input')));
    expect(amountField.keyboardType,
      const TextInputType.numberWithOptions(decimal: true));
    await tester.enterText(
      find.byKey(const Key('send-amount-input')), '2.5');
    await tester.pump();
    await tester.tap(find.byKey(const Key('send-amount-continue')));
    await tester.pumpAndSettle();

    expect(find.text('Confirm Payment'), findsOneWidget);
    expect(fake.calls, 0);
    await tester.tap(find.byKey(const Key('send-confirm-button')));
    await tester.pumpAndSettle();

    expect(fake.calls, 1);
    expect(fake.lastAsset, 'USDT');
    expect(fake.lastAmount, 2.5);
    expect(find.text('Balance updated'), findsOneWidget);
  });

  testWidgets('Payee amount cannot exceed available demo holdings',
      (tester) async {
    final fake = _FakeSendRepository();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        homeBalanceProvider.overrideWith(
          (ref) => Stream.value(HomeBalance.valued(
            usdt: 1, btc: 0.5, usdtKes: 130, btcKes: 10409400))),
        demoSendRepositoryProvider.overrideWithValue(fake),
      ],
      child: const MaterialApp(home: SendAmountScreen(
        asset: 'USDT', recipient: '9999999')),
    ));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('send-amount-input')), '2');
    await tester.pump();

    final continueButton = tester.widget<FilledButton>(
      find.byKey(const Key('send-amount-continue')));
    expect(continueButton.onPressed, null);
    expect(find.byKey(const Key('send-amount-warning')), findsOneWidget);
    expect(fake.calls, 0);
  });
}
