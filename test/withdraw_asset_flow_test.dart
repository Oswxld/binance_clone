import 'package:binance/features/assets/data/withdrawal_repository.dart';
import 'package:binance/features/assets/presentation/send_select_method_screen.dart';
import 'package:binance/features/home/domain/home_balance.dart';
import 'package:binance/features/home/presentation/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingWallet implements WithdrawalRepository {
  int count = 0;
  String? address;
  double? amount;

  @override
  Future<WithdrawalReceipt> withdrawUsdt({
    required double amount,
    required String address,
  }) async {
    count++;
    this.address = address;
    this.amount = amount;
    return WithdrawalReceipt(
      transactionId: List.filled(100, 'a').join(),
      createdAtUtc: DateTime.utc(2026, 11, 5, 16, 18, 30),
    );
  }
}

void main() {
  testWidgets('Withdraw Asset -> address -> amount -> details',
      (tester) async {
    final wallet = _RecordingWallet();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        homeBalanceProvider.overrideWith(
          (ref) => Stream.value(HomeBalance.valued(
            usdt: 100, btc: 0.02,
            usdtKes: 130, btcKes: 10409400))),
        withdrawalRepositoryProvider.overrideWithValue(wallet),
      ],
      child: const MaterialApp(
        home: SendSelectMethodScreen(asset: 'USDT'),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Withdraw Asset'), findsOneWidget);
    expect(find.text('Send to Binance users'), findsOneWidget);
    await tester.tap(find.byKey(const Key('withdraw-asset-method')));
    await tester.pumpAndSettle();

    expect(find.text('Enter address'), findsOneWidget);
    expect(find.text('Select Network'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('withdraw-address-input')),
      'anyAddress123');
    await tester.pump();

    expect(find.text('TRC20 (TRX)'), findsOneWidget);
    final next = tester.widget<FilledButton>(
      find.byKey(const Key('withdraw-address-next')));
    expect(next.onPressed, isNotNull);
    await tester.tap(find.byKey(const Key('withdraw-address-next')));
    await tester.pumpAndSettle();

    expect(find.text('Send USDT'), findsOneWidget);
    final amount = tester.widget<TextField>(
      find.byKey(const Key('withdraw-usdt-amount')));
    expect(amount.keyboardType,
      const TextInputType.numberWithOptions(decimal: true));
    await tester.enterText(
      find.byKey(const Key('withdraw-usdt-amount')), '50');
    await tester.pump();

    expect(find.text('46.0000000000 USDT'), findsOneWidget);
    expect(find.text('4.0000000000 USDT'), findsOneWidget);
    expect(wallet.count, 0);

    await tester.tap(find.byKey(const Key('withdraw-submit')));
    await tester.pumpAndSettle();

    expect(wallet.count, 1);
    expect(wallet.address, 'anyAddress123');
    expect(wallet.amount, 50);
    expect(find.text('Withdrawal Details'), findsOneWidget);
    expect(find.text('Txid'), findsOneWidget);
    expect(find.text(List.filled(100, 'a').join()), findsOneWidget);
    expect(find.text('2026-11-05 16:18:30 UTC'), findsOneWidget);
    expect(find.text('Simulated'), findsOneWidget);
    expect(find.text('anyAddress123'), findsOneWidget);
    expect(find.byKey(const Key('withdraw-again')), findsOneWidget);
  });

  testWidgets('Withdraw disabled above available balance',
      (tester) async {
    final wallet = _RecordingWallet();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        homeBalanceProvider.overrideWith(
          (ref) => Stream.value(HomeBalance.valued(
            usdt: 3, btc: 0, usdtKes: 130, btcKes: 10409400))),
        withdrawalRepositoryProvider.overrideWithValue(wallet),
      ],
      child: const MaterialApp(
        home: SendSelectMethodScreen(asset: 'USDT'),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('withdraw-asset-method')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('withdraw-address-input')), 'TRaddress');
    await tester.pump();
    await tester.tap(find.byKey(const Key('withdraw-address-next')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('withdraw-usdt-amount')), '5');
    await tester.pump();
    final withdraw = tester.widget<FilledButton>(
      find.byKey(const Key('withdraw-submit')));
    expect(withdraw.onPressed, null);
    expect(wallet.count, 0);
  });
}
