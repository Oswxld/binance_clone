import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/binance_palette.dart';
import '../../../core/utils/wallet_amount_formatter.dart';
import 'withdraw_enter_address_screen.dart';

/// Withdrawal details for the local wallet deduction. The reference is a
/// local UI reference, not a transaction hash from a blockchain network.
class WithdrawalDetailsScreen extends StatelessWidget {
  const WithdrawalDetailsScreen({
    super.key,
    required this.address,
    required this.totalAmount,
    required this.networkFee,
    required this.createdAt,
  });

  final String address;
  final double totalAmount;
  final double networkFee;
  final DateTime createdAt;

  String get _reference =>
      'W' + createdAt.microsecondsSinceEpoch.toRadixString(16).toUpperCase();

  String get _date {
    final d = createdAt.toLocal();
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${pad(d.month)}-${pad(d.day)} '
        '${pad(d.hour)}:${pad(d.minute)}:${pad(d.second)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BinancePalette.canvas,
      appBar: AppBar(
        backgroundColor: BinancePalette.canvas,
        foregroundColor: BinancePalette.textPrimary,
        centerTitle: true,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Withdrawal Details', style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () =>
              Navigator.popUntil(context, (route) => route.isFirst)),
        actions: [
          IconButton(
            tooltip: 'Help',
            icon: const Icon(Icons.support_agent_outlined,
              color: BinancePalette.textMuted),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(19, 25, 19, 26),
          children: [
            Center(child: Text(
              '-${_pretty(totalAmount)} USDT',
              key: const Key('withdraw-details-amount'),
              style: const TextStyle(
                color: BinancePalette.textPrimary,
                fontSize: 33, fontWeight: FontWeight.w700),
            )),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 19,
                  color: BinancePalette.green),
                SizedBox(width: 7),
                Text('Simulated', style: TextStyle(
                  color: BinancePalette.green,
                  fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 14),
            const Text('Wallet balance updated.',
              textAlign: TextAlign.center,
              style: TextStyle(color: BinancePalette.textMuted,
                height: 1.4, fontSize: 12)),
            const SizedBox(height: 43),
            _line('Network', 'TRX', icon: SizedBox(
              width: 17, height: 17,
              child: SvgPicture.asset('assets/svgs/network_trx.svg'))),
            const SizedBox(height: 23),
            _line('Address', address, copy: true),
            const SizedBox(height: 23),
            _line('Reference', _reference, copy: true),
            const SizedBox(height: 23),
            _line('Amount',
              '${_pretty(totalAmount)} USDT'),
            const SizedBox(height: 23),
            _line('Network fee',
              '${_pretty(networkFee)} USDT'),
            const SizedBox(height: 23),
            _line('Withdrawal Wallet', 'Spot Account'),
            const SizedBox(height: 23),
            _line('Date', _date),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 9, 16, 14),
          child: SizedBox(
            height: 49,
            child: FilledButton(
              key: const Key('withdraw-again'),
              onPressed: () =>
                Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
                  builder: (_) => const WithdrawEnterAddressScreen())),
              style: FilledButton.styleFrom(
                backgroundColor: BinancePalette.yellow,
                foregroundColor: BinancePalette.canvas,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9))),
              child: const Text('Withdraw Again',
                style: TextStyle(fontSize: 15,
                  fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    );
  }

  String _pretty(double value) {
    final number = formatWalletQuantity(value);
    return number.replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
  }

  Widget _line(String title, String value, {
    bool copy = false,
    Widget? icon,
  }) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 103,
        child: Text(title, style: const TextStyle(
          color: BinancePalette.textMuted, fontSize: 12.5)),
      ),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            if (icon != null) ...[icon, const SizedBox(width: 7)],
            Flexible(
              child: Text(value,
                key: title == 'Address'
                  ? const Key('withdraw-details-address') : null,
                textAlign: TextAlign.right,
                softWrap: true,
                style: const TextStyle(
                  color: BinancePalette.textPrimary,
                  fontWeight: FontWeight.w500,
                  height: 1.35, fontSize: 12.5)),
            ),
            if (copy)
              IconButton(
                constraints: const BoxConstraints(
                  minWidth: 35, minHeight: 35),
                padding: const EdgeInsets.only(left: 6),
                icon: const Icon(Icons.copy_outlined,
                  size: 15, color: BinancePalette.textMuted),
                onPressed: () => Clipboard.setData(
                  ClipboardData(text: value)),
              ),
          ]),
        ],
      )),
    ],
  );
}
