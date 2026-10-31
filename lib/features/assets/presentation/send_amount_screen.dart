import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/binance_palette.dart';
import '../../../core/utils/wallet_amount_formatter.dart';
import '../../home/domain/home_balance.dart';
import '../../home/presentation/home_provider.dart';
import '../data/demo_send_repository.dart';

/// Step 4: enter amount. The numeric keyboard is the device's real keyboard,
/// not the mock HTML keypad. Confirm is a bottom sheet on this page.
class SendAmountScreen extends ConsumerStatefulWidget {
  const SendAmountScreen({
    super.key,
    required this.asset,
    required this.recipient,
  });

  final String asset;
  final String recipient;

  @override
  ConsumerState<SendAmountScreen> createState() => _SendAmountScreenState();
}

class _SendAmountScreenState extends ConsumerState<SendAmountScreen> {
  final _amount = TextEditingController();
  String _note = '';

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  double? get _parsedAmount => double.tryParse(_amount.text.trim());

  double _available(HomeBalance balance) =>
      widget.asset == 'BTC' ? balance.btc : balance.usdt;

  bool _validAmount(HomeBalance balance) {
    final amount = _parsedAmount;
    return amount != null && amount.isFinite &&
        amount > 0 && amount <= _available(balance) &&
        double.parse(amount.toStringAsFixed(10)) > 0;
  }

  String _approxKes(HomeBalance balance, double amount) {
    if (!balance.hasValuation) return '≈ KSh--';
    final rate = widget.asset == 'BTC'
        ? balance.btcKesRate : balance.usdtKesRate;
    if (!rate.isFinite || rate <= 0) return '≈ KSh--';
    return '≈ KSh' + formatWalletMoney(amount * rate);
  }

  void _setMax(HomeBalance balance) {
    final available = _available(balance);
    final value = available.toStringAsFixed(10);
    final clean = value.replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
    _amount.value = TextEditingValue(
      text: clean,
      selection: TextSelection.collapsed(offset: clean.length),
    );
    setState(() {});
  }

  Future<void> _editNote() async {
    final controller = TextEditingController(text: _note);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: BinancePalette.surface,
        title: const Text('Note to Payee',
          style: TextStyle(color: BinancePalette.textPrimary)),
        content: TextField(
          controller: controller,
          maxLength: 100,
          style: const TextStyle(color: BinancePalette.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Optional demo note',
            hintStyle: TextStyle(color: BinancePalette.textMuted)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Save', style: TextStyle(
              color: BinancePalette.yellow))),
        ],
      ),
    );
    if (result != null && mounted) setState(() => _note = result);
    // Defer disposal: AlertDialog may still finish a transition after pop.
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
  }

  Future<void> _openConfirm(HomeBalance current) async {
    if (!_validAmount(current)) return;
    FocusScope.of(context).unfocus();

    final amount = _parsedAmount!;
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BinancePalette.canvas,
      showDragHandle: true,
      builder: (_) => _ConfirmPaymentSheet(
        asset: widget.asset,
        recipient: widget.recipient,
        amount: amount,
        approximateKes: _approxKes(current, amount),
        note: _note,
        send: () async {
          await ref.read(demoSendRepositoryProvider).deduct(
            asset: widget.asset,
            amount: amount,
          );
          ref.invalidate(homeBalanceProvider);
        },
      ),
    );

    if (result == true && mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
        builder: (_) => DemoSendSuccessScreen(
          asset: widget.asset,
          recipient: widget.recipient,
          amount: amount,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncBalance = ref.watch(homeBalanceProvider);
    final balance = asyncBalance.asData?.value ?? const HomeBalance.zero();
    final available = _available(balance);
    final amount = _parsedAmount ?? 0.0;
    final hasAmount = _amount.text.trim().isNotEmpty;
    final canContinue = !asyncBalance.isLoading &&
        !asyncBalance.hasError && _validAmount(balance);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: BinancePalette.canvas,
      appBar: AppBar(
        backgroundColor: BinancePalette.canvas,
        foregroundColor: BinancePalette.textPrimary,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text('Payee will Receive', style: TextStyle(
          fontSize: 17, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(17, 18, 17, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipOval(child: Image.asset(
                    'assets/svgs/home_icons/' + widget.asset + '.png',
                    width: 23, height: 23,
                  )),
                  const SizedBox(width: 7),
                  Text(widget.asset, style: const TextStyle(
                    color: BinancePalette.textPrimary,
                    fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 11),
              TextField(
                key: const Key('send-amount-input'),
                controller: _amount,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true, signed: false),
                inputFormatters: [TextInputFormatter.withFunction(
                  (oldValue, newValue) {
                    final pattern = RegExp(r'^\d{0,14}(\.\d{0,10})?$');
                    return pattern.hasMatch(newValue.text)
                        ? newValue : oldValue;
                  },
                )],
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() {}),
                textAlign: TextAlign.center,
                cursorColor: BinancePalette.yellow,
                style: TextStyle(
                  color: hasAmount ? BinancePalette.textPrimary
                      : BinancePalette.textMuted,
                  fontSize: 49, fontWeight: FontWeight.w400),
                decoration: const InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(color: BinancePalette.textDisabled),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 7),
                ),
              ),
              const SizedBox(height: 6),
              Text(_approxKes(balance, amount), style: const TextStyle(
                color: BinancePalette.textMuted, fontSize: 12)),
              const SizedBox(height: 27),
              Container(
                padding: const EdgeInsets.fromLTRB(13, 14, 13, 14),
                decoration: BoxDecoration(
                  color: BinancePalette.surface,
                  borderRadius: BorderRadius.circular(13)),
                child: Column(children: [
                  _details('Balance', formatWalletQuantity(available) +
                    ' ' + widget.asset, trailing: TextButton(
                      key: const Key('send-max'),
                      onPressed: asyncBalance.isLoading
                          ? null : () => _setMax(balance),
                      child: const Text('Max', style: TextStyle(
                        color: BinancePalette.yellow, fontSize: 12)),
                    )),
                  const SizedBox(height: 13),
                  _details('Max Sendable Balance',
                    formatWalletQuantity(available) + ' ' + widget.asset),
                  const SizedBox(height: 13),
                  _details('Source', 'Spot Account'),
                ]),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _editNote,
                child: Text(_note.isEmpty
                  ? 'Note to Payee' : 'Edit Note to Payee',
                  style: const TextStyle(
                    color: BinancePalette.yellow, fontSize: 13)),
              ),
              if (hasAmount && !canContinue && !asyncBalance.isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 9),
                  child: Text(
                    amount > available
                      ? 'Insufficient ' + widget.asset + ' demo balance'
                      : 'Enter an amount greater than zero (max 10 decimals)',
                    key: const Key('send-amount-warning'),
                    style: const TextStyle(
                      color: BinancePalette.red, fontSize: 11.5)),
                ),
              if (asyncBalance.hasError)
                const Text('Could not load your wallet.',
                  style: TextStyle(color: BinancePalette.red)),
              const SizedBox(height: 10),
              const Text('DEMO • No real recipient is credited.',
                style: TextStyle(color: BinancePalette.textMuted,
                  fontSize: 10.5)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
          child: SizedBox(
            height: 49,
            child: FilledButton(
              key: const Key('send-amount-continue'),
              onPressed: canContinue ? () => _openConfirm(balance) : null,
              style: FilledButton.styleFrom(
                backgroundColor: BinancePalette.yellow,
                disabledBackgroundColor: const Color(0xFF51471D),
                disabledForegroundColor: const Color(0xFF92824C),
                foregroundColor: BinancePalette.canvas,
              ),
              child: const Text('Continue',
                style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _details(String label, String value, {Widget? trailing}) =>
      Row(children: [
        Expanded(child: Text(label,
          style: const TextStyle(
            color: BinancePalette.textMuted, fontSize: 11.5))),
        Flexible(child: Text(value,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: BinancePalette.textPrimary, fontSize: 11.5))),
        if (trailing != null) trailing,
      ]);
}

/// Step 5: Confirmation sheet. The database is touched ONLY after Confirm.
class _ConfirmPaymentSheet extends StatefulWidget {
  const _ConfirmPaymentSheet({
    required this.asset,
    required this.recipient,
    required this.amount,
    required this.approximateKes,
    required this.note,
    required this.send,
  });

  final String asset;
  final String recipient;
  final double amount;
  final String approximateKes;
  final String note;
  final Future<void> Function() send;

  @override
  State<_ConfirmPaymentSheet> createState() => _ConfirmPaymentSheetState();
}

class _ConfirmPaymentSheetState extends State<_ConfirmPaymentSheet> {
  bool _submitting = false;
  String? _error;

  Future<void> _confirm() async {
    if (_submitting) return;
    setState(() { _submitting = true; _error = null; });
    try {
      await widget.send();
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() =>
        _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              const SizedBox(width: 36),
              const Expanded(child: Text('Confirm Payment',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: BinancePalette.textPrimary,
                  fontSize: 16, fontWeight: FontWeight.w600))),
              IconButton(
                tooltip: 'Cancel',
                onPressed: _submitting ? null : () => Navigator.pop(context),
                icon: const Icon(Icons.close,
                  color: BinancePalette.textMuted)),
            ]),
            const SizedBox(height: 12),
            _sheetCard(Row(children: [
              const CircleAvatar(
                backgroundColor: BinancePalette.raised,
                child: Icon(Icons.person_outline,
                  color: BinancePalette.textPrimary)),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.recipient + ' (Binance ID)',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: BinancePalette.textPrimary,
                      fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('Unverified demo recipient',
                    style: TextStyle(
                      color: BinancePalette.textMuted, fontSize: 11)),
                ],
              )),
            ])),
            const SizedBox(height: 11),
            _sheetCard(_summaryRow('Payee Receives',
              formatWalletQuantity(widget.amount) + ' ' + widget.asset,
              sub: widget.approximateKes, symbol: widget.asset)),
            const SizedBox(height: 11),
            _sheetCard(_summaryRow('Method', 'Spot Account (Demo)')),
            const SizedBox(height: 11),
            _sheetCard(_summaryRow('Payment Currency',
              formatWalletQuantity(widget.amount) + ' ' + widget.asset,
              symbol: widget.asset)),
            if (widget.note.isNotEmpty) ...[
              const SizedBox(height: 11),
              _sheetCard(_summaryRow('Note', widget.note)),
            ],
            const SizedBox(height: 16),
            const Text(
              'DEMO ONLY • Confirm subtracts this amount from your own '
              'Supabase demo balance. It does not transfer funds or verify '
              'the recipient.',
              textAlign: TextAlign.center,
              style: TextStyle(color: BinancePalette.textMuted,
                fontSize: 11, height: 1.4),
            ),
            if (_error != null) ...[
              const SizedBox(height: 11),
              Text(_error!, key: const Key('send-confirm-error'),
                style: const TextStyle(
                  color: BinancePalette.red, fontSize: 12)),
            ],
            const SizedBox(height: 19),
            SizedBox(
              width: double.infinity, height: 49,
              child: FilledButton(
                key: const Key('send-confirm-button'),
                onPressed: _submitting ? null : _confirm,
                style: FilledButton.styleFrom(
                  backgroundColor: BinancePalette.yellow,
                  foregroundColor: BinancePalette.canvas),
                child: _submitting
                  ? const SizedBox(height: 19, width: 19,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Confirm',
                      style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _sheetCard(Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    decoration: BoxDecoration(
      color: BinancePalette.surface,
      border: Border.all(color: BinancePalette.border, width: 0.6),
      borderRadius: BorderRadius.circular(12)),
    child: child,
  );

  Widget _summaryRow(String title, String value, {
    String? sub, String? symbol,
  }) => Row(children: [
    Expanded(child: Text(title, style: const TextStyle(
      color: BinancePalette.textMuted, fontSize: 12))),
    Flexible(child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          if (symbol != null) ...[
            Image.asset('assets/svgs/home_icons/' + symbol + '.png',
              width: 16, height: 16),
            const SizedBox(width: 6),
          ],
          Flexible(child: Text(value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: BinancePalette.textPrimary,
              fontSize: 13, fontWeight: FontWeight.w600))),
        ]),
        if (sub != null) ...[
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(
            color: BinancePalette.textMuted, fontSize: 11)),
        ],
      ],
    )),
  ]);
}

class DemoSendSuccessScreen extends StatelessWidget {
  const DemoSendSuccessScreen({
    super.key,
    required this.asset,
    required this.recipient,
    required this.amount,
  });
  final String asset;
  final String recipient;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BinancePalette.canvas,
      appBar: AppBar(
        backgroundColor: BinancePalette.canvas,
        foregroundColor: BinancePalette.textPrimary,
        surfaceTintColor: Colors.transparent,
        title: const Text('Demo Transfer'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        ),
      ),
      body: SafeArea(top: false, child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const Spacer(),
          const Icon(Icons.check_circle_rounded,
            color: BinancePalette.green, size: 76),
          const SizedBox(height: 18),
          const Text('Demo balance updated',
            style: TextStyle(color: BinancePalette.textPrimary,
              fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text(formatWalletQuantity(amount) + ' ' + asset + ' deducted',
            style: const TextStyle(
              color: BinancePalette.textPrimary, fontSize: 16)),
          const SizedBox(height: 11),
          Text('Recipient entered: ' + recipient,
            style: const TextStyle(
              color: BinancePalette.textMuted, fontSize: 12)),
          const SizedBox(height: 10),
          const Text('Prototype only. No recipient was credited '
            'and no real crypto was sent.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: BinancePalette.textMuted, fontSize: 12, height: 1.4)),
          const Spacer(),
          SizedBox(width: double.infinity, height: 49,
            child: FilledButton(
              key: const Key('send-done'),
              onPressed: () => Navigator.popUntil(
                context, (route) => route.isFirst),
              style: FilledButton.styleFrom(
                backgroundColor: BinancePalette.yellow,
                foregroundColor: BinancePalette.canvas),
              child: const Text('Done',
                style: TextStyle(fontWeight: FontWeight.w600)),
            )),
        ]),
      )),
    );
  }
}
