import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/binance_palette.dart';

/// Deposit/purchase method selection, styled after the provided Stitch mockup.
///
/// This is a presentation step. Selecting a method does not initiate a
/// transfer, payment, wallet address generation, or balance update.
class SelectMethodScreen extends StatefulWidget {
  const SelectMethodScreen({
    super.key,
    this.showUsdtEntryAnimation = false,
  });

  /// The entry animation is *only* requested by tapping USDT.
  /// Opening this screen normally never creates a loading overlay.
  final bool showUsdtEntryAnimation;

  @override
  State<SelectMethodScreen> createState() => _SelectMethodScreenState();
}

class _SelectMethodScreenState extends State<SelectMethodScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _equalizerController;
  Timer? _loadingTimer;
  late bool _showLoading;

  @override
  void initState() {
    super.initState();
    _showLoading = widget.showUsdtEntryAnimation;
    _equalizerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (_showLoading) {
      _equalizerController.repeat();
      _loadingTimer = Timer(
        const Duration(milliseconds: 3200),
        _dismissLoading,
      );
    }
  }

  void _dismissLoading() {
    if (!mounted || !_showLoading) return;
    _loadingTimer?.cancel();
    _equalizerController.stop();
    setState(() => _showLoading = false);
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _equalizerController.dispose();
    super.dispose();
  }

  void _unavailable(String title) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: BinancePalette.raised,
          duration: const Duration(seconds: 2),
          content: Text(
            '$title is not configured yet.',
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
        backgroundColor: BinancePalette.canvas,
        foregroundColor: BinancePalette.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 52,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back, size: 23),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Select Method',
          style: TextStyle(
            color: BinancePalette.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // Actual Android system bars are provided by the OS, not the HTML.
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
              children: [
                const _MethodSectionHeading('Deposit from Wallet'),
                const SizedBox(height: 11),
                _MethodCard(
                  title: 'Deposit Asset',
                  description:
                      'Deposit Crypto from other exchanges/wallets to Binance',
                  icon: Icons.account_balance_wallet_outlined,
                  onTap: () => _unavailable('Deposit Asset'),
                ),
                const SizedBox(height: 12),
                _MethodCard(
                  title: 'Receive Via Binance Pay',
                  description: 'Receive crypto from other Binance users',
                  icon: Icons.qr_code_2_rounded,
                  onTap: () => _unavailable('Receive Via Binance Pay'),
                ),
                const SizedBox(height: 25),
                const _MethodSectionHeading('Purchase Crypto'),
                const SizedBox(height: 11),
                _MethodCard(
                  title: 'P2P Trading',
                  description:
                      'Buy crypto via Bank Transfer, Mobile Payment and more',
                  icon: Icons.people_outline_rounded,
                  onTap: () => _unavailable('P2P Trading'),
                ),
                const SizedBox(height: 12),
                _MethodCard(
                  title: 'Buy with KES',
                  description:
                      'Buy crypto with Card, Apple Pay, Google Pay, and more',
                  icon: Icons.credit_card_outlined,
                  onTap: () => _unavailable('Buy with KES'),
                ),
              ],
            ),

            // The HTML equalizer is a centered floating tile, not a full-page
            // loader. It is placed ON this route after USDT is tapped and fades
            // away after 3.2 seconds (or immediately when the user dismisses).
            // Only the little tile captures taps, not the entire screen.
            if (widget.showUsdtEntryAnimation)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: !_showLoading,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: _showLoading
                        ? Center(
                            key: const Key('usdt-loading-toast'),
                            child: GestureDetector(
                              onTap: _dismissLoading,
                              child: _EqualizerToast(
                                animation: _equalizerController,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(
                            key: Key('usdt-loading-dismissed'),
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MethodSectionHeading extends StatelessWidget {
  const _MethodSectionHeading(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: BinancePalette.textMuted,
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF242932),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 17,
          ),
          child: Row(
            children: [
              // The supplied HTML leaves the artwork empty. Use compact
              // native icons rather than adding large invented illustrations.
              SizedBox(
                width: 38,
                height: 38,
                child: Center(
                  child: Icon(
                    icon,
                    size: 26,
                    color: BinancePalette.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: BinancePalette.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        color: BinancePalette.textMuted,
                        fontSize: 11.5,
                        height: 1.3,
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

/// Faithful native Flutter counterpart of four staggered yellow HTML bars.
class _EqualizerToast extends StatelessWidget {
  const _EqualizerToast({required this.animation});
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('usdt-equalizer-tile'),
      width: 56,
      height: 56,
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
            width: 24,
            height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var index = 0; index < 4; index++) ...[
                  if (index > 0) const SizedBox(width: 3),
                  _animatedBar(index),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _animatedBar(int index) {
    // Four 1-second cycles offset by 0/150/300/450 ms, just like the CSS
    // animation-delay values. Each bar pulses between 6 and 18 pixels.
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
