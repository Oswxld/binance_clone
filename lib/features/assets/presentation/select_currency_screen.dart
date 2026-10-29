import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/binance_palette.dart';
import 'select_method_screen.dart';

/// Visual catalog from the supplied Select Currency mockup. This is the
/// starting point of Add Funds, not a deposit-processing implementation.
class SelectCurrencyScreen extends StatefulWidget {
  const SelectCurrencyScreen({super.key});

  @override
  State<SelectCurrencyScreen> createState() => _SelectCurrencyScreenState();
}

class _SelectCurrencyScreenState extends State<SelectCurrencyScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _numericKey = GlobalKey();
  final GlobalKey _letterAKey = GlobalKey();
  String _search = '';
  late final AnimationController _equalizerController;
  bool _isUsdtLoading = false;

  static const _indexLetters = <String>[
    '1', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K',
    'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W',
    'X', 'Y', 'Z', '市', '牛',
  ];

  @override
  void initState() {
    super.initState();
    _equalizerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
  }

  @override
  void dispose() {
    // Prevent any pending ticker completion from navigating after disposal.
    _isUsdtLoading = false;
    _equalizerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openUsdtMethod() {
    // Display the four-bar loading tile ON Select Currency first.
    // Prevent repeated taps from starting overlapping route transitions.
    if (_isUsdtLoading) return;
    FocusScope.of(context).unfocus();
    setState(() => _isUsdtLoading = true);
    // Play exactly one 850 ms cycle; navigate only when it completes.
    // No arbitrary 3.2-second delay and no animation on Select Method.
    _equalizerController.forward(from: 0).whenCompleteOrCancel(() {
      if (!mounted || !_isUsdtLoading) return;
      setState(() => _isUsdtLoading = false);
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const SelectMethodScreen(),
        ),
      );
    });
  }

  List<_CurrencyOption> _matching(List<_CurrencyOption> group) {
    final query = _search.trim().toLowerCase();
    if (query.isEmpty) return group;
    return group.where((currency) {
      return currency.symbol.toLowerCase().contains(query) ||
          currency.name.toLowerCase().contains(query);
    }).toList();
  }

  void _jumpTo(String letter) {
    final key = switch (letter) {
      '1' => _numericKey,
      'A' => _letterAKey,
      _ => null,
    };
    if (key == null) return;
    final target = key.currentContext;
    if (target == null) return;
    FocusScope.of(context).unfocus();
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: 0.02,
    );
  }

  void _onCurrencySelected(_CurrencyOption currency) {
    FocusScope.of(context).unfocus();
    if (currency.symbol == 'USDT') {
      _openUsdtMethod();
      return;
    }
    if (_isUsdtLoading) return;
    // Other currencies are not wired to funding yet. Never mutate holdings
    // or pretend that a deposit succeeded.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: BinancePalette.raised,
        content: Text(
          '${currency.symbol} funding is not configured yet.',
          style: const TextStyle(color: BinancePalette.textPrimary),
        ),
        duration: const Duration(seconds: 2),
      ));
  }

  List<Widget> _section(
    String title,
    List<_CurrencyOption> options, {
    Key? titleKey,
  }) {
    if (options.isEmpty) return const [];
    return [
      Padding(
        key: titleKey,
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
        child: Text(
          title,
          style: const TextStyle(
            color: BinancePalette.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      for (final option in options)
        _CurrencyRow(
          key: ValueKey('currency-${option.symbol}'),
          currency: option,
          onTap: () => _onCurrencySelected(option),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final trending = _matching(_trending);
    final numbers = _matching(_numbers);
    final letters = _matching(_letterA);
    final searching = _search.trim().isNotEmpty;
    final empty = trending.isEmpty && numbers.isEmpty && letters.isEmpty;

    return Scaffold(
      backgroundColor: BinancePalette.canvas,
      appBar: AppBar(
        backgroundColor: BinancePalette.canvas,
        foregroundColor: BinancePalette.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 51,
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back, size: 23),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Select Currency',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: BinancePalette.textPrimary,
          ),
        ),
      ),
      // AppBar already protects the Android status bar. This SafeArea
      // protects the device's actual gesture/navigation region only.
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: BinancePalette.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: TextField(
                  key: const Key('currency-search'),
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onChanged: (value) => setState(() => _search = value),
                  style: const TextStyle(
                    color: BinancePalette.textPrimary,
                    fontSize: 13,
                  ),
                  cursorColor: BinancePalette.yellow,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.search,
                      color: BinancePalette.textMuted,
                      size: 19,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 41,
                      minHeight: 40,
                    ),
                    hintText: 'Search Coins',
                    hintStyle: const TextStyle(
                      color: BinancePalette.textMuted,
                      fontSize: 13,
                    ),
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    suffixIcon: searching
                        ? IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _search = '');
                            },
                            icon: const Icon(
                              Icons.close,
                              color: BinancePalette.textMuted,
                              size: 17,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  // Only 17 demo entries: build section anchors eagerly so
                  // alphabet shortcuts can reliably reach even offscreen rows.
                  SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      16, 0, searching ? 16 : 34, 24,
                    ),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!empty) ...[
                          ..._section('Trending', trending),
                          ..._section(
                            '1', numbers,
                            titleKey: searching ? null : _numericKey,
                          ),
                          ..._section(
                            'A', letters,
                            titleKey: searching ? null : _letterAKey,
                          ),
                        ] else
                          const Padding(
                            padding: EdgeInsets.only(top: 65),
                            child: Center(
                              child: Text(
                                'No matching currencies',
                                style: TextStyle(
                                  color: BinancePalette.textMuted,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!searching)
                    Positioned(
                      right: 2,
                      top: 9,
                      bottom: 14,
                      child: SizedBox(
                        width: 27,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (final letter in _indexLetters)
                              SizedBox(
                                height: 13,
                                child: InkWell(
                                  onTap: (letter == '1' || letter == 'A')
                                      ? () => _jumpTo(letter)
                                      : null,
                                  borderRadius: BorderRadius.circular(3),
                                  child: Center(
                                    child: Text(
                                      letter,
                                      style: TextStyle(
                                        color: letter == '1' || letter == 'A'
                                            ? BinancePalette.textSecondary
                                            : BinancePalette.textMuted,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w400,
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
              ],
            ),
            if (_isUsdtLoading)
              Positioned.fill(
                child: Stack(
                  children: [
                    // Block other currency taps while the brief transition
                    // plays, without painting a full-screen dark scrim.
                    const ModalBarrier(
                      dismissible: false,
                      color: Colors.transparent,
                    ),
                    Center(
                      child: Semantics(
                        key: const Key('usdt-loading-toast'),
                        label: 'Opening USDT deposit methods',
                        liveRegion: true,
                        child: _EqualizerToast(
                          animation: _equalizerController,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyOption {
  const _CurrencyOption({
    required this.symbol,
    required this.name,
    required this.background,
    this.glyph,
    this.iconAsset,
    this.glyphColor = Colors.white,
    this.moneyBadge = false,
    this.roundIcon = true,
    this.glyphSize = 14,
  });

  final String symbol;
  final String name;
  final Color background;
  final String? glyph;
  final String? iconAsset;
  final Color glyphColor;
  final bool moneyBadge;
  final bool roundIcon;
  final double glyphSize;
}

const _trending = <_CurrencyOption>[
  _CurrencyOption(
    symbol: 'USD', name: 'USD', background: BinancePalette.yellow,
    glyph: r'$', glyphColor: BinancePalette.canvas, moneyBadge: true,
    glyphSize: 18,
  ),
  _CurrencyOption(
    symbol: 'EUR', name: 'Euro', background: Color(0xFF0052FF),
    glyph: '€', moneyBadge: true, glyphSize: 18,
  ),
  _CurrencyOption(
    symbol: 'BTC', name: 'Bitcoin', background: Color(0xFFF7931A),
    glyph: '₿', glyphSize: 20,
  ),
  _CurrencyOption(
    symbol: 'ETH', name: 'Ethereum', background: Color(0xFF627EEA),
    iconAsset: 'invest_eth',
  ),
  _CurrencyOption(
    symbol: 'USDT', name: 'TetherUS', background: Color(0xFF009393),
    iconAsset: 'asset_usdt',
  ),
  _CurrencyOption(
    symbol: 'BNB', name: 'BNB', background: Color(0xFFF3BA2F),
    iconAsset: 'currency_bnb',
  ),
];

const _numbers = <_CurrencyOption>[
  _CurrencyOption(
    symbol: 'OG', name: 'OG', background: Color(0xFF5C1A72),
    glyph: 'OG', glyphSize: 11,
  ),
  _CurrencyOption(
    symbol: '1000CAT', name: '1000*Simons Cat',
    background: Color(0xFFE52D27), glyph: '🐱', glyphSize: 16,
  ),
  _CurrencyOption(
    symbol: '1000CHEEMS', name: '1000*cheems.pet',
    background: Color(0xFF3D2914), glyph: '🐕', glyphSize: 17,
  ),
  _CurrencyOption(
    symbol: '1000PEPPER', name: 'PEPPER',
    background: Color(0xFFF59E0B), glyph: '🎃', glyphSize: 18,
  ),
  _CurrencyOption(
    symbol: '1000SATS', name: '1000*SATS (Ordinals)',
    background: Color(0xFFF59E0B), glyph: r'$', glyphSize: 17,
  ),
  _CurrencyOption(
    symbol: '1INCH', name: '1inch',
    background: Color(0xFF0B0E14), iconAsset: 'currency_1inch',
    roundIcon: false,
  ),
  _CurrencyOption(
    symbol: '1MBABYDOGE', name: '1M x BABY DOGE',
    background: BinancePalette.yellow, glyph: '🐶', glyphSize: 18,
  ),
  _CurrencyOption(
    symbol: '2Z', name: 'DoubleZero', background: Colors.white,
    glyph: '2Z', glyphColor: Color(0xFF4F46E5), glyphSize: 12,
  ),
];

const _letterA = <_CurrencyOption>[
  _CurrencyOption(
    symbol: 'A', name: 'Vaulta', background: Color(0xFF2445FC),
    iconAsset: 'currency_vaulta',
  ),
  _CurrencyOption(
    symbol: 'AAOIB', name: 'Applied Optoelectronics (bStocks)',
    background: BinancePalette.textPrimary, glyph: 'AOI',
    glyphColor: BinancePalette.surface, glyphSize: 10,
  ),
  _CurrencyOption(
    symbol: 'AAPLB', name: 'Apple (bStocks)',
    background: Color(0xFF0D0E12), iconAsset: 'currency_apple',
    roundIcon: false,
  ),
];

class _CurrencyRow extends StatelessWidget {
  const _CurrencyRow({
    super.key,
    required this.currency,
    required this.onTap,
  });

  final _CurrencyOption currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: currency.background,
                shape: currency.roundIcon
                    ? BoxShape.circle
                    : BoxShape.rectangle,
                borderRadius: currency.roundIcon
                    ? null
                    : BorderRadius.circular(7),
              ),
              child: currency.iconAsset != null
                  ? SvgPicture.asset(
                      'assets/svgs/${currency.iconAsset}.svg',
                      width: 18, height: 18,
                    )
                  : Text(
                      currency.glyph ?? currency.symbol.substring(0, 1),
                      maxLines: 1,
                      style: TextStyle(
                        color: currency.glyphColor,
                        fontWeight: FontWeight.w600,
                        fontSize: currency.glyphSize,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          currency.symbol,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: BinancePalette.textPrimary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                      if (currency.moneyBadge) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF332A15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Money',
                            style: TextStyle(
                              fontSize: 9.5,
                              color: Color(0xFFD89F0E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    currency.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: BinancePalette.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Four staggered yellow bars from the supplied loading animation.
///
/// This tile exists ONLY on Select Currency while a USDT tap is transitioning
/// to Select Method. No animation is rendered on the destination screen.
class _EqualizerToast extends StatelessWidget {
  const _EqualizerToast({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('usdt-equalizer-tile'),
      height: 56,
      width: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xF22E3440),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x1AFFFFFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x59000000),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          return SizedBox(
            height: 20,
            width: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var index = 0; index < 4; index++) ...[
                  if (index > 0) const SizedBox(width: 3),
                  _bar(index),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _bar(int index) {
    final phase = (animation.value - index * 0.15) * 2 * math.pi;
    final wave = (1 - math.cos(phase)) / 2;
    return Container(
      width: 3.5,
      height: 6 + 12 * wave,
      decoration: BoxDecoration(
        color: BinancePalette.yellow.withValues(
          alpha: 0.65 + 0.35 * wave,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
