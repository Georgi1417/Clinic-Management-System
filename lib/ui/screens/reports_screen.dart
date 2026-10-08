import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/providers.dart';
import '../widgets/report_preview_dialog.dart';

import '../../core/localization/translations.dart';
import '../../core/localization/app_languages.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(patientsProvider);
    final appointmentsAsync = ref.watch(appointmentsProvider);
    final inventoryAsync = ref.watch(inventoryProvider);
    final l10n = context.l10n(ref);

    final patients = patientsAsync.valueOrNull ?? [];
    final appts = appointmentsAsync.valueOrNull ?? [];
    final inventory = inventoryAsync.valueOrNull ?? [];

    final lowStockCount = inventory.where((i) => i.quantity < 10).length;
    final totalApptsThisMonth = appts.where((a) => a.actualDateTime.month == DateTime.now().month && a.actualDateTime.year == DateTime.now().year).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.reportsTitle, style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 8),
            Text(l10n.reportsSubtitle, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16)),
            const SizedBox(height: 32),
            
            // KPIs Row
            Row(
              children: [
                Expanded(child: _buildKpiCard(context, l10n.reportsKpiTotalPatients, patients.length.toString(), LucideIcons.users, AppTheme.primaryBlue)),
                const SizedBox(width: 24),
                Expanded(child: _buildKpiCard(context, l10n.reportsKpiApptsMonth, totalApptsThisMonth.toString(), LucideIcons.calendarCheck, AppTheme.success)),
                const SizedBox(width: 24),
                Expanded(child: _buildKpiCard(context, l10n.reportsKpiLowStock, lowStockCount.toString(), Icons.warning_amber_rounded, lowStockCount > 0 ? AppTheme.error : (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey))),
              ],
            ),
            const SizedBox(height: 32),

            // Charts Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildWeeklyTrafficChart(context, appts, l10n)),
                const SizedBox(width: 24),
                Expanded(flex: 1, child: _buildProcedurePieChart(context, appts, l10n)),
              ],
            ),
            
            const SizedBox(height: 48),
            const Divider(height: 1),
            const SizedBox(height: 48),
            
            Text(l10n.reportsGenerationTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            // Existing Report Generation Cards
            Row(
              children: [
                Expanded(
                  child: _buildReportCard(
                    context,
                    title: l10n.reportsDailyTitle,
                    description: l10n.reportsDailyDesc,
                    icon: LucideIcons.calendarClock,
                    buttonLabel: l10n.reportsDailyButton,
                    color: AppTheme.primaryBlue,
                    onPressed: () => showReportPreviewDialog(context, ref, ReportTimeframe.daily),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildReportCard(
                    context,
                    title: l10n.reportsMonthlyTitle,
                    description: l10n.reportsMonthlyDesc,
                    icon: LucideIcons.calendarDays,
                    buttonLabel: l10n.reportsMonthlyButton,
                    color: AppTheme.warning,
                    onPressed: () => showReportPreviewDialog(context, ref, ReportTimeframe.monthly),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Theme.of(context).textTheme.bodyLarge?.color)),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyTrafficChart(BuildContext context, List<Appointment> appts, Translations l10n) {
    final now = DateTime.now();
    final List<int> dailyCounts = List.filled(7, 0);
    final List<String> dayLabels = [];

    // Past 6 days + today
    for (int i = 6; i >= 0; i--) {
      final targetDate = now.subtract(Duration(days: i));
      dayLabels.add(DateFormat('E', l10n.language == AppLanguage.en ? 'en_US' : 'bg_BG').format(targetDate)); // Mon, Tue, etc.
      
      final count = appts.where((a) => a.actualDateTime.year == targetDate.year && 
                                       a.actualDateTime.month == targetDate.month && 
                                       a.actualDateTime.day == targetDate.day).length;
      dailyCounts[6 - i] = count;
    }

    final computedMax = dailyCounts.reduce((a, b) => a > b ? a : b).toDouble();
    final maxY = computedMax == 0 ? 5.0 : (computedMax * 1.5).clamp(5.0, 100.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.reportsChartWeeklyTraffic, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 2.2,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(dayLabels[value.toInt()], style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 12, fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        if (value % 1 != 0) return const SizedBox.shrink(); 
                        return Text(value.toInt().toString(), style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 12));
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 5,
                  getDrawingHorizontalLine: (value) => FlLine(color: const Color(0xFFE5E7EB), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: dailyCounts[index].toDouble(),
                        color: AppTheme.primaryBlue,
                        width: 40,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                      )
                    ],
                  );
                }),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcedurePieChart(BuildContext context, List<Appointment> appts, Translations l10n) {
    final Map<String, int> procedureCounts = {};
    for (final a in appts) {
      for (final p in a.procedures) {
        procedureCounts[p.procedure] = (procedureCounts[p.procedure] ?? 0) + 1;
      }
    }

    if (procedureCounts.isEmpty) {
      return Card(
        child: SizedBox(
          height: 300,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(child: Text(l10n.reportsNoProcedureData, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color))),
          ),
        ),
      );
    }

    final colors = [AppTheme.primaryBlue, AppTheme.warning, AppTheme.success, AppTheme.error, AppTheme.pending];
    var i = 0;
    
    final sections = procedureCounts.entries.map((e) {
      final color = colors[i % colors.length];
      i++;
      return PieChartSectionData(
        color: color,
        value: e.value.toDouble(),
        title: '${e.value}',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.reportsChartProcedures, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.25,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: sections,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Custom Legend
          ...procedureCounts.entries.map((e) {
            final idx = procedureCounts.keys.toList().indexOf(e.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: colors[idx % colors.length], shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500))),
                  Text('${e.value}', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyMedium?.color)),
                ],
              ),
            );
          }).toList(),
        ],
      ),
      ),
    );
  }

  // Legacy layout definitions
  Widget _buildReportCard(BuildContext context, {required String title, required String description, required IconData icon, required String buttonLabel, required Color color, VoidCallback? onPressed}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(description, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onPressed ?? () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(buttonLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      ),
    );
  }
}
