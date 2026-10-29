import 'package:binance/features/home/domain/home_balance.dart';
import 'package:binance/features/home/presentation/home_provider.dart';
import 'package:binance/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpHome(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        homeBalanceProvider.overrideWith(
          (ref) => Stream.value(const HomeBalance.zero()),
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: SafeArea(child: HomeScreen()),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('Home ticker automatically scrolls headlines upward',
      (tester) async {
    await _pumpHome(tester);

    final ticker = tester.widget<PageView>(
      find.byKey(const Key('home-news-ticker')),
    );
    expect(ticker.scrollDirection, Axis.vertical);
    expect(ticker.controller!.page, 0);

    await tester.pump(const Duration(milliseconds: 3700));
    await tester.pump(const Duration(milliseconds: 520));

    final updated = tester.widget<PageView>(
      find.byKey(const Key('home-news-ticker')),
    );
    expect(updated.controller!.page, closeTo(1.0, 0.05));
  });

  testWidgets('Get Rewards cycles exactly two offers and two page dots',
      (tester) async {
    await _pumpHome(tester);

    expect(find.byKey(const Key('home-rewards-carousel')), findsOneWidget);
    expect(find.byKey(const Key('rewards-dot-0-active')), findsOneWidget);
    expect(find.byKey(const Key('rewards-dot-1-inactive')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 4300));
    await tester.pump(const Duration(milliseconds: 620));

    expect(find.byKey(const Key('rewards-dot-0-inactive')), findsOneWidget);
    expect(find.byKey(const Key('rewards-dot-1-active')), findsOneWidget);
    final pageView = tester.widget<PageView>(
      find.byKey(const Key('home-rewards-carousel')),
    );
    expect(pageView.childrenDelegate.estimatedChildCount, 2);
  });

  testWidgets('Swiping the bank card changes Deposit into red Withdraw',
      (tester) async {
    await _pumpHome(tester);

    final card = find.byKey(const Key('home-bank-transfer-carousel'));
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bank-dot-0-active')), findsOneWidget);

    await tester.drag(card, const Offset(-140, 0));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bank-dot-1-active')), findsOneWidget);
    final withdraw = tester.widget<Text>(find.text('Withdraw').last);
    expect(withdraw.style?.color, const Color(0xFFF6465D));
  });
}
