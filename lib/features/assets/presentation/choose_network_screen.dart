import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/binance_palette.dart';

/// USDT network catalogue matching the supplied Choose Network layout.
/// Names, minimums and arrival times are demo values from the mockup, NOT
/// verified live exchange limits. No deposit address is provided here.
class ChooseNetworkScreen extends StatelessWidget {
  const ChooseNetworkScreen({
    super.key,
    this.assetSymbol = 'USDT',
  });

  final String assetSymbol;

  void _showUnavailable(BuildContext context, _DepositNetwork network) {
    // Never synthesize an address or imply a network deposit was initiated.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: BinancePalette.raised,
          duration: const Duration(seconds: 2),
          content: Text(
            '${network.code} deposits for $assetSymbol are not configured yet.',
            style: const TextStyle(
              color: BinancePalette.textPrimary,
              fontSize: 12,
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BinancePalette.canvas,
      appBar: AppBar(
        title: const Text(
          'Choose Network',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: BinancePalette.textPrimary,
          ),
        ),
        centerTitle: true,
        toolbarHeight: 52,
        backgroundColor: BinancePalette.canvas,
        foregroundColor: BinancePalette.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // No simulated status bar or bottom gesture indicator; the phone
      // already renders those outside Flutter's SafeArea.
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 7, 18, 16),
              child: Text(
                'Please note that only supported networks on Binance '
                'platform are shown, if you deposit via another network '
                'your assets may be lost.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.43,
                  letterSpacing: -0.1,
                  color: BinancePalette.textMuted,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                key: const Key('network-list'),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: _networks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final network = _networks[index];
                  return _NetworkCard(
                    key: ValueKey('network-card-${network.code}'),
                    network: network,
                    assetSymbol: assetSymbol,
                    onTap: () => _showUnavailable(context, network),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepositNetwork {
  const _DepositNetwork({
    required this.code,
    required this.name,
    required this.minimum,
    required this.arrivalMinutes,
    required this.badgeColor,
    this.icon,
    this.iconColor = Colors.white,
    this.badgeBorder,
  });

  final String code;
  final String name;
  final String minimum;
  final int arrivalMinutes;
  final Color badgeColor;
  final String? icon;
  final Color iconColor;
  final Color? badgeBorder;
}

/// Reference presentation data only. Real supported networks and deposit
/// thresholds MUST come from the actual backend before enabling deposits.
const _networks = <_DepositNetwork>[
  _DepositNetwork(
    code: 'BSC', name: 'BNB Smart Chain (BEP20)',
    minimum: '>0.01', arrivalMinutes: 1,
    badgeColor: Color(0xFFF0B90B), icon: 'network_bsc',
  ),
  _DepositNetwork(
    code: 'TRX', name: 'Tron (TRC20)',
    minimum: '>0.01', arrivalMinutes: 1,
    badgeColor: Color(0xFFEB3B5A), icon: 'network_trx',
  ),
  _DepositNetwork(
    code: 'ETH', name: 'Ethereum (ERC20)',
    minimum: '>0.001', arrivalMinutes: 2,
    badgeColor: Color(0xFF627EEA), icon: 'network_eth',
  ),
  _DepositNetwork(
    code: 'POL', name: 'Polygon POS',
    minimum: '>0.02', arrivalMinutes: 1,
    badgeColor: Color(0xFF8247E5), icon: 'network_pol',
  ),
  _DepositNetwork(
    code: 'PLASMA', name: 'Plasma',
    minimum: '>0.000001', arrivalMinutes: 1,
    badgeColor: Color(0xFF0E3528), icon: 'network_plasma',
    badgeBorder: Color(0xFF195942),
  ),
  _DepositNetwork(
    code: 'SOL', name: 'Solana',
    minimum: '>0.001', arrivalMinutes: 1,
    badgeColor: Color(0xFF000000), icon: 'network_sol',
  ),
  _DepositNetwork(
    code: 'APT', name: 'Aptos',
    minimum: '>0.00001', arrivalMinutes: 1,
    badgeColor: Color(0xFF000000),
    badgeBorder: Color(0x334FFFFFF),
  ),
  _DepositNetwork(
    code: 'ARBITRUM', name: 'Arbitrum One',
    minimum: '>0.001', arrivalMinutes: 1,
    badgeColor: Color(0xFF28A0F0), icon: 'network_arbitrum',
  ),
  _DepositNetwork(
    code: 'TON', name: 'The Open Network (TON)',
    minimum: '>0.001', arrivalMinutes: 1,
    badgeColor: Color(0xFF0088CC), icon: 'network_ton',
  ),
  _DepositNetwork(
    code: 'AVAXC', name: 'AVAX C-Chain',
    minimum: '>0.001', arrivalMinutes: 4,
    badgeColor: Color(0xFFE84142), icon: 'network_avaxc',
  ),
  _DepositNetwork(
    code: 'CELO', name: 'CELO',
    minimum: '>0.001', arrivalMinutes: 6,
    badgeColor: Color(0xFFFCFF52), icon: 'network_celo',
  ),
];

class _NetworkCard extends StatelessWidget {
  const _NetworkCard({
    super.key,
    required this.network,
    required this.assetSymbol,
    required this.onTap,
  });

  final _DepositNetwork network;
  final String assetSymbol;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BinancePalette.raised,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: network.badgeColor,
                  shape: BoxShape.circle,
                  border: network.badgeBorder == null
                      ? null
                      : Border.all(color: network.badgeBorder!),
                ),
                alignment: Alignment.center,
                child: network.icon != null
                    ? SvgPicture.asset(
                        'assets/svgs/${network.icon}.svg',
                        width: 16,
                        height: 16,
                      )
                    : const _AptosMark(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 5,
                      runSpacing: 1,
                      children: [
                        Text(
                          network.code,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: BinancePalette.textPrimary,
                          ),
                        ),
                        Text(
                          network.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: BinancePalette.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Min. deposit ${network.minimum} $assetSymbol',
                      style: const TextStyle(
                        fontSize: 11,
                        color: BinancePalette.textMuted,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Est. arrival ${network.arrivalMinutes} '
                      '${network.arrivalMinutes == 1 ? 'min' : 'mins'}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: BinancePalette.textMuted,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Three white horizontal bars from the supplied Aptos badge artwork.
class _AptosMark extends StatelessWidget {
  const _AptosMark();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final width in [14.0, 16.0, 12.0]) ...[
          Container(
            width: width,
            height: 1.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          if (width != 12.0) const SizedBox(height: 2.5),
        ],
      ],
    );
  }
}
