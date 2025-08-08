import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SalesTrendChart extends StatefulWidget {
  final List<Map<String, dynamic>> salesData;
  final VoidCallback? onChartTap;

  const SalesTrendChart({
    super.key,
    required this.salesData,
    this.onChartTap,
  });

  @override
  State<SalesTrendChart> createState() => _SalesTrendChartState();
}

class _SalesTrendChartState extends State<SalesTrendChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
        height: 30.h,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Sales Trend',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            GestureDetector(
                onTap: widget.onChartTap,
                child: CustomIconWidget(
                    iconName: 'fullscreen',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20)),
          ]),
          SizedBox(height: 2.h),
          Expanded(
              child: LineChart(LineChartData(
                  gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: _getMaxValue() / 4,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.2),
                            strokeWidth: 1);
                      }),
                  titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 &&
                                    index < widget.salesData.length) {
                                  return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                          (widget.salesData[index]['date']
                                                  as String)
                                              .substring(0, 5),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                  color: theme.colorScheme
                                                      .onSurfaceVariant)));
                                }
                                return const Text('');
                              })),
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              interval: _getMaxValue() / 4,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                    '₹${(value / 1000).toStringAsFixed(0)}K',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme
                                            .colorScheme.onSurfaceVariant));
                              }))),
                  borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                          color: theme.colorScheme.outline
                              .withValues(alpha: 0.2))),
                  minX: 0,
                  maxX: (widget.salesData.length - 1).toDouble(),
                  minY: 0,
                  maxY: _getMaxValue(),
                  lineBarsData: [
                    LineChartBarData(
                        spots: _getSpots(),
                        isCurved: true,
                        gradient: LinearGradient(colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.7),
                        ]),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                  radius: touchedIndex == index ? 6 : 4,
                                  color: theme.colorScheme.primary,
                                  strokeWidth: 2,
                                  strokeColor: theme.colorScheme.surface);
                            }),
                        belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary
                                      .withValues(alpha: 0.3),
                                  theme.colorScheme.primary
                                      .withValues(alpha: 0.1),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter))),
                  ],
                  lineTouchData: LineTouchData(
                      enabled: true,
                      touchCallback: (FlTouchEvent event,
                          LineTouchResponse? touchResponse) {
                        setState(() {
                          if (touchResponse != null &&
                              touchResponse.lineBarSpots != null) {
                            touchedIndex =
                                touchResponse.lineBarSpots!.first.spotIndex;
                          } else {
                            touchedIndex = -1;
                          }
                        });
                      },
                      touchTooltipData: LineTouchTooltipData(
                          tooltipRoundedRadius: 8,
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              final index = barSpot.spotIndex;
                              final data = widget.salesData[index];
                              return LineTooltipItem(
                                  '${data['date']}\n₹${(data['amount'] as double).toStringAsFixed(0)}',
                                  theme.textTheme.bodySmall!.copyWith(
                                      color: theme.colorScheme.onInverseSurface,
                                      fontWeight: FontWeight.w600));
                            }).toList();
                          }))))),
        ]));
  }

  List<FlSpot> _getSpots() {
    return widget.salesData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), (entry.value['amount'] as double));
    }).toList();
  }

  double _getMaxValue() {
    if (widget.salesData.isEmpty) return 100000;
    final maxAmount = widget.salesData
        .map((data) => data['amount'] as double)
        .reduce((a, b) => a > b ? a : b);
    return (maxAmount * 1.2).ceilToDouble();
  }
}
