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

    // The navigation edge rises smoothly over the Trade circle and returns
    // to the straight border. It is one painted path, never a line drawn
    // behind the yellow circle.
    return SizedBox(
      height: 82,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final centerX = constraints.maxWidth / 2;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  key: const Key('nav-shaped-background'),
                  painter: const _NavigationContourPainter(),
                ),
              ),
              Positioned(
                top: 25,
                left: 10,
                right: 10,
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
                      icon: marketsSelected
                          ? 'markets_active' : 'markets_inactive',
                      active: marketsSelected,
                      activeLabelColor: Colors.white,
                      onTap: () => onSelect(AppTab.markets),
                    ),
                    // Reserve the same width as the other four tabs so their
                    // labels and touch targets remain exactly aligned.
                    const Expanded(child: SizedBox.shrink()),
                    _navigationItem(
                      name: 'Invest',
                      icon: investSelected
                          ? 'invest_active' : 'invest_inactive',
                      active: investSelected,
                      activeLabelColor: Colors.white,
                      onTap: () => onSelect(AppTab.invest),
                    ),
                    _navigationItem(
                      name: 'Assets',
                      icon: assetsSelected
                          ? 'assets_active' : 'assets_inactive',
                      active: assetsSelected,
                      activeLabelColor: Colors.white,
                      onTap: () => onSelect(AppTab.assets),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 7,
                left: centerX - 26,
                child: Container(
                  key: const Key('bottom-trade-circle'),
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: _yellow,
                    shape: BoxShape.circle,
                  ),
                  child: _icon('trade', 27),
                ),
              ),
            ],
          );
        },
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

/// A raised, smooth top outline that follows the Trade button without
/// drawing a straight border through the middle.
class _NavigationContourPainter extends CustomPainter {
  const _NavigationContourPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const shoulderY = 24.0;
    const crestY = 1.0;
    final centerX = size.width / 2;

    final contour = Path()
      ..moveTo(0, shoulderY)
      ..lineTo(centerX - 42, shoulderY)
      ..cubicTo(centerX - 30, shoulderY,
          centerX - 36, crestY, centerX, crestY)
      ..cubicTo(centerX + 36, crestY,
          centerX + 30, shoulderY, centerX + 42, shoulderY)
      ..lineTo(size.width, shoulderY);

    final filled = Path.from(contour)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      filled,
      Paint()..color = BinancePalette.canvas,
    );
    canvas.drawPath(
      contour,
      Paint()
        ..color = BinancePalette.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _NavigationContourPainter oldDelegate) => false;
}
