import 'package:flutter/material.dart';

import '../../../core/theme/binance_palette.dart';
import 'send_recipient_screen.dart';

/// Send flow step 2. Separate from Add Funds > Select Method.
class SendSelectMethodScreen extends StatelessWidget {
  const SendSelectMethodScreen({super.key, required this.asset});
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BinancePalette.canvas,
      appBar: AppBar(
        backgroundColor: BinancePalette.canvas,
        foregroundColor: BinancePalette.textPrimary,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text('Select Method',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(top: false, child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 20),
        children: [
          const Text('Withdraw to Wallet',
            style: TextStyle(color: BinancePalette.textSecondary,
              fontSize: 13)),
          const SizedBox(height: 12),
          _SendMethodTile(
            key: const Key('send-to-binance-users'),
            icon: Icons.north_east_rounded,
            title: 'Send to Binance users',
            subtitle: 'Binance internal transfer, send via Email/Phone/ID',
            onTap: () => Navigator.push(context, MaterialPageRoute<void>(
              builder: (_) => SendRecipientScreen(asset: asset))),
          ),
          const SizedBox(height: 28),
          const Text('Sell Crypto',
            style: TextStyle(color: BinancePalette.textSecondary,
              fontSize: 13)),
          const SizedBox(height: 12),
          _SendMethodTile(
            icon: Icons.payments_outlined,
            title: 'Sell to KES',
            subtitle: 'Sell crypto easily to your account.',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sell to KES is not available yet.'))),
          ),
        ],
      )),
    );
  }
}
class _SendMethodTile extends StatelessWidget {
  const _SendMethodTile({super.key, required this.icon, required this.title,
    required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: BinancePalette.surface,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        child: Row(children: [
          SizedBox(width: 43, height: 43,
            child: Icon(icon, size: 30, color: BinancePalette.yellow)),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(
                color: BinancePalette.textPrimary,
                fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(
                color: BinancePalette.textMuted,
                fontSize: 11.5, height: 1.3)),
            ],
          )),
        ]),
      ),
    ),
  );
}
