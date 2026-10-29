import 'dart:async';

import 'package:binance/core/theme/binance_palette.dart';
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

    // The reference design has a short allocation card: just title + bar.
    // The split still comes from the live KES values, without a legend.
    expect(find.textContaining('USDT 95.6%'), findsNothing);
    expect(find.textContaining('BTC 4.4%'), findsNothing);
    final allocationCard = find.byKey(const Key('assets-allocation-card'));
    expect(tester.getSize(allocationCard).height, lessThan(80));
    expect(tester.getSize(allocationCard).height, greaterThan(50));

    final usdtSegment = find.byKey(const Key('allocation-usdt-segment'));
    final btcSegment = find.byKey(const Key('allocation-btc-segment'));
    final blueWidth = tester.getSize(usdtSegment).width;
    final yellowWidth = tester.getSize(btcSegment).width;
    expect(tester.getSize(usdtSegment).height, 7);
    expect(blueWidth / (blueWidth + yellowWidth),
        closeTo(260 / 272, 0.01));

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

    final updatedBlue = tester.getSize(usdtSegment).width;
    final updatedYellow = tester.getSize(btcSegment).width;
    expect(updatedBlue / (updatedBlue + updatedYellow),
        closeTo(0.25, 0.01));
    expect(tester.getSize(btcSegment).height, 7);
    // Balance and Allocation headings are softer than their primary figures.
    expect(tester.widget<Text>(find.text('Balance')).style?.color,
        BinancePalette.textSecondary);
    expect(tester.widget<Text>(find.text('Allocation')).style?.color,
        BinancePalette.textSecondary);
    expect(tester.widget<Text>(find.text('KES')).style?.color,
        BinancePalette.textPrimary);
    expect(tester.widget<Text>(find.text('Est. Total Value')).style?.color,
        BinancePalette.textPrimary);
    expect(tester.widget<Text>(find.text("Today's PNL")).style?.color,
        BinancePalette.textPrimary);
  });
}
