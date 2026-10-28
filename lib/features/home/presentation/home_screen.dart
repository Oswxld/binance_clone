import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../domain/home_balance.dart';
import 'home_provider.dart';

// Exact source palette from the supplied Tailwind design.
const _bg = Color(0xFF181A20);
const _card = Color(0xFF202630);
const _border = Color(0xFF2B313A);
const _yellow = Color(0xFFFCD535);
const _green = Color(0xFF0ECB81);
const _red = Color(0xFFF6465D);
const _muted = Color(0xFF848E9C);
const _white = Colors.white;

Widget _svg(String name, double size) =>
    SvgPicture.asset('assets/svgs/' + name + '.svg', width: size, height: size);

String _money(double value) {
  final parts = value.toStringAsFixed(2).split('.');
  var whole = parts.first;
  final groups = <String>[];
  while (whole.length > 3) {
    groups.insert(0, whole.substring(whole.length - 3));
    whole = whole.substring(0, whole.length - 3);
  }
  groups.insert(0, whole);
  return groups.join(',') + '.' + parts.last;
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(homeBalanceProvider);

    return ColoredBox(
      color: _bg,
      child: Stack(
        children: [
            Column(
              children: [
                const _TopNavigation(),
                Expanded(
                  child: RefreshIndicator(
                    color: _yellow,
                    backgroundColor: _card,
                    onRefresh: () async {
                      ref.invalidate(homeBalanceProvider);
                      try {
                        await ref.read(homeBalanceProvider.future);
                      } catch (_) {
                        // AsyncValue handles and displays the error.
                      }
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _TrendingSearch(),
                          const SizedBox(height: 18),
                          _BalanceSection(
                            balance: balance,
                            retry: () => ref.invalidate(homeBalanceProvider),
                          ),
                          const SizedBox(height: 18),
                          const _QuickActions(),
                          const SizedBox(height: 16),
                          const _RewardsCard(),
                          const SizedBox(height: 16),
                          const _DepositMethod(),
                          const SizedBox(height: 16),
                          const _MarketsSection(),
                          const SizedBox(height: 18),
                          const _CommunityTabs(),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Positioned(
              right: 0,
              bottom: 18,
              child: _AssistantBubble(),
            ),
        ],
      ),
    );
  }
}

class _TopNavigation extends StatelessWidget {
  const _TopNavigation();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 9, 16, 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF262626),
                  border: Border.all(color: const Color(0xFF404040)),
                  shape: BoxShape.circle,
                ),
                child: _svg('avatar', 16),
              ),
              const SizedBox(width: 12),
              _svg('support', 20),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Text('Exchange',
                      style: TextStyle(color: _white, fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  child: Text('Wallet',
                      style: TextStyle(color: _muted, fontSize: 12)),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _svg('scan', 20),
              const SizedBox(width: 14),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _svg('notifications', 20),
                  Positioned(
                    right: -10,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 3, vertical: 1),
                      decoration: BoxDecoration(
                        color: _yellow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('99+',
                          style: TextStyle(color: _bg, fontSize: 9,
                              fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendingSearch extends StatelessWidget {
  const _TrendingSearch();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 37,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _svg('search', 16),
          const SizedBox(width: 9),
          const Text('🔥', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          const Flexible(
            child: Text('ETC is trending now',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: _muted, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _BalanceSection extends StatelessWidget {
  const _BalanceSection({required this.balance, required this.retry});

  final AsyncValue<HomeBalance> balance;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) {
    final totalText = balance.when(
      data: (value) => 'KSh' + _money(value.totalKes),
      loading: () => 'KSh...',
      error: (error, stack) => 'KSh--',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Est. Total Value(KES)',
                style: TextStyle(color: _muted, fontSize: 12)),
            const SizedBox(width: 5),
            _svg('balance_chevron', 14),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                totalText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: _yellow,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Text('Add Funds',
                  style: TextStyle(color: _bg, fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Text("Today's PNL",
                style: TextStyle(color: _muted, fontSize: 12)),
            const SizedBox(width: 6),
            const Text('-KSh2.39 (-0.62%)',
                style: TextStyle(color: _red, fontSize: 12,
                    fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            _svg('pnl_down', 12),
          ],
        ),
        if (balance.hasError) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: retry,
            child: const Text(
              'Could not load balance or live KES prices. Tap to retry.',
              style: TextStyle(color: _red, fontSize: 11),
            ),
          ),
        ],
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _QuickAction(label: 'Send', icon: 'send')),
        SizedBox(width: 10),
        Expanded(child: _QuickAction(label: 'Buy/Sell', icon: 'buy_sell')),
        SizedBox(width: 10),
        Expanded(child: _QuickAction(label: 'Withdraw', icon: 'withdraw')),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.label, required this.icon});

  final String label;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 43,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _svg(icon, 16),
          const SizedBox(width: 7),
          Flexible(
            child: Text(label, maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Color(0xFFE5E5E5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _RewardsCard extends StatelessWidget {
  const _RewardsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Get Rewards',
                  style: TextStyle(color: _muted, fontSize: 13,
                      fontWeight: FontWeight.w500)),
              const Spacer(),
              _svg('dismiss', 14),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFF03A66D),
                  shape: BoxShape.circle,
                ),
                child: _svg('rewards', 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Trade 10 USDT to get 2 USDT Token Voucher',
                    style: TextStyle(color: _white, fontSize: 12,
                        fontWeight: FontWeight.w600, height: 1.3)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Go',
                    style: TextStyle(color: _white, fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _pageDot(false), const SizedBox(width: 4),
              _pageDot(false), const SizedBox(width: 4),
              _pageDot(true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pageDot(bool active) => Container(
    width: active ? 14 : 6,
    height: 5,
    decoration: BoxDecoration(
      color: active ? _white : const Color(0xFF52525B),
      borderRadius: BorderRadius.circular(3),
    ),
  );
}

class _DepositMethod extends StatelessWidget {
  const _DepositMethod();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 192,
      height: 144,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20, height: 20,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: _yellow, shape: BoxShape.circle),
                child: Text(String.fromCharCode(36),
                    style: TextStyle(color: _bg, fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 6),
              const Text('USD',
                  style: TextStyle(color: Color(0xFFD4D4D4), fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            color: const Color(0xFF113B30),
            child: const Text('Deposit',
                style: TextStyle(color: _green, fontSize: 10)),
          ),
          const SizedBox(height: 4),
          const Text('Bank Transfer (SWIFT)',
              style: TextStyle(color: _white, fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const Spacer(),
          Row(
            children: [
              _svg('bank', 20),
              const Spacer(),
              Container(width: 12, height: 4,
                  decoration: BoxDecoration(color: _white,
                      borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 4),
              Container(width: 4, height: 4,
                  decoration: BoxDecoration(color: _muted,
                      borderRadius: BorderRadius.circular(4))),
            ],
          ),
        ],
      ),
    );
  }
}

class _MarketsSection extends StatelessWidget {
  const _MarketsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 9),
            child: Row(
              children: [
                _marketTab('Favorites'),
                const SizedBox(width: 12),
                const Column(
                  children: [
                    Text('Hot', style: TextStyle(
                        color: _white, fontSize: 13,
                        fontWeight: FontWeight.w700)),
                    SizedBox(height: 4),
                    SizedBox(width: 24, height: 2,
                        child: ColoredBox(color: _yellow)),
                  ],
                ),
                const SizedBox(width: 12),
                _marketTab('TradFi'),
                const SizedBox(width: 12),
                _marketTab('Alpha'),
                const SizedBox(width: 12),
                _marketTab('New'),
                const Spacer(),
                _svg('filter', 16),
              ],
            ),
          ),
          const Divider(color: _border, height: 1),
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              children: [
                Text('Crypto',
                  style: TextStyle(color: _white, fontSize: 12,
                      fontWeight: FontWeight.bold)),
                SizedBox(width: 16),
                Text('Futures',
                    style: TextStyle(color: _muted, fontSize: 12)),
                SizedBox(width: 16),
                Text('Stocks',
                    style: TextStyle(color: _muted, fontSize: 12)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 1, 12, 7),
            child: Row(
              children: [
                Expanded(child: Text('Name',
                    style: TextStyle(color: _muted, fontSize: 11))),
                Expanded(child: Text('Last Price',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: _muted, fontSize: 11))),
                Expanded(child: Text('24h chg%',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: _muted, fontSize: 11))),
              ],
            ),
          ),
          const _MarketRow(
            name: 'BNB', caption: 'BNB', icon: 'bnb', emoji: '🔥',
            iconBg: _yellow, price: '751.79',
            kes: 'KSh 97,785.33', change: '+0.49%',
          ),
          const _MarketRow(
            name: 'BTC', caption: 'Bitcoin', symbol: '₿', emoji: '🔥',
            iconBg: Color(0xFFF7931A), price: '81,147.38',
            kes: 'KSh 10,554,839.72', change: '+0.65%',
          ),
          const _MarketRow(
            name: 'ETH', caption: 'Ethereum', icon: 'eth', emoji: '🔥',
            iconBg: Color(0xFF627EEA), price: '2,357.43',
            kes: 'KSh 306,630.92', change: '+0.69%',
          ),
          const _MarketRow(
            name: 'PEPE', caption: 'Pepe', symbol: '🐸',
            iconBg: Color(0xFF398039), price: '0.00000489',
            kes: 'KSh 0.00063604', change: '+9.15%',
          ),
          const _MarketRow(
            name: 'SOL', caption: 'Solana', icon: 'sol',
            iconBg: Color(0xFF141414), price: '102.12',
            kes: 'KSh 13,282.75', change: '+1.03%',
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('View More',
                style: TextStyle(color: _muted, fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _marketTab(String title) => Text(
    title,
    style: const TextStyle(color: _muted, fontSize: 11.5,
        fontWeight: FontWeight.w500),
  );
}

class _MarketRow extends StatelessWidget {
  const _MarketRow({
    required this.name,
    required this.caption,
    required this.iconBg,
    required this.price,
    required this.kes,
    required this.change,
    this.icon,
    this.symbol,
    this.emoji,
  });

  final String name;
  final String caption;
  final String? icon;
  final String? symbol;
  final String? emoji;
  final Color iconBg;
  final String price;
  final String kes;
  final String change;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 25,
                  height: 25,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconBg,
                    border: name == 'SOL'
                        ? Border.all(color: _border) : null,
                  ),
                  child: icon != null
                      ? _svg(icon!, 15)
                      : Text(symbol ?? name.substring(0, 1),
                          style: const TextStyle(
                              color: _white, fontSize: 13,
                              fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: _white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                          ),
                          if (emoji != null) ...[
                            const SizedBox(width: 3),
                            Text(emoji!, style: const TextStyle(fontSize: 11)),
                          ],
                        ],
                      ),
                      Text(caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: _muted, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price, maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFFF1F1F1),
                        fontSize: 12.5, fontWeight: FontWeight.w600)),
                Text(kes, maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _muted, fontSize: 10)),
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                constraints: const BoxConstraints(minWidth: 64),
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 7),
                decoration: BoxDecoration(
                  color: _green,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(change,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black,
                        fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityTabs extends StatelessWidget {
  const _CommunityTabs();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Discover',
            style: TextStyle(color: _muted, fontSize: 12)),
        const SizedBox(width: 15),
        const Text('Following',
            style: TextStyle(color: _white, fontSize: 13,
                fontWeight: FontWeight.w700)),
        const SizedBox(width: 15),
        const Text('Stocks',
            style: TextStyle(color: _muted, fontSize: 12)),
        const SizedBox(width: 15),
        const Text('Leaderboard',
            style: TextStyle(color: _muted, fontSize: 12)),
        const Spacer(),
        _svg('feed_expand', 14),
      ],
    );
  }
}

class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 29,
      height: 29,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: _yellow,
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(20),
        ),
      ),
      child: const Text('😊', style: TextStyle(fontSize: 12)),
    );
  }
}
