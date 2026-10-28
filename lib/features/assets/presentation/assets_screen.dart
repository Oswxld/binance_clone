import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../home/domain/home_balance.dart';
import '../../home/presentation/home_provider.dart';
import '../../../core/utils/wallet_amount_formatter.dart';

const _bg = Color(0xFF121318);
const _surface = Color(0xFF181A20);
const _border = Color(0xFF23272E);
const _muted = Color(0xFF848E9C);
const _white = Color(0xFFEAECEF);
const _yellow = Color(0xFFFCD535);
const _green = Color(0xFF0ECB81);

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
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
                children: [
                  _PortfolioHeader(balance: balance),
                  const SizedBox(height: 15),
                  const _AssetActions(),
                  const SizedBox(height: 19),
                  _AllocationCard(balance: quantities),
                  const SizedBox(height: 16),
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            if (i != 0) const SizedBox(width: 20),
            SizedBox(
              height: 37,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Text(
                    tabs[i],
                    style: TextStyle(
                      fontSize: i == 0 ? 18 : 17,
                      fontWeight: i == 0
                          ? FontWeight.bold : FontWeight.w500,
                      color: i == 0 ? Colors.white : _muted,
                    ),
                  ),
                  if (i == 0)
                    const Positioned(
                      bottom: 0,
                      child: SizedBox(
                        width: 16,
                        height: 3,
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
              color: _muted, fontSize: 13,
            )),
            const SizedBox(width: 6),
            _icon('asset_eye', 16),
            const Spacer(),
            _icon('asset_history', 20),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                totalText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 29,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            const SizedBox(width: 5),
            const Text('KES', style: TextStyle(
              fontSize: 12, color: _muted,
              fontWeight: FontWeight.w600,
            )),
            const SizedBox(width: 4),
            _icon('asset_currency_chevron', 13),
            const SizedBox(width: 9),
            _icon('asset_sparkline', 90),
          ],
        ),
        const SizedBox(height: 5),
        const Row(
          children: [
            Text("Today's PNL", style: TextStyle(
              fontSize: 12, color: _muted,
            )),
            SizedBox(width: 7),
            Text('KSh0.00 (0.00%)', style: TextStyle(
              fontSize: 12, color: _muted,
              fontWeight: FontWeight.w500,
            )),
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
        const SizedBox(height: 10),
        Center(child: _icon('asset_down_chevron', 15)),
      ],
    );
  }
}

class _AssetActions extends StatelessWidget {
  const _AssetActions();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _ActionButton('Add Funds', 'asset_add_funds')),
        Expanded(child: _ActionButton('Send', 'asset_send')),
        Expanded(child: _ActionButton('Transfer', 'asset_transfer')),
        Expanded(child: _ActionButton('Earn', 'asset_earn')),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton(this.label, this.svg);
  final String label;
  final String svg;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 48,
          width: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF1E2329),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: _icon(svg, 21),
        ),
        const SizedBox(height: 9),
        Text(label,
          maxLines: 1,
          style: const TextStyle(
            color: _white, fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
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
    final total = balance.totalKes;
    final usdtPortion = balance.hasValuation && total > 0
        ? (balance.usdtValueKes / total).clamp(0.0, 1.0).toDouble()
        : 0.0;
    final btcPortion = balance.hasValuation && total > 0
        ? (balance.btcValueKes / total).clamp(0.0, 1.0).toDouble()
        : 0.0;

    return _AssetCard(
      child: Column(
        children: [
          Row(
            children: [
              const Text('Allocation', style: TextStyle(
                color: _white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              )),
              const Spacer(),
              _icon('asset_alloc_filter', 16),
              const SizedBox(width: 10),
              _icon('asset_down', 16),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 8,
              color: const Color(0xFF2B313A),
              child: Row(
                children: [
                  if (usdtPortion > 0)
                    Expanded(
                      flex: (usdtPortion * 10000).round().clamp(1, 10000),
                      child: const ColoredBox(color: Color(0xFF1E75FF)),
                    ),
                  if (btcPortion > 0)
                    Expanded(
                      flex: (btcPortion * 10000).round().clamp(1, 10000),
                      child: const ColoredBox(color: _yellow),
                    ),
                  if (usdtPortion == 0 && btcPortion == 0)
                    const Expanded(child: SizedBox.shrink()),
                ],
              ),
            ),
          ),
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
                color: _white, fontSize: 14,
                fontWeight: FontWeight.w600,
              )),
              const Spacer(),
              _icon('asset_balance_filter', 17),
            ],
          ),
          const SizedBox(height: 18),
          _AssetBalanceRow(
            ticker: 'USDT',
            subtitle: 'TetherUS',
            svg: 'asset_usdt',
            accent: const Color(0xFF009393),
            amount: balance.hasError ? '--'
                : formatWalletQuantity(quantities.usdt),
            kes: _kesText(quantities.usdtValueKes),
          ),
          const SizedBox(height: 18),
          const Divider(color: _border, height: 1),
          const SizedBox(height: 18),
          _AssetBalanceRow(
            ticker: 'BTC',
            subtitle: 'Bitcoin',
            svg: 'asset_btc',
            accent: const Color(0xFFF7931A),
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
    required this.svg,
    required this.accent,
    required this.amount,
    required this.kes,
    this.pnl = false,
  });

  final String ticker;
  final String subtitle;
  final String svg;
  final Color accent;
  final String amount;
  final String kes;
  final bool pnl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              height: 28,
              width: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent,
              ),
              child: _icon(svg, 17),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ticker, style: const TextStyle(
                    color: _white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  )),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(
                    color: _muted, fontSize: 12,
                  )),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(amount, style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                )),
                const SizedBox(height: 4),
                Text(kes, style: const TextStyle(
                  color: _muted, fontSize: 12,
                )),
              ],
            ),
          ],
        ),
        if (pnl) ...[
          const SizedBox(height: 15),
          const Row(
            children: [
              Text('Unrealized PNL',
                style: TextStyle(color: _muted, fontSize: 12)),
              Spacer(),
              Text('KSh0.00 (0.00%)',
                style: TextStyle(color: _muted, fontSize: 12)),
            ],
          ),
        ],
        const SizedBox(height: 12),
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
        horizontal: 19, vertical: 8,
      ),
      child: Text(text, style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      )),
    );
  }
}
