import 'dart:async';

import 'package:binance/features/assets/presentation/assets_screen.dart';
import 'package:binance/features/home/domain/home_balance.dart';
import 'package:binance/features/home/presentation/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Assets allocation follows live balance updates and uses Home PNG icons',
      (tester) async {
    final updates = StreamController<HomeBalance>();
    addTearDown(updates.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeBalanceProvider.overrideWith((ref) => updates.stream),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SafeArea(child: AssetsScreen()),
          ),
        ),
      ),
    );

    // Today's PNL is an intentionally fixed screenshot demo figure.
    final pnl = tester.widget<Text>(
      find.byKey(const Key('assets-today-pnl')),
    );
    expect(pnl.data, '-KSh0.72631392 (-0.19%)');
    expect(pnl.style?.color, const Color(0xFFF6465D));

    updates.add(HomeBalance.valued(
      usdt: 2,
      btc: 12 / 10409400,
      usdtKes: 130,
      btcKes: 10409400,
      indicativeRates: true,
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('USDT 95.6%'), findsOneWidget);
    expect(find.text('BTC 4.4%'), findsOneWidget);
    expect(find.byKey(const Key('allocation-indicative-price-label')),
        findsOneWidget);

    final usdtSegment = find.byKey(const Key('allocation-usdt-segment'));
    expect(tester.getSize(usdtSegment).height, 7);

    final usdtIcon = tester.widget<Image>(
      find.byKey(const ValueKey('assets-coin-icon-USDT')),
    );
    final btcIcon = tester.widget<Image>(
      find.byKey(const ValueKey('assets-coin-icon-BTC')),
    );
    expect((usdtIcon.image as AssetImage).assetName,
        'assets/svgs/home_icons/USDT.png');
    expect((btcIcon.image as AssetImage).assetName,
        'assets/svgs/home_icons/BTC.png');

    // Updating holdings without changing a widget key must animate the
    // visible proportions. A price-only update would do the same.
    updates.add(HomeBalance.valued(
      usdt: 1,
      btc: 1,
      usdtKes: 100,
      btcKes: 300,
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('USDT 25.0%'), findsOneWidget);
    expect(find.text('BTC 75.0%'), findsOneWidget);
    expect(find.byKey(const Key('allocation-indicative-price-label')),
        findsNothing);
    expect(tester.getSize(find.byKey(const Key('allocation-btc-segment'))).height,
        7);
  });
}
