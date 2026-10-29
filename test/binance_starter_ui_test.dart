import 'package:binance/core/presentation/app_bottom_navigation.dart';
import 'package:binance/features/home/domain/home_balance.dart';
import 'package:binance/features/home/presentation/home_provider.dart';
import 'package:binance/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('center yellow Trade navigation circle is 52x52', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const Spacer(),
                AppBottomNavigation(
                  selected: AppTab.home,
                  onSelect: (_) {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const Key('bottom-trade-circle'))),
      const Size(52, 52),
    );
    final shaped = tester.widget<CustomPaint>(
      find.byKey(const Key('nav-shaped-background')),
    );
    expect(shaped.painter, isNotNull);

    // In the reference the yellow circle finishes at about the same
    // baseline as the Markets label; it must not hover high above it.
    final nav = tester.getRect(find.byType(AppBottomNavigation));
    final circle = tester.getRect(find.byKey(const Key('bottom-trade-circle')));
    final marketsLabel = tester.getRect(find.text('Markets'));
    expect((circle.center.dx - nav.center.dx).abs(), lessThan(0.5));
    expect((circle.bottom - marketsLabel.bottom).abs(), lessThan(4));
    // The circle is a small amount higher than the straight divider,
    // rather than floating far above the navigation.
    expect(circle.top - nav.top, 18);
  });

  testWidgets('bank card grows taller and keeps both carousel actions',
      (tester) async {
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

    final card = find.byKey(const Key('home-bank-transfer-card'));
    expect(tester.getSize(card).height, 190);

    final carousel = find.byKey(const Key('home-bank-transfer-carousel'));
    expect(carousel, findsOneWidget);
    await tester.ensureVisible(carousel);
    await tester.pumpAndSettle();
    await tester.drag(carousel, const Offset(-140, 0));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('bank-dot-1-active')), findsOneWidget);
  });
}
