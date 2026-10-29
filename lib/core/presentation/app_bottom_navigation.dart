import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/binance_palette.dart';

/// Tabs currently implemented in the demo. Other visible icons remain visual
/// placeholders until their corresponding features are built.
enum AppTab { home, markets, invest, assets }

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final AppTab selected;
  final ValueChanged<AppTab> onSelect;

  static const _background = BinancePalette.canvas;
  static const _muted = BinancePalette.textMuted;
  static const _yellow = BinancePalette.yellow;

  Widget _icon(String asset, double size) {
    return SvgPicture.asset(
      'assets/svgs/' + asset + '.svg',
      width: size,
      height: size,
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeSelected = selected == AppTab.home;
    final marketsSelected = selected == AppTab.markets;
    final investSelected = selected == AppTab.invest;
    final assetsSelected = selected == AppTab.assets;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
      decoration: const BoxDecoration(
        color: _background,
        border: Border(top: BorderSide(color: BinancePalette.border)),
      ),
      child: Row(
        children: [
          _navigationItem(
            name: 'Home',
            icon: homeSelected ? 'home' : 'home_inactive',
            active: homeSelected,
            activeLabelColor: Colors.white,
            onTap: () => onSelect(AppTab.home),
          ),
          _navigationItem(
            name: 'Markets',
            icon: marketsSelected ? 'markets_active' : 'markets_inactive',
            active: marketsSelected,
            // Per the Markets mockup, only the chart arrow glows yellow;
            // the rest of the chart and active label stay white.
            activeLabelColor: Colors.white,
            onTap: () => onSelect(AppTab.markets),
          ),
          Expanded(
            child: Center(
              child: Container(
                key: const Key('bottom-trade-circle'),
                width: 62,
                height: 62,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: _yellow,
                  shape: BoxShape.circle,
                ),
                child: _icon('trade', 32),
              ),
            ),
          ),
          _navigationItem(
            name: 'Invest',
            icon: investSelected ? 'invest_active' : 'invest_inactive',
            active: investSelected,
            activeLabelColor: Colors.white,
            onTap: () => onSelect(AppTab.invest),
          ),
          _navigationItem(
            name: 'Assets',
            icon: assetsSelected ? 'assets_active' : 'assets_inactive',
            active: assetsSelected,
            activeLabelColor: Colors.white,
            onTap: () => onSelect(AppTab.assets),
          ),
        ],
      ),
    );
  }

  Widget _navigationItem({
    required String name,
    required String icon,
    required bool active,
    Color activeLabelColor = _yellow,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Semantics(
        button: onTap != null,
        selected: active,
        label: name,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _icon(icon, 20),
                const SizedBox(height: 7),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 10,
                    color: active ? activeLabelColor : _muted,
                    fontWeight:
                        active ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
