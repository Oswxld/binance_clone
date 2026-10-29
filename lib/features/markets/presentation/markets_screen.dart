import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/binance_palette.dart';

/// Static Markets mockup matching the supplied HTML.
/// Market quotations, filters and search are placeholders for this iteration.
class MarketsScreen extends StatelessWidget {
  const MarketsScreen({super.key});

  static const _background = BinancePalette.canvas;
  static const _secondary = BinancePalette.textMuted;
  static const _primary = BinancePalette.textPrimary;
  static const _yellow = BinancePalette.yellow;
  static const _chip = BinancePalette.raised;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _background,
      child: Column(
        children: [
            const _MarketSearchHeader(),
            const _CategoryTabs(),
            const _TradingTypeTabs(),
            const _MarketFilters(),
            const _MarketTableHeading(),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: _coins.length,
                separatorBuilder: (_, __) => const Divider(
                  color: BinancePalette.divider,
                  height: 1,
                  thickness: 1,
                ),
                itemBuilder: (context, index) => _MarketCoinRow(
                  coin: _coins[index],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _marketSvg(String asset, double size) {
  return SvgPicture.asset(
    'assets/svgs/' + asset + '.svg',
    width: size,
    height: size,
  );
}

class _MarketSearchHeader extends StatelessWidget {
  const _MarketSearchHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 9, 16, 9),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: BinancePalette.raised,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  _marketSvg('markets_search', 16),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Search coins and trends',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: MarketsScreen._secondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          _marketSvg('markets_more', 20),
        ],
      ),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: BinancePalette.divider)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _tab('For You'),
            const SizedBox(width: 24),
            _tab('Favorites'),
            const SizedBox(width: 24),
            _tab('Crypto', active: true),
            const SizedBox(width: 24),
            _tab('TradFi', newDot: true),
            const SizedBox(width: 24),
            _tab('Alpha'),
            const SizedBox(width: 24),
            _tab('Prediction'),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, {bool active = false, bool newDot = false}) {
    return SizedBox(
      height: 39,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: TextStyle(
                  fontSize: 14,
                  color: active
                      ? MarketsScreen._primary
                      : MarketsScreen._secondary,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                )),
                if (newDot) ...[
                  const SizedBox(width: 2),
                  Transform.translate(
                    offset: const Offset(0, -6),
                    child: const CircleAvatar(
                      radius: 3,
                      backgroundColor: MarketsScreen._yellow,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (active)
            const Positioned(
              bottom: 0,
              child: SizedBox(
                width: 16,
                height: 3,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: MarketsScreen._yellow,
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TradingTypeTabs extends StatelessWidget {
  const _TradingTypeTabs();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 15, 16, 11),
      child: Row(
        children: [
          Text('Spot', style: TextStyle(
            color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold,
          )),
          SizedBox(width: 20),
          Text('USDⓈ-M', style: TextStyle(
            color: MarketsScreen._secondary, fontSize: 13,
            fontWeight: FontWeight.w600,
          )),
          SizedBox(width: 20),
          Text('COIN-M', style: TextStyle(
            color: MarketsScreen._secondary, fontSize: 13,
            fontWeight: FontWeight.w600,
          )),
          SizedBox(width: 20),
          Text('Options', style: TextStyle(
            color: MarketsScreen._secondary, fontSize: 13,
            fontWeight: FontWeight.w600,
          )),
        ],
      ),
    );
  }
}

class _MarketFilters extends StatelessWidget {
  const _MarketFilters();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: BinancePalette.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: MarketsScreen._chip,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('All', style: TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    )),
                  ),
                  const SizedBox(width: 10),
                  _filter('bStocks'),
                  const SizedBox(width: 10),
                  _filter('tCommodities'),
                  const SizedBox(width: 10),
                  _filter('Solana'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 1, height: 15, color: BinancePalette.border,
          ),
          const SizedBox(width: 8),
          const Text('USDT', style: TextStyle(
            color: MarketsScreen._primary,
            fontSize: 11, fontWeight: FontWeight.w600,
          )),
          const SizedBox(width: 4),
          _marketSvg('markets_chevron', 10),
          const SizedBox(width: 10),
          _marketSvg('markets_list', 16),
        ],
      ),
    );
  }

  Widget _filter(String label) {
    return Text(label, style: const TextStyle(
      color: MarketsScreen._secondary,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    ));
  }
}

class _MarketTableHeading extends StatelessWidget {
  const _MarketTableHeading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text('Name ↕ / Vol ↕', style: TextStyle(
              color: MarketsScreen._secondary, fontSize: 10,
            )),
          ),
          Expanded(
            flex: 4,
            child: Text('Last Price ↕',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: MarketsScreen._secondary, fontSize: 10,
              )),
          ),
          Expanded(
            flex: 3,
            child: Text('24h Chg ↕',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: MarketsScreen._secondary, fontSize: 10,
              )),
          ),
        ],
      ),
    );
  }
}

class _MarketCoin {
  const _MarketCoin({
    required this.ticker,
    required this.name,
    required this.volume,
    required this.price,
    required this.priceKes,
    required this.change,
    this.leverage = '10x',
  });

  final String ticker;
  final String name;
  final String volume;
  final String price;
  final String priceKes;
  final String change;
  final String leverage;

  bool get up => change.startsWith('+');
}

const _coins = <_MarketCoin>[
  _MarketCoin(ticker: 'USDC', name: 'USDC', volume: '1.48B',
      price: '1.00079', priceKes: 'KSh 130.1', change: '-0.02%'),
  _MarketCoin(ticker: 'BTC', name: 'Bitcoin', volume: '949.98M',
      price: '80,752.77', priceKes: 'KSh 10,497,860.1',
      change: '+0.18%'),
  _MarketCoin(ticker: 'ETH', name: 'Ethereum', volume: '341.18M',
      price: '2,342.18', priceKes: 'KSh 304,483.39', change: '-0.22%'),
  _MarketCoin(ticker: 'SOL', name: 'Solana', volume: '152.60M',
      price: '101.43', priceKes: 'KSh 13,185.9', change: '+0.55%'),
  _MarketCoin(ticker: 'ZEC', name: 'Zcash', volume: '125.59M',
      price: '1,279.99', priceKes: 'KSh 166,398.7', change: '-1.40%'),
  _MarketCoin(ticker: 'USD1', name: 'World Liberty Fi...', volume: '111.38M',
      price: '1.00019', priceKes: 'KSh 130.02', change: '+0.01%',
      leverage: '5x'),
  _MarketCoin(ticker: 'XRP', name: 'XRP', volume: '101.20M',
      price: '1.3185', priceKes: 'KSh 171.4', change: '-0.14%'),
  _MarketCoin(ticker: 'PEPE', name: 'Pepe', volume: '88.58M',
      price: '0.00000487', priceKes: 'KSh 0.0006331', change: '+8.71%',
      leverage: '5x'),
  _MarketCoin(ticker: 'BNB', name: 'BNB', volume: '88.08M',
      price: '748.02', priceKes: 'KSh 97,242.59', change: '-0.22%'),
  _MarketCoin(ticker: 'NEAR', name: 'NEAR', volume: '84.12M',
      price: '4.597', priceKes: 'KSh 597.6', change: '-0.80%',
      leverage: '5x'),
];

class _MarketCoinRow extends StatelessWidget {
  const _MarketCoinRow({required this.coin});

  final _MarketCoin coin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Row(
              children: [
                _icon(),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(coin.ticker,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('/ USDT', style: TextStyle(
                            color: MarketsScreen._secondary, fontSize: 10,
                          )),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 3, vertical: 1),
                            decoration: BoxDecoration(
                              color: BinancePalette.raised,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(coin.leverage, style: const TextStyle(
                              color: MarketsScreen._secondary, fontSize: 9,
                            )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Flexible(
                            child: Text(coin.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: MarketsScreen._secondary,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(coin.volume, style: const TextStyle(
                            color: MarketsScreen._secondary, fontSize: 10,
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(coin.price,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(coin.priceKes,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: MarketsScreen._secondary,
                        fontSize: 10,
                      )),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                constraints: const BoxConstraints(minWidth: 64),
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: coin.up
                      ? BinancePalette.green
                      : BinancePalette.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(coin.change,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _icon() {
    return ClipOval(
      child: Image.asset(
        'assets/svgs/market_icons/${coin.ticker}.png',
        key: ValueKey('markets-coin-icon-${coin.ticker}'),
        width: 24,
        height: 24,
        fit: BoxFit.cover,
      ),
    );
  }
}
