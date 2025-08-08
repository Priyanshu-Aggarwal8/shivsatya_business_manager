import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfitAnalysisChart extends StatefulWidget {
  final List<Map<String, dynamic>> profitData;
  final VoidCallback? onChartTap;

  const ProfitAnalysisChart({
    super.key,
    required this.profitData,
    this.onChartTap,
  });

  @override
  State<ProfitAnalysisChart> createState() => _ProfitAnalysisChartState();
}

class _ProfitAnalysisChartState extends State<ProfitAnalysisChart> {
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
            Text('Profit Analysis',
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
              child: BarChart(BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxValue(),
                  barTouchData: BarTouchData(
                      enabled: true,
                      touchCallback:
                          (FlTouchEvent event, BarTouchResponse? response) {
                        setState(() {
                          if (response != null && response.spot != null) {
                            touchedIndex = response.spot!.touchedBarGroupIndex;
                          } else {
                            touchedIndex = -1;
                          }
                        });
                      },
                      touchTooltipData: BarTouchTooltipData(
                          tooltipRoundedRadius: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final data = widget.profitData[groupIndex];
                            return BarTooltipItem(
                                '${data['product']}\nProfit: ₹${(data['profit'] as double).toStringAsFixed(0)}\nMargin: ${data['margin']}%',
                                theme.textTheme.bodySmall!.copyWith(
                                    color: theme.colorScheme.onInverseSurface,
                                    fontWeight: FontWeight.w600));
                          })),
                  titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 &&
                                    index < widget.profitData.length) {
                                  return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                          (widget.profitData[index]['product']
                                                  as String)
                                              .substring(0, 3),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                  color: theme.colorScheme
                                                      .onSurfaceVariant)));
                                }
                                return const Text('');
                              },
                              reservedSize: 30)),
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: _getMaxValue() / 4,
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
                  barGroups: _getBarGroups(theme),
                  gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: _getMaxValue() / 4,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.2),
                            strokeWidth: 1);
                      })))),
        ]));
  }

  List<BarChartGroupData> _getBarGroups(ThemeData theme) {
    return widget.profitData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isTouched = index == touchedIndex;

      return BarChartGroupData(x: index, barRods: [
        BarChartRodData(
            toY: data['profit'] as double,
            color:
                isTouched ? AppTheme.successLight : theme.colorScheme.primary,
            width: isTouched ? 20 : 16,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4), topRight: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: _getMaxValue(),
                color: theme.colorScheme.outline.withValues(alpha: 0.1))),
      ]);
    }).toList();
  }

  double _getMaxValue() {
    if (widget.profitData.isEmpty) return 50000;
    final maxProfit = widget.profitData
        .map((data) => data['profit'] as double)
        .reduce((a, b) => a > b ? a : b);
    return (maxProfit * 1.2).ceilToDouble();
  }
}
