import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/binance_palette.dart';

/// USDT on Tron (TRC20) deposit presentation.
///
/// The HTML reference contains an unverified sample address and a handmade
/// non-QR illustration. We never reuse that unverified address. Instead the
/// screen renders a REAL scannable QR of an unmistakable DEMO message until a
/// verified destination address is supplied by the backend.
class DepositUsdtScreen extends StatelessWidget {
  const DepositUsdtScreen({
    super.key,
    this.trustedDepositAddress,
  });

  /// Only pass a provider-issued, user-associated TRC20 deposit address.
  /// A basic format check prevents accidental placeholder/invalid strings,
  /// but does not verify ownership: the backend must do that.
  final String? trustedDepositAddress;

  static const String demoQrPayload =
      'DEMO ONLY - USDT TRC20 DEPOSIT ADDRESS NOT CONFIGURED';

  String? get _address {
    final value = trustedDepositAddress?.trim();
    if (value == null) return null;
    if (!RegExp(r'^T[1-9A-HJ-NP-Za-km-z]{33}$').hasMatch(value)) {
      return null;
    }
    return value;
  }

  void _message(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          backgroundColor: BinancePalette.raised,
          content: Text(
            message,
            style: const TextStyle(color: BinancePalette.textPrimary),
          ),
        ),
      );
  }

  Future<void> _copyAddress(BuildContext context) async {
    final value = _address;
    if (value == null) {
      _message(context, 'This is a demo QR. No deposit address is configured.');
      return;
    }
    await Clipboard.setData(ClipboardData(text: value));
    if (context.mounted) _message(context, 'Deposit address copied.');
  }

  void _showHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BinancePalette.surface,
        title: const Text(
          'USDT deposit safety',
          style: TextStyle(color: BinancePalette.textPrimary),
        ),
        content: const Text(
          'Use only a verified USDT address on the TRC20 network. '
          'The demo QR on this screen cannot receive funds. '
          'Always verify the destination and network before sending.',
          style: TextStyle(color: BinancePalette.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Got it',
              style: TextStyle(color: BinancePalette.yellow),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final address = _address;
    final isDemo = address == null;
    final qrPayload = address ?? demoQrPayload;

    return Scaffold(
      backgroundColor: BinancePalette.canvas,
      appBar: AppBar(
        backgroundColor: BinancePalette.canvas,
        foregroundColor: BinancePalette.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 54,
        titleSpacing: 0,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
        ),
        title: const Text(
          'Deposit USDT',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: BinancePalette.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Deposit help',
            onPressed: () => _showHelp(context),
            icon: const Icon(Icons.help_outline_rounded, size: 22),
          ),
          IconButton(
            tooltip: 'Deposit records',
            onPressed: () => _message(
              context,
              'Deposit records are not configured yet.',
            ),
            icon: const Icon(Icons.receipt_long_outlined, size: 22),
          ),
          const SizedBox(width: 6),
        ],
      ),
      // Preserve the real Android status/navigation bars; no fake clock or
      // gesture indicator from the reference HTML.
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 7, 14, 18),
                children: [
                  _NetworkSelector(
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 11),
                  _QrAddressCard(
                    address: address,
                    qrPayload: qrPayload,
                    isDemo: isDemo,
                    onCopy: () => _copyAddress(context),
                  ),
                  const SizedBox(height: 17),
                  const _DepositDetails(),
                  const SizedBox(height: 18),
                  const _DepositWarnings(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 8, 15, 10),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton(
                  key: const Key('save-share-address'),
                  onPressed: () => _copyAddress(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: BinancePalette.yellow,
                    foregroundColor: BinancePalette.canvas,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: const Text(
                    'Save and Share Address',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
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

class _NetworkSelector extends StatelessWidget {
  const _NetworkSelector({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BinancePalette.surface,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Network',
                      style: TextStyle(
                        color: BinancePalette.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    SizedBox(height: 4),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 2,
                      children: [
                        Text(
                          'TRX',
                          style: TextStyle(
                            color: BinancePalette.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                        Text(
                          'Tron (TRC20)',
                          style: TextStyle(
                            color: BinancePalette.textMuted,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3),
                    Text(
                      'USDT · TRC20 network',
                      style: TextStyle(
                        color: BinancePalette.textMuted,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 21,
                color: BinancePalette.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QrAddressCard extends StatelessWidget {
  const _QrAddressCard({
    required this.address,
    required this.qrPayload,
    required this.isDemo,
    required this.onCopy,
  });

  final String? address;
  final String qrPayload;
  final bool isDemo;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: BinancePalette.surface,
        border: Border.all(color: BinancePalette.divider),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.fromLTRB(13, 16, 13, 16),
      child: Column(
        children: [
          // Genuine QR code generated by qr_flutter with error correction;
          // Stitch's hand-placed SVG squares could not encode an address.
          Container(
            width: 224,
            height: 224,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(19),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                QrImageView(
                  key: const Key('usdt-deposit-qr'),
                  data: qrPayload,
                  version: QrVersions.auto,
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                  size: 206,
                  padding: const EdgeInsets.all(9),
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
                // Small high-contrast Tether center badge. High QR error
                // correction helps preserve camera readability.
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF009393),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                  child: SvgPicture.asset(
                    'assets/svgs/asset_usdt.svg',
                    width: 18,
                    height: 18,
                  ),
                ),
              ],
            ),
          ),
          if (isDemo) ...[
            const SizedBox(height: 9),
            const Text(
              'DEMO PREVIEW · DO NOT SEND FUNDS',
              key: Key('deposit-demo-warning'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: BinancePalette.yellow,
              ),
            ),
          ],
          const SizedBox(height: 17),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Deposit Address',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: BinancePalette.textMuted,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      address ?? 'Not configured yet',
                      key: const Key('deposit-address-value'),
                      style: TextStyle(
                        fontSize: address == null ? 13 : 13.5,
                        fontWeight: FontWeight.w600,
                        color: address == null
                            ? BinancePalette.textMuted
                            : BinancePalette.textPrimary,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                key: const Key('copy-deposit-address'),
                tooltip: 'Copy deposit address',
                onPressed: onCopy,
                style: IconButton.styleFrom(
                  backgroundColor: BinancePalette.raised,
                  minimumSize: const Size(42, 42),
                ),
                icon: const Icon(
                  Icons.copy_outlined,
                  color: BinancePalette.textSecondary,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DepositDetails extends StatelessWidget {
  const _DepositDetails();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _DetailRow(label: 'Deposit to', value: 'Spot Wallet'),
        _DetailRow(label: 'Minimum deposit', value: '>0.01 USDT'),
        _DetailRow(
          label: 'Credited (Trading enabled)',
          value: '1 Confirmation(s)',
        ),
        _DetailRow(
          label: 'Unlocked (Withdrawal enabled)',
          value: '1 Confirmation(s)',
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: BinancePalette.textMuted,
                fontSize: 11.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: const TextStyle(
              color: BinancePalette.textPrimary,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DepositWarnings extends StatelessWidget {
  const _DepositWarnings();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reference limits and confirmations are illustrative. '
          'Verify live requirements with your wallet provider.',
          style: TextStyle(
            color: BinancePalette.textMuted,
            fontSize: 10.5,
            height: 1.45,
          ),
        ),
        SizedBox(height: 10),
        _WarningLine('Do not transact with sanctioned entities.'),
        _WarningLine('Do not send NFTs to this address.'),
        _WarningLine(
          'Send only USDT over TRC20 to a verified Tron deposit address. '
          'Using another network can result in permanent loss of funds.',
        ),
      ],
    );
  }
}

class _WarningLine extends StatelessWidget {
  const _WarningLine(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(color: BinancePalette.textMuted, fontSize: 12),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: BinancePalette.textMuted,
                fontSize: 10.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
