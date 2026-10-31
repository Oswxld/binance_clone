import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/binance_palette.dart';
import '../../../core/utils/wallet_amount_formatter.dart';
import '../../home/domain/home_balance.dart';
import '../../home/presentation/home_provider.dart';
import 'send_select_method_screen.dart';

/// Assets > Send > Select Asset, using live wallet values.
class SendSelectAssetScreen extends ConsumerStatefulWidget {
  const SendSelectAssetScreen({super.key});
  @override
  ConsumerState<SendSelectAssetScreen> createState() => _SendSelectAssetState();
}

class _SendSelectAssetState extends ConsumerState<SendSelectAssetScreen> {
  final _search = TextEditingController();
  bool _showSearch = false;
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _choose(String symbol) {
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => SendSelectMethodScreen(asset: symbol),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(homeBalanceProvider);
    final snapshot = balance.asData?.value ?? const HomeBalance.zero();
    final query = _search.text.trim().toLowerCase();
    final assets = ['USDT', 'BTC'].where((symbol) =>
      symbol.toLowerCase().contains(query) ||
      (symbol == 'USDT' ? 'tetherus' : 'bitcoin').contains(query)).toList();

    return Scaffold(
      backgroundColor: BinancePalette.canvas,
      appBar: AppBar(
        backgroundColor: BinancePalette.canvas,
        foregroundColor: BinancePalette.textPrimary,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text('Select Asset',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        leading: IconButton(icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context)),
        actions: [IconButton(
          tooltip: 'Search',
          icon: Icon(_showSearch ? Icons.close : Icons.search),
          onPressed: () => setState(() {
            _showSearch = !_showSearch;
            if (!_showSearch) _search.clear();
          }),
        )],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
          children: [
            const Row(children: [
              Icon(Icons.account_balance_wallet_outlined,
                size: 20, color: BinancePalette.textPrimary),
              SizedBox(width: 8),
              Flexible(child: Text('Spot + Funding + Earn Flexible',
                style: TextStyle(color: BinancePalette.textPrimary,
                  fontSize: 13.5, fontWeight: FontWeight.w600))),
              Icon(Icons.keyboard_arrow_down,
                color: BinancePalette.textSecondary, size: 18),
            ]),
            if (_showSearch) ...[
              const SizedBox(height: 16),
              TextField(
                key: const Key('send-search-asset'),
                controller: _search,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: BinancePalette.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search Coins',
                  hintStyle: const TextStyle(color: BinancePalette.textMuted),
                  filled: true, fillColor: BinancePalette.surface,
                  prefixIcon: const Icon(Icons.search,
                    color: BinancePalette.textMuted),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
            const SizedBox(height: 33),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Search History',
                  style: TextStyle(color: BinancePalette.textPrimary,
                    fontSize: 14, fontWeight: FontWeight.w600)),
                Icon(Icons.delete_outline,
                  size: 18, color: BinancePalette.textMuted),
              ]),
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft,
              child: ActionChip(
                label: const Text('USDT'),
                onPressed: () => _choose('USDT'),
                backgroundColor: BinancePalette.surface,
                side: BorderSide.none,
                labelStyle: const TextStyle(
                  color: BinancePalette.textPrimary, fontSize: 12),
              )),
            const SizedBox(height: 31),
            const Text('Coin List', style: TextStyle(
              color: BinancePalette.textPrimary,
              fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            if (balance.hasError)
              const Text('Could not load demo wallet',
                style: TextStyle(color: BinancePalette.red)),
            if (assets.isEmpty)
              const Text('No matching coins',
                style: TextStyle(color: BinancePalette.textMuted)),
            for (final symbol in assets)
              InkWell(
                key: Key('send-select-' + symbol),
                onTap: () => _choose(symbol),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Row(children: [
                    ClipOval(child: Image.asset(
                      'assets/svgs/home_icons/' + symbol + '.png',
                      height: 30, width: 30)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(symbol, style: const TextStyle(
                          color: BinancePalette.textPrimary,
                          fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 3),
                        Text(symbol == 'USDT' ? 'TetherUS' : 'Bitcoin',
                          style: const TextStyle(
                            color: BinancePalette.textMuted, fontSize: 12)),
                      ],
                    )),
                    Flexible(child: Text(
                      balance.isLoading ? 'Loading…' : formatWalletQuantity(
                        symbol == 'USDT' ? snapshot.usdt : snapshot.btc),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: BinancePalette.textSecondary, fontSize: 11))),
                    const Icon(Icons.chevron_right,
                      size: 17, color: BinancePalette.textMuted),
                  ]),
                ),
              ),
            const SizedBox(height: 20),
            const Text('DEMO WALLET • No real assets will be sent.',
              textAlign: TextAlign.center,
              style: TextStyle(color: BinancePalette.textMuted,
                fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
