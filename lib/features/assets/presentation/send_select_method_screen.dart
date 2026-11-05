import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/binance_palette.dart';
import 'send_recipient_screen.dart';
import 'withdraw_enter_address_screen.dart';

/// Send > Select Method. Keep this separate from the Add Funds method list.
class SendSelectMethodScreen extends StatelessWidget {
  const SendSelectMethodScreen({super.key, required this.asset});

  final String asset;

  void _unavailable(BuildContext context, String method) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$method is not available yet.')));
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
        title: const Text('Select Method', style: TextStyle(
          fontSize: 17, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 26),
          children: [
            const Text('Withdraw to Wallet', style: TextStyle(
              color: BinancePalette.textMuted,
              fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 13),
            _MethodCard(
              key: const Key('withdraw-asset-method'),
              title: 'Withdraw Asset',
              subtitle: 'Withdraw Crypto from Binance to other exchanges/wallets',
              icon: 'assets/svgs/withdraw.svg',
              badge: 'Last Used',
              onTap: () => Navigator.push(context, MaterialPageRoute<void>(
                builder: (_) => const WithdrawEnterAddressScreen())),
            ),
            const SizedBox(height: 12),
            _MethodCard(
              key: const Key('send-to-binance-users'),
              title: 'Send to Binance users',
              subtitle: 'Binance internal transfer, send via Email/Phone/ID',
              icon: 'assets/svgs/send.svg',
              onTap: () => Navigator.push(context, MaterialPageRoute<void>(
                builder: (_) => SendRecipientScreen(asset: asset))),
            ),
            const SizedBox(height: 12),
            _MethodCard(
              title: 'Withdraw to Binance Wallet',
              subtitle: 'Withdraw your asset to your Binance wallet',
              icon: 'assets/svgs/asset_transfer.svg',
              onTap: () => _unavailable(context, 'Withdraw to Binance Wallet'),
            ),
            const SizedBox(height: 30),
            const Text('Sell Crypto', style: TextStyle(
              color: BinancePalette.textMuted,
              fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 13),
            _MethodCard(
              title: 'Sell to KES',
              subtitle: 'Sell crypto easily to your account.',
              materialIcon: Icons.payments_outlined,
              onTap: () => _unavailable(context, 'Sell to KES'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.icon,
    this.materialIcon,
    this.badge,
  });

  final String title;
  final String subtitle;
  final String? icon;
  final IconData? materialIcon;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BinancePalette.surface,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 45, height: 47,
                  child: Center(
                    child: icon != null
                        ? SvgPicture.asset(icon!,
                            width: 37, height: 37)
                        : Icon(materialIcon,
                            size: 35, color: BinancePalette.textSecondary),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(child: Padding(
                  padding: EdgeInsets.only(
                    top: 2, right: badge == null ? 0 : 44),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(
                        color: BinancePalette.textPrimary,
                        fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 5),
                      Text(subtitle, style: const TextStyle(
                        color: BinancePalette.textMuted,
                        fontSize: 11.5, height: 1.35)),
                    ],
                  ),
                )),
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              top: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9, vertical: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFF3A3319),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(13),
                    bottomLeft: Radius.circular(9))),
                child: Text(badge!, style: const TextStyle(
                  color: BinancePalette.yellow,
                  fontSize: 10.5, fontWeight: FontWeight.w500)),
              ),
            ),
        ]),
      ),
    );
  }
}
