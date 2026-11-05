import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/binance_palette.dart';
import '../../../core/utils/wallet_amount_formatter.dart';
import '../../home/domain/home_balance.dart';
import '../../home/presentation/home_provider.dart';
import '../data/withdrawal_repository.dart';
import 'withdrawal_details_screen.dart';

/// USDT on TRC20 amount entry. Uses the phone's actual decimal keyboard.
class WithdrawEnterAmountScreen extends ConsumerStatefulWidget {
  const WithdrawEnterAmountScreen({super.key, required this.address});
  final String address;

  @override
  ConsumerState<WithdrawEnterAmountScreen> createState() =>
      _WithdrawEnterAmountState();
}

class _WithdrawEnterAmountState
    extends ConsumerState<WithdrawEnterAmountScreen> {
  final _controller = TextEditingController();
  bool _submitting = false;
  String? _error;

  double get amount => double.tryParse(_controller.text.trim()) ?? 0;

  // Illustrated 50 -> 46 received + 4 fee from the supplied design.
  // These are presentation values, not actual blockchain network quotes.
  double get networkFee =>
      double.parse((amount * 0.08).toStringAsFixed(10));
  double get receiveAmount => amount - networkFee;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setMax(HomeBalance balance) {
    final value = balance.usdt.toStringAsFixed(10)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length));
    setState(() => _error = null);
  }

  Future<void> _withdraw() async {
    if (_submitting || amount <= 0) return;
    final submittedAmount = amount;
    final submittedFee = networkFee;
    FocusScope.of(context).unfocus();
    setState(() { _submitting = true; _error = null; });
    try {
      // Server atomically deducts USDT and inserts the g_messages row.
      final receipt = await ref.read(withdrawalRepositoryProvider)
          .withdrawUsdt(
            amount: submittedAmount,
            address: widget.address,
          );
      ref.invalidate(homeBalanceProvider);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
        builder: (_) => WithdrawalDetailsScreen(
          address: widget.address,
          totalAmount: submittedAmount,
          networkFee: submittedFee,
          createdAt: receipt.createdAtUtc,
          transactionId: receipt.transactionId,
        ),
      ));
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final balanceState = ref.watch(homeBalanceProvider);
    final balance = balanceState.asData?.value ?? const HomeBalance.zero();
    final valid = !_submitting && !balanceState.isLoading &&
      !balanceState.hasError && amount.isFinite &&
      amount > 0 && amount <= balance.usdt &&
      double.parse(amount.toStringAsFixed(10)) > 0;

    final kes = balance.hasValuation && balance.usdtKesRate > 0
        ? '≈ KSh' + formatWalletMoney(amount * balance.usdtKesRate)
        : '≈ KSh--';

    return Scaffold(
      backgroundColor: BinancePalette.canvas,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: BinancePalette.canvas,
        foregroundColor: BinancePalette.textPrimary,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Image.asset('assets/svgs/home_icons/USDT.png',
            width: 23, height: 23),
          const SizedBox(width: 9),
          const Text('Send USDT', style: TextStyle(
            fontSize: 17, fontWeight: FontWeight.w600)),
        ]),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _submitting ? null : () => Navigator.pop(context)),
        actions: [
          IconButton(
            tooltip: 'Help',
            onPressed: () => FocusScope.of(context).unfocus(),
            icon: const Icon(Icons.help_outline, size: 21)),
          IconButton(
            tooltip: 'Scan',
            onPressed: () => FocusScope.of(context).unfocus(),
            icon: const Icon(Icons.qr_code_scanner_outlined, size: 21)),
        ],
      ),
      body: SafeArea(top: false, bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13, vertical: 9),
                decoration: BoxDecoration(
                  color: BinancePalette.raised,
                  borderRadius: BorderRadius.circular(5)),
                child: const Text('One-time',
                  style: TextStyle(color: BinancePalette.textPrimary,
                    fontSize: 12)),
              ),
              const SizedBox(height: 25),
              Row(children: [
                Expanded(
                  child: TextField(
                    key: const Key('withdraw-usdt-amount'),
                    controller: _controller,
                    enabled: !_submitting,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                    inputFormatters: [TextInputFormatter.withFunction(
                      (oldValue, newValue) =>
                        RegExp(r'^\d{0,14}(\.\d{0,10})?$')
                            .hasMatch(newValue.text)
                            ? newValue : oldValue)],
                    onChanged: (_) => setState(() => _error = null),
                    cursorColor: BinancePalette.yellow,
                    style: const TextStyle(
                      color: BinancePalette.textPrimary,
                      fontSize: 42, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(
                        color: BinancePalette.textDisabled),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero),
                  ),
                ),
                const Text('USDT', style: TextStyle(
                  color: BinancePalette.textDisabled,
                  fontSize: 21, fontWeight: FontWeight.w600)),
                const SizedBox(width: 10),
                TextButton(
                  key: const Key('withdraw-max'),
                  onPressed: _submitting || balanceState.isLoading
                      ? null : () => _setMax(balance),
                  style: TextButton.styleFrom(
                    backgroundColor: BinancePalette.raised,
                    foregroundColor: BinancePalette.textPrimary),
                  child: const Text('Max', style: TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 12)),
                ),
              ]),
              const SizedBox(height: 10),
              Text(kes, style: const TextStyle(
                color: BinancePalette.textMuted, fontSize: 13)),
              const SizedBox(height: 12),
              Text('Available  ' + formatWalletQuantity(balance.usdt) +
                   ' USDT',
                style: const TextStyle(
                  color: BinancePalette.textSecondary, fontSize: 12)),
              const SizedBox(height: 25),
              const Text('Network  TRC20 (TRX)', style: TextStyle(
                color: BinancePalette.textMuted, fontSize: 12)),
              const SizedBox(height: 33),
              _infoRow('Receive amount',
                formatWalletQuantity(receiveAmount) + ' USDT'),
              const SizedBox(height: 19),
              _infoRow('Network fee',
                formatWalletQuantity(networkFee) + ' USDT'),
              if (amount > balance.usdt) ...[
                const SizedBox(height: 18),
                const Text('Insufficient USDT balance',
                  key: Key('withdraw-balance-warning'),
                  style: TextStyle(
                    color: BinancePalette.red, fontSize: 12)),
              ],
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, key: const Key('withdraw-submit-error'),
                  style: const TextStyle(
                    color: BinancePalette.red, fontSize: 12)),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
          child: SizedBox(height: 49, child: FilledButton(
            key: const Key('withdraw-submit'),
            onPressed: valid ? _withdraw : null,
            style: FilledButton.styleFrom(
              backgroundColor: BinancePalette.yellow,
              foregroundColor: BinancePalette.canvas,
              disabledBackgroundColor: const Color(0xFF534928),
              disabledForegroundColor: const Color(0xFF8C7A39)),
            child: _submitting
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Withdraw', style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
          )),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(
          color: BinancePalette.textMuted, fontSize: 12.5)),
        Text(value, style: const TextStyle(
          color: BinancePalette.textPrimary,
          fontWeight: FontWeight.w500, fontSize: 12.5)),
      ]);
}
