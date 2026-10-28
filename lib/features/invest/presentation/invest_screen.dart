import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Presentation-only values from the supplied Invest mockup.
// Earn products, crypto quotes, and stocks are static examples for now.
const _background = Color(0xFF181A20);
const _card = Color(0xFF1E2026);
const _muted = Color(0xFF848E9C);
const _white = Color(0xFFEAECEF);
const _green = Color(0xFF0ECB81);
const _red = Color(0xFFF6465D);

Widget _investSvg(String name, double size) => SvgPicture.asset(
      'assets/svgs/' + name + '.svg',
      width: size,
      height: size,
    );

class InvestScreen extends StatelessWidget {
  const InvestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _background,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
        children: const [
          Padding(
            padding: EdgeInsets.fromLTRB(4, 0, 4, 14),
            child: Text(
              'Invest',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),
          _EarnCard(),
          SizedBox(height: 16),
          _HotCryptoCard(),
          SizedBox(height: 16),
          _StocksCard(),
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.chevron = true});
  final String title;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(
          color: _muted,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        )),
        if (chevron) ...[
          const Spacer(),
          _investSvg('invest_earn_chevron', 16),
        ],
      ],
    );
  }
}

class _EarnCard extends StatelessWidget {
  const _EarnCard();

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeading(title: 'Earn'),
          const SizedBox(height: 13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('KSh126.84', style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Est. Total Value', style: TextStyle(
                          color: _muted, fontSize: 12,
                        )),
                        const SizedBox(width: 6),
                        _investSvg('invest_eye', 14),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('KSh0.00', style: TextStyle(
                    color: _muted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  )),
                  SizedBox(height: 4),
                  Text('Last Day PNL', style: TextStyle(
                    color: _muted, fontSize: 12,
                  )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 23),
          const _EarnAssetRow(
            ticker: 'USDC',
            apr: '5.03%',
            iconColor: Color(0xFF2775CA),
            isUsdc: true,
          ),
          const SizedBox(height: 20),
          const _EarnAssetRow(
            ticker: 'U',
            apr: '6.12%',
            iconColor: Color(0xFF121214),
            isUsdc: false,
          ),
        ],
      ),
    );
  }
}

class _EarnAssetRow extends StatelessWidget {
  const _EarnAssetRow({
    required this.ticker,
    required this.apr,
    required this.iconColor,
    required this.isUsdc,
  });

  final String ticker;
  final String apr;
  final Color iconColor;
  final bool isUsdc;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconColor,
            shape: BoxShape.circle,
            border: isUsdc ? null : Border.all(
              color: const Color(0xFF3B414D),
            ),
          ),
          child: Text(
            isUsdc ? String.fromCharCode(36) : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ticker, style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              )),
              const SizedBox(height: 3),
              const Text('Bonus', style: TextStyle(
                color: _green,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              )),
            ],
          ),
        ),
        Column(
          children: [
            Text(apr, style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            )),
            const SizedBox(height: 3),
            const Text('APR', style: TextStyle(
              color: _muted,
              fontSize: 10,
            )),
          ],
        ),
        const SizedBox(width: 18),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13, vertical: 9,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF2B313A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('Subscribe', style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          )),
        ),
      ],
    );
  }
}

class _HotCryptoCard extends StatelessWidget {
  const _HotCryptoCard();

  @override
  Widget build(BuildContext context) {
    return const _CardShell(
      child: Column(
        children: [
          _SectionHeading(title: 'Hot Crypto'),
          SizedBox(height: 14),
          _QuotesHeading(showName: false, rightHeading: '24h Change'),
          SizedBox(height: 15),
          _QuoteRow(
            symbol: 'BNB',
            description: 'BNB',
            price: '748.41',
            priceKes: 'KSh97,293.30',
            change: '-0.15%',
            iconColor: Color(0xFFF3BA2F),
            svg: 'invest_bnb',
          ),
          SizedBox(height: 18),
          _QuoteRow(
            symbol: 'BTC',
            description: 'Bitcoin',
            price: '80,794.00',
            priceKes: 'KSh10,503,220.00',
            change: '+0.24%',
            iconColor: Color(0xFFF7931A),
            glyph: '₿',
          ),
          SizedBox(height: 18),
          _QuoteRow(
            symbol: 'ETH',
            description: 'Ethereum',
            price: '2,343.67',
            priceKes: 'KSh304,677.10',
            change: '-0.15%',
            iconColor: Color(0xFF627EEA),
            svg: 'invest_eth',
          ),
        ],
      ),
    );
  }
}

class _StocksCard extends StatelessWidget {
  const _StocksCard();

  @override
  Widget build(BuildContext context) {
    return const _CardShell(
      child: Column(
        children: [
          _SectionHeading(title: 'Stocks', chevron: false),
          SizedBox(height: 15),
          _QuotesHeading(showName: true, rightHeading: 'Change(%)'),
          SizedBox(height: 15),
          _QuoteRow(
            symbol: 'META',
            description: 'Meta Platforms, I...',
            price: '610.35',
            priceKes: 'KSh79,345.24',
            change: '-1.49%',
            iconColor: Colors.white,
            svg: 'invest_meta',
          ),
          SizedBox(height: 18),
          _QuoteRow(
            symbol: 'MU',
            description: 'Micron Technolo...',
            price: '967.89',
            priceKes: 'KSh125,825.57',
            change: '+4.30%',
            iconColor: Color(0xFF002D62),
            glyph: 'Micron',
          ),
        ],
      ),
    );
  }
}

class _QuotesHeading extends StatelessWidget {
  const _QuotesHeading({
    required this.showName,
    required this.rightHeading,
  });
  final bool showName;
  final String rightHeading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: showName
              ? const Text('Name', style: TextStyle(
                  fontSize: 11, color: _muted,
                ))
              : const SizedBox.shrink(),
        ),
        const SizedBox(
          width: 96,
          child: Text(
            'Last Price',
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 11, color: _muted),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 72,
          child: Text(
            rightHeading,
            textAlign: TextAlign.right,
            maxLines: 1,
            style: const TextStyle(fontSize: 11, color: _muted),
          ),
        ),
      ],
    );
  }
}

class _QuoteRow extends StatelessWidget {
  const _QuoteRow({
    required this.symbol,
    required this.description,
    required this.price,
    required this.priceKes,
    required this.change,
    required this.iconColor,
    this.svg,
    this.glyph,
  });

  final String symbol;
  final String description;
  final String price;
  final String priceKes;
  final String change;
  final Color iconColor;
  final String? svg;
  final String? glyph;

  @override
  Widget build(BuildContext context) {
    final rising = change.startsWith('+');

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              _AssetIcon(
                symbol: symbol,
                color: iconColor,
                svg: svg,
                glyph: glyph,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(symbol, style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    )),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        SizedBox(
          width: 96,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                priceKes,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 72,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: rising ? _green : _red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8, horizontal: 3,
              ),
              child: Text(
                change,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AssetIcon extends StatelessWidget {
  const _AssetIcon({
    required this.symbol,
    required this.color,
    this.svg,
    this.glyph,
  });

  final String symbol;
  final Color color;
  final String? svg;
  final String? glyph;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: svg != null
          ? Padding(
              padding: const EdgeInsets.all(6),
              child: _investSvg(svg!, 20),
            )
          : Text(
              glyph ?? symbol.substring(0, 1),
              style: TextStyle(
                color: symbol == 'MU'
                    ? const Color(0xFF00A1E0)
                    : Colors.white,
                fontSize: symbol == 'MU' ? 8 : 17,
                fontWeight: FontWeight.bold,
                fontStyle: symbol == 'BTC'
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
    );
  }
}
