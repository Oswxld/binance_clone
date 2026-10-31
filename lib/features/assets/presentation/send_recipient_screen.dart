import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/binance_palette.dart';
import 'send_amount_screen.dart';

/// Step 3: recipient input. Any non-empty numeric Binance ID is accepted in
/// this demo; no account look-up, recipient credit or real-money transfer.
class SendRecipientScreen extends StatefulWidget {
  const SendRecipientScreen({super.key, required this.asset});

  final String asset;

  @override
  State<SendRecipientScreen> createState() => _SendRecipientScreenState();
}

class _SendRecipientScreenState extends State<SendRecipientScreen> {
  final TextEditingController _id = TextEditingController();
  bool _emailPhoneTab = false;

  @override
  void dispose() {
    _id.dispose();
    super.dispose();
  }

  void _continue() {
    final recipient = _id.text.trim();
    if (recipient.isEmpty) return;
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => SendAmountScreen(
        asset: widget.asset,
        recipient: recipient,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _id.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: BinancePalette.canvas,
      appBar: AppBar(
        backgroundColor: BinancePalette.canvas,
        foregroundColor: BinancePalette.textPrimary,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Recurring Send (not available)',
            icon: const Icon(Icons.event_repeat_outlined, size: 20),
            onPressed: () => _unavailable(),
          ),
          TextButton(
            onPressed: _unavailable,
            child: const Text('Recurring Send', style: TextStyle(
              color: BinancePalette.textSecondary, fontSize: 10)),
          ),
          TextButton(
            onPressed: _unavailable,
            child: const Text('Deferred Send', style: TextStyle(
              color: BinancePalette.textSecondary, fontSize: 10)),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            const Text('Send to Binance User', style: TextStyle(
              color: BinancePalette.textPrimary,
              fontSize: 23, fontWeight: FontWeight.w700)),
            const SizedBox(height: 25),
            Row(children: [
              _tab('Email / Phone', true),
              const SizedBox(width: 10),
              _tab('Binance ID', false),
            ]),
            const SizedBox(height: 17),
            TextField(
              key: const Key('send-recipient-id'),
              controller: _id,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              style: const TextStyle(
                fontSize: 15, color: BinancePalette.textPrimary),
              decoration: InputDecoration(
                hintText: _emailPhoneTab
                    ? 'Enter phone number'
                    : 'Enter Binance user account',
                hintStyle: const TextStyle(color: BinancePalette.textDisabled),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 17, horizontal: 15),
                filled: true,
                fillColor: BinancePalette.surface,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(9)),
              ),
            ),
            const SizedBox(height: 11),
            Text(
              _emailPhoneTab
                ? 'Enter any phone number for this demo.'
                : 'Binance ID can be found under App Home - Profile. '
                  'Any number works for this demo.',
              style: const TextStyle(
                color: BinancePalette.textMuted,
                height: 1.5,
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: 19),
            SizedBox(
              height: 49,
              child: ElevatedButton(
                key: const Key('send-recipient-continue'),
                onPressed: enabled ? _continue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BinancePalette.yellow,
                  disabledBackgroundColor: const Color(0xFF54461B),
                  disabledForegroundColor: const Color(0xFF8E7A33),
                  foregroundColor: BinancePalette.canvas,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9)),
                ),
                child: const Text('Continue',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 34),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent', style: TextStyle(
                  color: BinancePalette.textPrimary,
                  fontSize: 14, fontWeight: FontWeight.w600)),
                Text('Demo', style: TextStyle(
                  color: BinancePalette.yellow,
                  fontSize: 12, fontWeight: FontWeight.w600)),
              ]),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => setState(() => _id.text = '1255361535'),
              child: Row(children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: BinancePalette.raised,
                    borderRadius: BorderRadius.circular(9)),
                  child: const Icon(Icons.person_outline,
                    color: BinancePalette.textPrimary),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sample Recipient', style: TextStyle(
                      color: BinancePalette.textPrimary,
                      fontWeight: FontWeight.w600, fontSize: 13)),
                    SizedBox(height: 3),
                    Text('1255361535 (example Binance ID)',
                      style: TextStyle(
                        color: BinancePalette.textMuted, fontSize: 11)),
                  ],
                ),
              ]),
            ),
            const SizedBox(height: 30),
            const Text(
              'DEMO ONLY • Recipient IDs are not checked against Binance. '
              'No recipient will receive any assets.',
              style: TextStyle(
                color: BinancePalette.textMuted, fontSize: 10.5,
                height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab(String name, bool emailPhone) {
    final active = _emailPhoneTab == emailPhone;
    return InkWell(
      onTap: () => setState(() {
        _emailPhoneTab = emailPhone;
        _id.clear();
      }),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? BinancePalette.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: active
              ? Border.all(color: BinancePalette.border)
              : null,
        ),
        child: Text(name, style: TextStyle(
          color: active ? BinancePalette.textPrimary : BinancePalette.textMuted,
          fontSize: 12, fontWeight: active ? FontWeight.w600 : FontWeight.w500,
        )),
      ),
    );
  }

  void _unavailable() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Scheduled transfers are not available in this demo.'),
    ));
  }
}
