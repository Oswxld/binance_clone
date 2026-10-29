import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../domain/wallet_allocation.dart';
import 'select_currency_screen.dart';
import 'portfolio_sparkline.dart';

import '../../home/domain/home_balance.dart';
import '../../home/presentation/home_provider.dart';
import '../../../core/utils/wallet_amount_formatter.dart';
import '../../../core/theme/binance_palette.dart';

const _bg = BinancePalette.canvas;
const _surface = BinancePalette.surface;
const _border = BinancePalette.border;
const _muted = BinancePalette.textMuted;
const _white = BinancePalette.textPrimary;
const _yellow = BinancePalette.yellow;

Widget _icon(String name, double size) =>
    SvgPicture.asset('assets/svgs/' + name + '.svg',
        height: size, width: size);

class AssetsScreen extends ConsumerWidget {
  const AssetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Same single StreamProvider as Home, not a second database subscription.
    final balance = ref.watch(homeBalanceProvider);
    final snapshot = balance.asData?.value;
    final quantities = snapshot ?? const HomeBalance.zero();

    return ColoredBox(
      color: _bg,
      child: Column(
        children: [
          const _AssetsCategoryTabs(),
          Expanded(
            child: RefreshIndicator(
              color: _yellow,
              onRefresh: () async {
                ref.invalidate(homeBalanceProvider);
                try {
                  await ref.read(homeBalanceProvider.future);
                } catch (_) {
                  // Provider displays the subscription failure.
                }
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 7, 14, 16),
                children: [
                  _PortfolioHeader(balance: balance),
                  const SizedBox(height: 10),
                  const _AssetActions(),
                  const SizedBox(height: 12),
                  _AllocationCard(balance: quantities),
                  const SizedBox(height: 12),
                  _BalancesCard(balance: balance, quantities: quantities),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssetsCategoryTabs extends StatelessWidget {
  const _AssetsCategoryTabs();

  @override
  Widget build(BuildContext context) {
    const tabs = ['Overview', 'Futures', 'Earn', 'Spot', 'Funding'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 4),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            if (i != 0) const SizedBox(width: 16),
            SizedBox(
              height: 29,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Text(
                    tabs[i],
                    style: TextStyle(
                      fontSize: i == 0 ? 14 : 13,
                      fontWeight: i == 0
                          ? FontWeight.w600 : FontWeight.w400,
                      color: i == 0 ? Colors.white : _muted,
                    ),
                  ),
                  if (i == 0)
                    const Positioned(
                      bottom: 0,
                      child: SizedBox(
                        width: 14,
                        height: 2.5,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: _yellow,
                            borderRadius:
                                BorderRadius.all(Radius.circular(2)),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PortfolioHeader extends StatelessWidget {
  const _PortfolioHeader({required this.balance});
  final AsyncValue<HomeBalance> balance;

  @override
  Widget build(BuildContext context) {
    final current = balance.asData?.value;
    final totalText = balance.hasError
        ? 'KSh--'
        : (current != null && !current.hasValuation)
            ? 'KSh--'
            : 'KSh' + formatWalletMoney(current?.totalKes ?? 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Est. Total Value', style: TextStyle(
              color: _muted, fontSize: 11.5,
            )),
            const SizedBox(width: 5),
            _icon('asset_eye', 14),
            const Spacer(),
            _icon('asset_history', 18),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Amount and its currency selector form ONE compact group.
            // They shrink together on narrow phones without pushing the
            // currency label against the graph on the opposite side.
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        totalText,
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 24,
                          letterSpacing: -0.45,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text('KES', style: TextStyle(
                    fontSize: 10, color: _muted,
                    fontWeight: FontWeight.w500,
                  )),
                  const SizedBox(width: 2),
                  _icon('asset_currency_chevron', 11),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const PortfolioSparkline(),
          ],
        ),
        const SizedBox(height: 3),
        const Row(
          children: [
            Text("Today's PNL", style: TextStyle(
              fontSize: 10.5,
              color: _muted,
              decoration: TextDecoration.underline,
              decorationColor: _muted,
              decorationStyle: TextDecorationStyle.dotted,
            )),
            SizedBox(width: 6),
            // Screenshot-matching demo figure; not a calculated daily PNL.
            Text(
              '-KSh0.72631392 (-0.19%)',
              key: Key('assets-today-pnl'),
              style: TextStyle(
                fontSize: 10.5,
                color: BinancePalette.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 2),
            Icon(Icons.chevron_right, size: 14, color: _muted),
          ],
        ),
        if (current != null && !current.hasValuation) ...[
          const SizedBox(height: 9),
          const Text('KES prices unavailable; holdings are up to date.',
            style: TextStyle(color: Color(0xFFF6465D), fontSize: 11)),
        ],
        if (balance.hasError) ...[
          const SizedBox(height: 9),
          const Text('Could not connect to balances. Pull down to retry.',
            style: TextStyle(color: Color(0xFFF6465D), fontSize: 11)),
        ],
        const SizedBox(height: 5),
        Center(child: _icon('asset_down_chevron', 12)),
      ],
    );
  }
}

class _AssetActions extends StatelessWidget {
  const _AssetActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            'Add Funds',
            'asset_add_funds',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SelectCurrencyScreen(),
              ),
            ),
          ),
        ),
        const Expanded(child: _ActionButton('Send', 'asset_send')),
        const Expanded(child: _ActionButton('Transfer', 'asset_transfer')),
        const Expanded(child: _ActionButton('Earn', 'asset_earn')),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton(this.label, this.svg, {this.onTap});
  final String label;
  final String svg;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Container(
                height: 41,
                width: 50,
                decoration: BoxDecoration(
                  color: BinancePalette.raised,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: _icon(svg, 23),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                style: const TextStyle(
                  color: _white,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssetCard extends StatelessWidget {
  const _AssetCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: child,
    );
  }
}

class _AllocationCard extends StatelessWidget {
  const _AllocationCard({required this.balance});
  final HomeBalance balance;

  @override
  Widget build(BuildContext context) {
    final allocation = WalletAllocation.fromBalance(balance);

    return _AssetCard(
      child: Column(
        children: [
          Row(
            children: [
              const Text('Allocation', style: TextStyle(
                color: _white,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              )),
              const Spacer(),
              _icon('asset_alloc_filter', 13),
              const SizedBox(width: 8),
              _icon('asset_down', 13),
            ],
          ),
          const SizedBox(height: 11),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 7,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (!allocation.hasValuation) {
                    // No holdings or no KES rates: show a neutral bar,
                    // never fake the mockup's 78/22 allocation.
                    return const ColoredBox(color: BinancePalette.raised);
                  }
                  // Animate changes in either wallet quantity or KES quotes.
                  // BTC occupies the remainder of the bar.
                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0,
                      end: allocation.usdtFraction,
                    ),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    builder: (context, usdtShare, _) {
                      final blueWidth = constraints.maxWidth * usdtShare;
                      return Row(
                        // Without stretch, a childless ColoredBox can shrink to
                        // zero height inside the horizontal allocation Row.
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (blueWidth > 0)
                            SizedBox(
                              width: blueWidth,
                              child: const ColoredBox(
                                key: Key('allocation-usdt-segment'),
                                color: Color(0xFF1E75FF),
                              ),
                            ),
                          if (usdtShare < 1)
                            const Expanded(
                              child: ColoredBox(
                                key: Key('allocation-btc-segment'),
                                color: _yellow,
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
          if (allocation.hasValuation) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const CircleAvatar(
                  radius: 3, backgroundColor: Color(0xFF1E75FF)),
                const SizedBox(width: 5),
                Text(
                  'USDT ${(allocation.usdtFraction * 100).toStringAsFixed(1)}%',
                  key: const Key('allocation-usdt-percentage'),
                  style: const TextStyle(color: _muted, fontSize: 10),
                ),
                const SizedBox(width: 14),
                const CircleAvatar(radius: 3, backgroundColor: _yellow),
                const SizedBox(width: 5),
                Text(
                  'BTC ${(allocation.btcFraction * 100).toStringAsFixed(1)}%',
                  key: const Key('allocation-btc-percentage'),
                  style: const TextStyle(color: _muted, fontSize: 10),
                ),
              ],
            ),
            if (balance.indicativeRates) ...[
              const SizedBox(height: 8),
              const Text(
                'Indicative KES split • live prices unavailable',
                key: Key('allocation-indicative-price-label'),
                style: TextStyle(color: _muted, fontSize: 10),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _BalancesCard extends StatelessWidget {
  const _BalancesCard({required this.balance, required this.quantities});

  final AsyncValue<HomeBalance> balance;
  final HomeBalance quantities;

  @override
  Widget build(BuildContext context) {
    return _AssetCard(
      child: Column(
        children: [
          Row(
            children: [
              const Text('Balance', style: TextStyle(
                color: _white, fontSize: 12.5,
                fontWeight: FontWeight.w500,
              )),
              const Spacer(),
              _icon('asset_balance_filter', 14),
            ],
          ),
          const SizedBox(height: 12),
          _AssetBalanceRow(
            ticker: 'USDT',
            subtitle: 'TetherUS',
            amount: balance.hasError ? '--'
                : formatWalletQuantity(quantities.usdt),
            kes: _kesText(quantities.usdtValueKes),
          ),
          const SizedBox(height: 12),
          const Divider(color: _border, height: 1),
          const SizedBox(height: 12),
          _AssetBalanceRow(
            ticker: 'BTC',
            subtitle: 'Bitcoin',
            amount: balance.hasError ? '--'
                : formatWalletQuantity(quantities.btc),
            kes: _kesText(quantities.btcValueKes),
            pnl: true,
          ),
        ],
      ),
    );
  }

  String _kesText(double value) {
    if (balance.hasError || !quantities.hasValuation) return 'KSh--';
    return 'KSh' + formatWalletMoney(value);
  }
}

class _AssetBalanceRow extends StatelessWidget {
  const _AssetBalanceRow({
    required this.ticker,
    required this.subtitle,
    required this.amount,
    required this.kes,
    this.pnl = false,
  });

  final String ticker;
  final String subtitle;
  final String amount;
  final String kes;
  final bool pnl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/svgs/home_icons/$ticker.png',
                key: ValueKey('assets-coin-icon-$ticker'),
                width: 25,
                height: 25,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ticker, style: const TextStyle(
                    color: _white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  )),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(
                    color: _muted, fontSize: 10.5,
                  )),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(amount, style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                )),
                const SizedBox(height: 3),
                Text(kes, style: const TextStyle(
                  color: _muted, fontSize: 10.5,
                )),
              ],
            ),
          ],
        ),
        if (pnl) ...[
          const SizedBox(height: 10),
          const Row(
            children: [
              Text('Unrealized PNL',
                style: TextStyle(color: _muted, fontSize: 10.5)),
              Spacer(),
              Text('KSh0.00 (0.00%)',
                style: TextStyle(color: _muted, fontSize: 10.5)),
            ],
          ),
        ],
        const SizedBox(height: 9),
        const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _ActionChip('Earn'),
            SizedBox(width: 8),
            _ActionChip('Trade'),
          ],
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _border,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14, vertical: 6,
      ),
      child: Text(text, style: const TextStyle(
        color: Colors.white,
        fontSize: 10.5,
        fontWeight: FontWeight.w500,
      )),
    );
  }
}
