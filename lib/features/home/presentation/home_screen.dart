import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/utils/wallet_amount_formatter.dart';
import '../../../core/theme/binance_palette.dart';
import '../domain/home_balance.dart';
import '../domain/wallet_display_currency.dart';
import 'display_currency_picker.dart';
import 'home_provider.dart';

// One shared Binance Classic-inspired palette across all tabs.
const _bg = BinancePalette.canvas;
const _card = BinancePalette.surface;
const _border = BinancePalette.border;
const _yellow = BinancePalette.yellow;
const _green = BinancePalette.green;
const _red = BinancePalette.red;
const _muted = BinancePalette.textMuted;
const _white = BinancePalette.textPrimary;

Widget _svg(String name, double size) =>
    SvgPicture.asset('assets/svgs/' + name + '.svg', width: size, height: size);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, this.onSignOut});

  final Future<void> Function()? onSignOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(homeBalanceProvider);

    return ColoredBox(
      color: _bg,
      child: Stack(
        children: [
            Column(
              children: [
                _TopNavigation(onSignOut: onSignOut),
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
        ],
      ),
    );
  }
}

class _TopNavigation extends StatelessWidget {
  const _TopNavigation({this.onSignOut});

  final Future<void> Function()? onSignOut;

  Future<void> _confirmSignOut(BuildContext context) async {
    if (onSignOut == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: BinancePalette.surface,
        title: const Text('Sign out?'),
        content: const Text('You can sign back in to view your wallet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true) await onSignOut!();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 9, 16, 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                key: const Key('home-account-avatar'),
                onTap: onSignOut == null
                    ? null
                    : () => _confirmSignOut(context),
                child: Tooltip(
                  message: onSignOut == null ? 'Account' : 'Account / Sign out',
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: BinancePalette.raised,
                      border: Border.all(color: BinancePalette.border),
                      shape: BoxShape.circle,
                    ),
                    child: _svg('avatar', 16),
                  ),
                ),
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

class _TrendingSearch extends StatefulWidget {
  const _TrendingSearch();

  @override
  State<_TrendingSearch> createState() => _TrendingSearchState();
}

class _TrendingSearchState extends State<_TrendingSearch> {
  // UI sample headlines; these are not a live news feed.
  static const _headlines = <String>[
    '🔥 ETC is trending now',
    'FECEx beats Q4',
    '📈 Explore today’s market movers',
    '📰 Discover the latest market insights',
  ];

  final PageController _controller = PageController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 3600), (_) {
      if (!mounted || !_controller.hasClients) return;
      _controller.nextPage(
        duration: const Duration(milliseconds: 470),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

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
          Expanded(
            child: ClipRect(
              child: PageView.builder(
                key: const Key('home-news-ticker'),
                controller: _controller,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final headline = _headlines[index % _headlines.length];
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      headline,
                      key: ValueKey('news-headline-$index'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 13,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceSection extends ConsumerWidget {
  const _BalanceSection({required this.balance, required this.retry});

  final AsyncValue<HomeBalance> balance;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(displayCurrencyProvider);
    final totalText = balance.when(
      data: (value) => formatWalletDisplayValue(
        value.valueIn(value.totalKes, currency), currency),
      loading: () => formatWalletDisplayValue(0, currency),
      error: (error, stack) => formatWalletDisplayValue(null, currency),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DisplayCurrencyPicker(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Est. Total Value(${currency.code})',
                  style: const TextStyle(color: _muted, fontSize: 12)),
              const SizedBox(width: 5),
              _svg('balance_chevron', 14),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                totalText,
                key: const Key('home-converted-total'),
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
        if (currency != WalletDisplayCurrency.kes &&
            balance.asData?.value.hasValuation == true) ...[
          const SizedBox(height: 3),
          Text(
            '≈KSh${formatWalletMoney(balance.asData!.value.totalKes)}',
            key: const Key('home-kes-equivalent'),
            style: const TextStyle(color: _muted, fontSize: 12),
          ),
        ],
        const SizedBox(height: 4),
        Row(
          children: [
            const Text("Today's PNL",
                style: TextStyle(color: _muted, fontSize: 12)),
            const SizedBox(width: 6),
            Text(
              currency == WalletDisplayCurrency.kes
                  ? 'KSh0.00 (0.00%)'
                  : '0.00 ${currency.code} (0.00%)',
              style: const TextStyle(color: _muted, fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        if (balance.asData?.value.hasValuation == false) ...[
          const SizedBox(height: 8),
          const Text(
            'Balances updated, but KES rates are unavailable.',
            style: TextStyle(color: _red, fontSize: 11),
          ),
        ],
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
                    color: BinancePalette.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _RewardsCard extends StatefulWidget {
  const _RewardsCard();

  @override
  State<_RewardsCard> createState() => _RewardsCardState();
}

class _RewardsCardState extends State<_RewardsCard> {
  static const _offers = <String>[
    'Trade 10 USDT to get 2 USDT Token Voucher',
    'Trade 10 USDT of bStocks to get 1 USDT Token Voucher',
  ];

  final PageController _controller = PageController();
  Timer? _timer;
  int _selectedPage = 0;
  bool _touching = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 4200), (_) {
      if (!mounted || !_controller.hasClients || _touching) return;
      _controller.animateToPage(
        (_selectedPage + 1) % _offers.length,
        duration: const Duration(milliseconds: 570),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

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
              const Text(
                'Get Rewards',
                style: TextStyle(
                  color: _muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              _svg('dismiss', 14),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 60,
            child: Listener(
              onPointerDown: (_) => _touching = true,
              onPointerUp: (_) => _touching = false,
              onPointerCancel: (_) => _touching = false,
              child: PageView.builder(
                key: const Key('home-rewards-carousel'),
                controller: _controller,
                itemCount: _offers.length,
                onPageChanged: (index) => setState(() {
                  _selectedPage = index;
                }),
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/svgs/home_icons/USDT.png',
                          key: const Key('home-rewards-usdt-icon'),
                          width: 34,
                          height: 34,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _offers[index],
                          key: ValueKey('reward-offer-$index'),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _border,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Go',
                          style: TextStyle(
                            color: _white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var index = 0; index < _offers.length; index++) ...[
                if (index > 0) const SizedBox(width: 5),
                Container(
                  key: ValueKey(
                    'rewards-dot-$index-${_selectedPage == index ? 'active' : 'inactive'}',
                  ),
                  width: _selectedPage == index ? 14 : 6,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _selectedPage == index
                        ? _white
                        : BinancePalette.textDisabled,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DepositMethod extends StatefulWidget {
  const _DepositMethod();

  @override
  State<_DepositMethod> createState() => _DepositMethodState();
}

class _DepositMethodState extends State<_DepositMethod> {
  final PageController _controller = PageController();
  int _selectedPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('home-bank-transfer-card'),
      width: 192,
      height: 190,
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
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: _yellow,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  String.fromCharCode(36),
                  style: const TextStyle(
                    color: _bg,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'USD',
                style: TextStyle(
                  color: BinancePalette.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: PageView(
              key: const Key('home-bank-transfer-carousel'),
              controller: _controller,
              onPageChanged: (index) => setState(() {
                _selectedPage = index;
              }),
              children: const [
                _BankTransferSlide(isWithdraw: false),
                _BankTransferSlide(isWithdraw: true),
              ],
            ),
          ),
          Row(
            children: [
              _svg('bank', 20),
              const Spacer(),
              for (var index = 0; index < 2; index++) ...[
                if (index > 0) const SizedBox(width: 4),
                Container(
                  key: ValueKey(
                    'bank-dot-$index-${_selectedPage == index ? 'active' : 'inactive'}',
                  ),
                  width: _selectedPage == index ? 12 : 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _selectedPage == index ? _white : _muted,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _BankTransferSlide extends StatelessWidget {
  const _BankTransferSlide({required this.isWithdraw});

  final bool isWithdraw;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            key: ValueKey(
              isWithdraw ? 'bank-withdraw-badge' : 'bank-deposit-badge',
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: isWithdraw
                  ? const Color(0xFF3D202A)
                  : const Color(0xFF113B30),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              isWithdraw ? 'Withdraw' : 'Deposit',
              style: TextStyle(
                color: isWithdraw ? _red : _green,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Bank Transfer (SWIFT)',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
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
            name: 'BNB', caption: 'BNB', emoji: '🔥',
            price: '751.79', kes: 'KSh 97,785.33', change: '+0.49%',
          ),
          const _MarketRow(
            name: 'BTC', caption: 'Bitcoin', emoji: '🔥',
            price: '81,147.38', kes: 'KSh 10,554,839.72', change: '+0.65%',
          ),
          const _MarketRow(
            name: 'ETH', caption: 'Ethereum', emoji: '🔥',
            price: '2,357.43', kes: 'KSh 306,630.92', change: '+0.69%',
          ),
          const _MarketRow(
            name: 'PEPE', caption: 'Pepe',
            price: '0.00000489', kes: 'KSh 0.00063604', change: '+9.15%',
          ),
          const _MarketRow(
            name: 'SOL', caption: 'Solana',
            price: '102.12', kes: 'KSh 13,282.75', change: '+1.03%',
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
    required this.price,
    required this.kes,
    required this.change,
    this.emoji,
  });

  final String name;
  final String caption;
  final String? emoji;
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
                ClipOval(
                  child: Image.asset(
                    // PEPE is only provided in market_icons. The other
                    // home market symbols have dedicated home_icons assets.
                    name == 'PEPE'
                        ? 'assets/svgs/market_icons/PEPE.png'
                        : 'assets/svgs/home_icons/$name.png',
                    key: ValueKey('home-coin-icon-$name'),
                    width: 25,
                    height: 25,
                    fit: BoxFit.cover,
                  ),
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
                    style: const TextStyle(color: BinancePalette.textPrimary,
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

