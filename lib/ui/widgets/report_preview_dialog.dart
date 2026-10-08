import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/models.dart';
import '../../services/providers.dart';
import '../../core/localization/translations.dart';
import '../../core/localization/app_languages.dart';

enum ReportTimeframe { daily, monthly }

void showReportPreviewDialog(BuildContext context, WidgetRef ref, ReportTimeframe timeframe) {
  showDialog(
    context: context,
    builder: (ctx) => ReportPreviewDialog(timeframe: timeframe),
  );
}

class ReportPreviewDialog extends ConsumerWidget {
  final ReportTimeframe timeframe;
  const ReportPreviewDialog({super.key, required this.timeframe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(patientsProvider);
    final appointmentsAsync = ref.watch(appointmentsProvider);
    final inventoryAsync = ref.watch(inventoryProvider);
    final l10n = context.l10n(ref);
    final currentLang = ref.watch(languageProvider);

    final allApts = appointmentsAsync.valueOrNull ?? [];
    final inventory = inventoryAsync.valueOrNull ?? [];

    final now = DateTime.now();

    // 1. Filter Appointments
    final filteredAppts = allApts.where((a) {
      if (timeframe == ReportTimeframe.daily) {
        return a.actualDateTime.year == now.year && a.actualDateTime.month == now.month && a.actualDateTime.day == now.day;
      } else {
        return a.actualDateTime.year == now.year && a.actualDateTime.month == now.month;
      }
    }).toList();

    // 2. Identify Patients
    filteredAppts.map((a) => a.patientId).toSet();

    // 3. Aggregate Inventory Usage
    final Map<String, int> totalUsedItems = {};
    for (var apt in filteredAppts) {
      for (var entry in apt.usedItems.entries) {
        totalUsedItems[entry.key] = (totalUsedItems[entry.key] ?? 0) + entry.value;
      }
    }

    // 4. Identify Expirations (< 14 days)
    final twoWeeksFromNow = now.add(const Duration(days: 14));
    final expiringItems = inventory.where((i) {
      if (i.expirationDate == null) return false;
      return i.expirationDate!.isBefore(twoWeeksFromNow);
    }).toList();

    final title = timeframe == ReportTimeframe.daily 
        ? '${l10n.reportsPreviewDailyTitle} - ${DateFormat('MMM dd, yyyy', currentLang == AppLanguage.en ? 'en_US' : 'bg_BG').format(now)}' 
        : '${l10n.reportsPreviewMonthlyTitle} - ${DateFormat('MMMM yyyy', currentLang == AppLanguage.en ? 'en_US' : 'bg_BG').format(now)}';

    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(timeframe == ReportTimeframe.daily ? LucideIcons.calendarClock : LucideIcons.calendarDays, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: theme.textTheme.displaySmall?.color)),
            ],
          ),
          IconButton(icon: Icon(Icons.close, color: theme.textTheme.bodyMedium?.color), onPressed: () => Navigator.of(context).pop()),
        ],
      ),
      content: SizedBox(
        width: 800,
        height: 600,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               _buildSectionTitle(context, l10n.reportsPreviewSectionAppts),
              _buildPatientsTable(context, filteredAppts, l10n, currentLang),
              const SizedBox(height: 32),
              
              _buildSectionTitle(context, l10n.reportsPreviewSectionInventory),
              if (totalUsedItems.isEmpty)
                Text(l10n.reportsPreviewNoInventory, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color))
              else
                _buildInventoryUsageTable(context, totalUsedItems, inventory, l10n),
              const SizedBox(height: 32),

              _buildSectionTitle(context, l10n.reportsPreviewSectionCritical),
              if (expiringItems.isEmpty)
                Text(l10n.reportsPreviewNoExpiringSoon, style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold))
              else
                _buildExpiryWarningTable(context, expiringItems, l10n, currentLang),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: () => _exportPdf(title, filteredAppts, totalUsedItems, inventory, expiringItems, l10n, currentLang),
          icon: const Icon(LucideIcons.fileText, size: 18),
          label: Text(l10n.reportsPreviewExportPDF),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.titleLarge?.color)),
    );
  }

  Widget _buildPatientsTable(BuildContext context, List<Appointment> appts, Translations l10n, AppLanguage currentLang) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(8)),
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(theme.colorScheme.surfaceVariant),
        columns: [
          DataColumn(label: Text(l10n.aptDetailsFieldPatient, style: TextStyle(color: theme.textTheme.titleMedium?.color, fontWeight: FontWeight.bold))),
          DataColumn(label: Text(l10n.appointmentsFieldProcedure, style: TextStyle(color: theme.textTheme.titleMedium?.color, fontWeight: FontWeight.bold))),
          DataColumn(label: Text(l10n.reportsPreviewTableTimeDate, style: TextStyle(color: theme.textTheme.titleMedium?.color, fontWeight: FontWeight.bold))),
        ],
        rows: appts.map((a) {
          return DataRow(cells: [
            DataCell(Text(a.patientName, style: TextStyle(fontWeight: FontWeight.w500, color: theme.textTheme.bodyLarge?.color))),
            DataCell(Text(a.procedures.map((p) => '${p.procedure} - ${p.type}').join(', '), style: TextStyle(color: theme.textTheme.bodyMedium?.color))),
            DataCell(Text('${DateFormat('MMM dd', currentLang == AppLanguage.en ? 'en_US' : 'bg_BG').format(a.date)} at ${a.time}', style: TextStyle(color: theme.textTheme.bodyMedium?.color))),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildInventoryUsageTable(BuildContext context, Map<String, int> usage, List<InventoryItem> inventory, Translations l10n) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(8)),
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(theme.colorScheme.surfaceVariant),
        columns: [
          DataColumn(label: Text(l10n.storageTableItemName, style: TextStyle(color: theme.textTheme.titleMedium?.color, fontWeight: FontWeight.bold))),
          DataColumn(label: Text(l10n.reportsPreviewTableQtyUsed, style: TextStyle(color: theme.textTheme.titleMedium?.color, fontWeight: FontWeight.bold))),
          DataColumn(label: Text(l10n.reportsPreviewTableRemaining, style: TextStyle(color: theme.textTheme.titleMedium?.color, fontWeight: FontWeight.bold))),
        ],
        rows: usage.entries.map((e) {
          final item = inventory.firstWhere((i) => i.id == e.key, orElse: () => InventoryItem(id: '', name: l10n.commonUnknown, category: '', quantity: 0));
          return DataRow(cells: [
            DataCell(Text(item.name, style: TextStyle(color: theme.textTheme.bodyLarge?.color))),
            DataCell(Text('${e.value}', style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color))),
            DataCell(Text('${item.quantity}', style: TextStyle(color: item.quantity <= 0 ? const Color(0xFFEF4444) : theme.textTheme.bodyMedium?.color))),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildExpiryWarningTable(BuildContext context, List<InventoryItem> expiringItems, Translations l10n, AppLanguage currentLang) {
    final theme = Theme.of(context);
    const errorRed = Color(0xFFEF4444);
    return Container(
      decoration: BoxDecoration(border: Border.all(color: errorRed), borderRadius: BorderRadius.circular(8)),
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(errorRed.withOpacity(0.1)),
        columns: [
          DataColumn(label: Text(l10n.storageTableItemName, style: const TextStyle(color: errorRed, fontWeight: FontWeight.bold))),
          DataColumn(label: Text(l10n.storageTableQuantity, style: const TextStyle(color: errorRed, fontWeight: FontWeight.bold))),
          DataColumn(label: Text(l10n.storageTableExpiration, style: const TextStyle(color: errorRed, fontWeight: FontWeight.bold))),
        ],
        rows: expiringItems.map((i) {
          final fmtDate = i.expirationDate != null ? DateFormat('MMM dd, yyyy', currentLang == AppLanguage.en ? 'en_US' : 'bg_BG').format(i.expirationDate!) : l10n.commonNA;
          return DataRow(cells: [
            DataCell(Text(i.name, style: const TextStyle(fontWeight: FontWeight.w600, color: errorRed))),
            DataCell(Text('${i.quantity}', style: TextStyle(color: theme.textTheme.bodyMedium?.color))),
            DataCell(Text(fmtDate, style: const TextStyle(fontWeight: FontWeight.bold, color: errorRed))),
          ]);
        }).toList(),
      ),
    );
  }


  // ===================== EXPORTS =====================

  void _exportPdf(String title, List<Appointment> appts, Map<String, int> usage, List<InventoryItem> inventory, List<InventoryItem> expiringItems, Translations l10n, AppLanguage currentLang) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
            pw.SizedBox(height: 20),
            
            // Appointments
            pw.Text(l10n.reportsPreviewSectionAppts, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Table.fromTextArray(
              context: context,
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
              data: <List<String>>[
                <String>[l10n.aptDetailsFieldPatient, l10n.appointmentsFieldProcedure, l10n.appointmentsFieldDate],
                ...appts.map((a) => [a.patientName, a.procedures.map((p) => '${p.procedure} - ${p.type}').join(', '), '${DateFormat('MMM dd', currentLang == AppLanguage.en ? 'en_US' : 'bg_BG').format(a.date)} at ${a.time}'])
              ],
            ),
            pw.SizedBox(height: 20),

            // Inventory Usage
            pw.Text(l10n.reportsPreviewSectionInventory, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            if (usage.isEmpty) 
               pw.Text(l10n.reportsPreviewNoInventory)
            else
               pw.Table.fromTextArray(
                 context: context,
                 headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                 data: <List<String>>[
                   <String>[l10n.storageTableItemName, l10n.reportsPreviewTableUsedShort, l10n.reportsPreviewTableRemainingShort],
                   ...usage.entries.map((e) {
                     final item = inventory.firstWhere((i) => i.id == e.key, orElse: () => InventoryItem(id: '', name: l10n.commonUnknown, category: '', quantity: 0));
                     return [item.name, e.value.toString(), item.quantity.toString()];
                   })
                 ],
               ),
            pw.SizedBox(height: 20),

            // Expirations
            pw.Text(l10n.reportsPreviewSectionCritical, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.red700)),
            pw.SizedBox(height: 8),
            if (expiringItems.isEmpty)
               pw.Text(l10n.reportsPreviewNoExpiringSoon)
            else
               pw.Table.fromTextArray(
                 context: context,
                 headerDecoration: const pw.BoxDecoration(color: PdfColors.red100),
                 data: <List<String>>[
                   <String>[l10n.storageTableItemName, l10n.storageTableQuantity, l10n.storageTableExpiration],
                   ...expiringItems.map((i) {
                     final fmtDate = i.expirationDate != null ? DateFormat('MMM dd, yyyy', currentLang == AppLanguage.en ? 'en_US' : 'bg_BG').format(i.expirationDate!) : l10n.commonNA;
                     return [i.name, i.quantity.toString(), fmtDate];
                   })
                 ],
               ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }
}
