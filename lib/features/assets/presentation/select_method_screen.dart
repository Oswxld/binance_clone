import 'package:flutter/material.dart';

import '../../../core/theme/binance_palette.dart';
import 'choose_network_screen.dart';

/// Deposit/purchase method selection, styled after the provided Stitch mockup.
///
/// This is a presentation step. Selecting a method does not initiate a
/// transfer, payment, wallet address generation, or balance update.
class SelectMethodScreen extends StatelessWidget {
  const SelectMethodScreen({super.key});

  void _unavailable(BuildContext context, String title) {
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
          children: [
            const _MethodSectionHeading('Deposit from Wallet'),
              const SizedBox(height: 11),
              _MethodCard(
                title: 'Deposit Asset',
                description:
                    'Deposit Crypto from other exchanges/wallets to Binance',
                icon: Icons.account_balance_wallet_outlined,
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ChooseNetworkScreen(
                        assetSymbol: 'USDT',
                      ),
                    ),
                  ),
              ),
              const SizedBox(height: 12),
              _MethodCard(
                title: 'Receive Via Binance Pay',
                description: 'Receive crypto from other Binance users',
                icon: Icons.qr_code_2_rounded,
                onTap: () => _unavailable(context, 'Receive Via Binance Pay'),
              ),
              const SizedBox(height: 25),
              const _MethodSectionHeading('Purchase Crypto'),
              const SizedBox(height: 11),
              _MethodCard(
                title: 'P2P Trading',
                description:
                    'Buy crypto via Bank Transfer, Mobile Payment and more',
                icon: Icons.people_outline_rounded,
                onTap: () => _unavailable(context, 'P2P Trading'),
              ),
              const SizedBox(height: 12),
              _MethodCard(
                title: 'Buy with KES',
                description:
                    'Buy crypto with Card, Apple Pay, Google Pay, and more',
                icon: Icons.credit_card_outlined,
                onTap: () => _unavailable(context, 'Buy with KES'),
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
