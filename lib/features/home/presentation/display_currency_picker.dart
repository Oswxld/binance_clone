import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/binance_palette.dart';
import '../domain/wallet_display_currency.dart';
import 'home_provider.dart';

/// Shared popup so both Home and Assets select one display denomination.
class DisplayCurrencyPicker extends ConsumerWidget {
  const DisplayCurrencyPicker({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(displayCurrencyProvider);
    return PopupMenuButton<WalletDisplayCurrency>(
      key: const Key('display-currency-picker'),
      tooltip: 'Choose display currency',
      initialValue: selected,
      position: PopupMenuPosition.under,
      color: BinancePalette.surface,
      elevation: 10,
      constraints: const BoxConstraints(minWidth: 150, maxWidth: 190),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (currency) =>
          ref.read(displayCurrencyProvider.notifier).select(currency),
      itemBuilder: (_) => [
        for (final currency in WalletDisplayCurrency.values)
          PopupMenuItem<WalletDisplayCurrency>(
            value: currency,
            height: 37,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    currency.code,
                    style: TextStyle(
                      color: BinancePalette.textPrimary,
                      fontSize: 13,
                      fontWeight: currency == selected
                          ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (currency == selected)
                  const Icon(Icons.check, color: BinancePalette.textPrimary,
                      size: 17),
              ],
            ),
          ),
      ],
      child: child,
    );
  }
}
