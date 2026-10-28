import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Tabs currently implemented in the demo. Other visible icons remain visual
/// placeholders until their corresponding features are built.
enum AppTab { home, markets }

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final AppTab selected;
  final ValueChanged<AppTab> onSelect;

  static const _background = Color(0xFF181A20);
  static const _muted = Color(0xFF848E9C);
  static const _yellow = Color(0xFFFCD535);

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

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
      decoration: const BoxDecoration(
        color: _background,
        border: Border(top: BorderSide(color: Color(0xFF22262F))),
      ),
      child: Row(
        children: [
          _navigationItem(
            name: 'Home',
            icon: homeSelected ? 'home' : 'home_inactive',
            active: homeSelected,
            activeLabelColor: _yellow,
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
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: _yellow,
                  shape: BoxShape.circle,
                ),
                child: _icon(marketsSelected ? 'markets_trade' : 'trade', 24),
              ),
            ),
          ),
          _navigationItem(
            name: 'Invest',
            icon: marketsSelected ? 'markets_invest' : 'invest',
            active: false,
          ),
          _navigationItem(
            name: 'Assets',
            icon: marketsSelected ? 'markets_assets' : 'assets',
            active: false,
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
