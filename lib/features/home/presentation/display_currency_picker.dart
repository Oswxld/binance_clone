import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/binance_palette.dart';
import '../domain/wallet_display_currency.dart';
import 'home_provider.dart';

/// Opens a compact, right-side currency popup directly BELOW the tapped
/// label/chevron. Unlike PopupMenuButton(initialValue: ...), positioning is
/// independent of which currency is selected (including the last item, KES).
class DisplayCurrencyPicker extends ConsumerWidget {
  const DisplayCurrencyPicker({super.key, required this.child});

  final Widget child;

  static const double _menuWidth = 130;
  static const double _itemHeight = 36;

  Future<void> _showCurrencyMenu(BuildContext context, WidgetRef ref) async {
    final renderBox = context.findRenderObject();
    if (renderBox is! RenderBox || !renderBox.hasSize) return;

    final rect = renderBox.localToGlobal(Offset.zero) & renderBox.size;
    final media = MediaQuery.of(context);
    final screen = media.size;
    const edgePadding = 8.0;
    final menuHeight = WalletDisplayCurrency.values.length * _itemHeight;

    // Keep the popup near the right-hand ticker, but within the viewport.
    // On the Assets tab the widget only wraps the currency + chevron,
    // not the full amount row, so its anchor is never the left of the screen.
    final left = (rect.left - 4).clamp(
      edgePadding,
      (screen.width - _menuWidth - edgePadding)
          .clamp(edgePadding, double.infinity),
    ).toDouble();
    final below = rect.bottom + 3;
    final maximumTop = screen.height - media.padding.bottom -
        menuHeight - edgePadding;
    final top = below <= maximumTop
        ? below
        : (rect.top - menuHeight - 3)
            .clamp(media.padding.top + edgePadding, maximumTop)
            .toDouble();

    final selected = ref.read(displayCurrencyProvider);
    final chosen = await showGeneralDialog<WalletDisplayCurrency>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 110),
      pageBuilder: (dialogContext, _, __) => Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              width: _menuWidth,
              child: Material(
                key: const Key('display-currency-menu'),
                color: BinancePalette.surface,
                elevation: 9,
                shadowColor: Colors.black54,
                borderRadius: BorderRadius.circular(7),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final currency in WalletDisplayCurrency.values)
                      InkWell(
                        key: ValueKey('display-currency-option-${currency.code}'),
                        onTap: () => Navigator.of(dialogContext).pop(currency),
                        child: Container(
                          height: _itemHeight,
                          padding: const EdgeInsets.symmetric(horizontal: 11),
                          color: currency == selected
                              ? BinancePalette.raised
                              : Colors.transparent,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  currency.code,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: BinancePalette.textPrimary,
                                    fontWeight: currency == selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                              if (currency == selected)
                                const Icon(
                                  Icons.check,
                                  color: BinancePalette.textPrimary,
                                  size: 17,
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (chosen != null && context.mounted) {
      ref.read(displayCurrencyProvider.notifier).select(chosen);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      button: true,
      label: 'Choose display currency',
      child: InkWell(
        key: const Key('display-currency-picker'),
        onTap: () => _showCurrencyMenu(context, ref),
        borderRadius: BorderRadius.circular(4),
        child: child,
      ),
    );
  }
}
