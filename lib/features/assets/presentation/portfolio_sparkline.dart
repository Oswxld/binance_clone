import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Compact, visually illustrative Binance-like sparkline.
///
/// This is NOT portfolio historical performance: b_balances currently stores
/// just the latest USDT/BTC quantities, not timestamped valuation history.
/// Replace [_sampleSpots] with genuine historical KES snapshots once available.
class PortfolioSparkline extends StatelessWidget {
  const PortfolioSparkline({super.key});

  static final List<FlSpot> _sampleSpots = List<FlSpot>.unmodifiable(
    List<FlSpot>.generate(65, (index) {
      // Trace the supplied SVG's zig-zag, adding deterministic fine
      // fluctuations so the 96px miniature resembles a dense market graph.
      const anchors = <double>[
        18, 18, 20, 16, 18, 14, 15, 13, 15,
        14, 8, 14, 4, 18, 14, 23, 20, 24,
      ];
      final t = index / 64 * (anchors.length - 1);
      final left = t.floor();
      final right = math.min(left + 1, anchors.length - 1);
      final baseY = anchors[left] +
          (anchors[right] - anchors[left]) * (t - left);
      final fineMovement = math.sin(index * 2.73) * 1.8 +
          math.cos(index * 4.17) * 1.1;
      final y = (28 - baseY - fineMovement).clamp(1.0, 27.0).toDouble();
      return FlSpot(index.toDouble(), y);
    }),
  );

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 96,
      height: 36,
      child: RepaintBoundary(child: _PortfolioLineGraph()),
    );
  }
}

class _PortfolioLineGraph extends StatelessWidget {
  const _PortfolioLineGraph();

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 64,
        minY: 0,
        maxY: 28,
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: PortfolioSparkline._sampleSpots,
            color: const Color(0xFFFCD535),
            barWidth: 1.8,
            isCurved: false,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
      duration: Duration.zero,
    );
  }
}
