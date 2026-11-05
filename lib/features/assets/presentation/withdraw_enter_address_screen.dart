import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/binance_palette.dart';
import 'withdraw_enter_amount_screen.dart';

class WithdrawEnterAddressScreen extends StatefulWidget {
  const WithdrawEnterAddressScreen({super.key});

  @override
  State<WithdrawEnterAddressScreen> createState() => _AddressState();
}

class _AddressState extends State<WithdrawEnterAddressScreen> {
  final addressController = TextEditingController();
  bool get hasAddress => addressController.text.trim().isNotEmpty;

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  Future<void> pasteAddress() async {
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted || clipboard?.text == null) return;
    final value = clipboard!.text!.trim();
    addressController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    setState(() {});
  }

  void continueToAmount() {
    if (!hasAddress) return;
    FocusScope.of(context).unfocus();
    Navigator.push(context, MaterialPageRoute<void>(
      builder: (_) => WithdrawEnterAmountScreen(
        address: addressController.text.trim(),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: BinancePalette.canvas,
    appBar: AppBar(
      backgroundColor: BinancePalette.canvas,
      foregroundColor: BinancePalette.textPrimary,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      title: const Text('Enter address', style: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w600)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context)),
      actions: [
        IconButton(
          onPressed: () => FocusScope.of(context).unfocus(),
          icon: const Icon(Icons.help_outline_rounded)),
        IconButton(
          onPressed: () => FocusScope.of(context).unfocus(),
          icon: const Icon(Icons.history)),
      ],
    ),
    body: SafeArea(top: false, bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(19, 12, 19, 24),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          Align(alignment: Alignment.centerLeft,
            child: Container(
              key: const Key('withdraw-network-indicator'),
              decoration: BoxDecoration(
                color: BinancePalette.surface,
                borderRadius: BorderRadius.circular(22)),
              padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 9),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (hasAddress)
                  Container(
                    height: 18, width: 18, padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEB3B5A), shape: BoxShape.circle),
                    child: SvgPicture.asset('assets/svgs/network_trx.svg'))
                else
                  const Icon(Icons.public,
                    color: BinancePalette.textMuted, size: 17),
                const SizedBox(width: 8),
                Text(hasAddress ? 'TRC20 (TRX)' : 'Select Network',
                  style: TextStyle(
                    color: hasAddress
                      ? BinancePalette.textPrimary
                      : BinancePalette.textMuted,
                    fontSize: 12, fontWeight: FontWeight.w600)),
              ]),
            )),
          const SizedBox(height: 31),
          TextField(
            key: const Key('withdraw-address-input'),
            controller: addressController,
            autofocus: true,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            minLines: 1,
            maxLines: 3,
            onChanged: (_) => setState(() {}),
            cursorColor: BinancePalette.yellow,
            style: const TextStyle(color: BinancePalette.textPrimary,
              fontSize: 22, fontWeight: FontWeight.w600, height: 1.35),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Address',
              hintStyle: TextStyle(color: BinancePalette.textDisabled,
                fontSize: 33, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 17),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _QuickChip('Address book', Icons.contacts_outlined,
              () => FocusScope.of(context).unfocus()),
            _QuickChip('Paste', Icons.content_paste, pasteAddress),
            _QuickChip('Scan', Icons.qr_code_scanner, () {}),
            if (hasAddress) _QuickChip('Clear', Icons.close, () {
              addressController.clear();
              setState(() {});
            }),
          ]),
          const SizedBox(height: 34),
          const Divider(color: BinancePalette.divider),
          const SizedBox(height: 17),
          const Text('Recent Withdrawals',
            style: TextStyle(color: BinancePalette.textPrimary,
              fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 15),
          InkWell(
            key: const Key('withdraw-sample-address'),
            onTap: () {
              const value = 'TRf4Bmb9TZtzAU3oUoFb3pLoCLSQcv4kBi';
              addressController.value = TextEditingValue(
                text: value,
                selection: TextSelection.collapsed(offset: value.length));
              setState(() {});
            },
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TRf4Bmb9TZtzAU3oUoFb3pLoCLSQcv4kBi',
                  style: TextStyle(color: BinancePalette.textPrimary,
                    fontSize: 13)),
                SizedBox(height: 8),
                Text('TRX', style: TextStyle(
                  color: BinancePalette.yellow, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: SafeArea(top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
        child: SizedBox(height: 49,
          child: FilledButton(
            key: const Key('withdraw-address-next'),
            onPressed: hasAddress ? continueToAmount : null,
            style: FilledButton.styleFrom(
              backgroundColor: BinancePalette.yellow,
              foregroundColor: BinancePalette.canvas,
              disabledBackgroundColor: const Color(0xFF534928),
              disabledForegroundColor: const Color(0xFF8C7A39)),
            child: const Text('Next'),
          )),
      ),
    ),
  );
}

class _QuickChip extends StatelessWidget {
  const _QuickChip(this.label, this.icon, this.onPressed);
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => ActionChip(
    label: Text(label),
    avatar: Icon(icon, size: 15, color: BinancePalette.textSecondary),
    onPressed: onPressed,
    side: BorderSide.none,
    backgroundColor: BinancePalette.surface,
    labelStyle: const TextStyle(
      color: BinancePalette.textSecondary, fontSize: 12),
  );
}
