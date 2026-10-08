import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../services/providers.dart';

import '../../core/localization/translations.dart';
import '../../core/localization/app_languages.dart';

void showAppointmentDetailsModal(BuildContext context, WidgetRef ref, Appointment apt) {
  Map<String, int> usedItems = Map.from(apt.usedItems);
  final l10n = context.l10n(ref);

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setModalState) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: apt.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(LucideIcons.calendar, color: apt.color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.aptDetailsTitle),
                Text(apt.patientName, style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color)),
              ],
            )
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 32),
                _buildDetailRow(context, l10n.aptDetailsFieldPatient, apt.patientName),
                _buildDetailRow(context, l10n.appointmentsFieldPlace, apt.place == 'Clinic' ? l10n.appointmentsPlaceClinic : l10n.appointmentsPlaceHome),
                _buildDetailRow(context, l10n.appointmentsFieldProcedure, apt.procedures.map((p) => '${p.procedure} - ${p.type}').join('\n')),
                _buildDetailRow(context, l10n.appointmentsFieldDate, DateFormat('MMMM dd, yyyy', l10n.language == AppLanguage.en ? 'en_US' : 'bg_BG').format(apt.date)),
                _buildDetailRow(context, l10n.appointmentsFieldTime, apt.time),
                if (apt.notes != null && apt.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(context, l10n.appointmentsFieldNotes, apt.notes!),
                ],
                const Divider(height: 32),
                Text(l10n.aptDetailsSuppliesTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Consumer(
                  builder: (context, ref, child) {
                    final inventory = ref.watch(inventoryProvider).valueOrNull ?? [];
                    
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (usedItems.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(l10n.aptDetailsNoItems, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                            ),
                          ...usedItems.entries.map((entry) {
                            final item = inventory.firstWhere((i) => i.id == entry.key, orElse: () => InventoryItem(id: '', name: 'Unknown', category: '', quantity: 0));
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Expanded(child: Text(item.name)),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(LucideIcons.minus, size: 20),
                                        onPressed: () {
                                          setModalState(() {
                                            if (usedItems[entry.key]! > 1) {
                                              usedItems[entry.key] = usedItems[entry.key]! - 1;
                                            } else {
                                              usedItems.remove(entry.key);
                                            }
                                          });
                                        },
                                      ),
                                      Text('${entry.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: const Icon(LucideIcons.plus, size: 20),
                                        onPressed: () {
                                          setModalState(() {
                                            usedItems[entry.key] = usedItems[entry.key]! + 1;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          const Divider(),
                          
                          // Searchable autocomplete for supplies
                          Autocomplete<InventoryItem>(
                            displayStringForOption: (InventoryItem option) => '${option.name} (${option.category})',
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) {
                                return const Iterable<InventoryItem>.empty();
                              }
                              return inventory.where((InventoryItem item) {
                                return item.name.toLowerCase().contains(textEditingValue.text.toLowerCase()) || 
                                       item.category.toLowerCase().contains(textEditingValue.text.toLowerCase());
                              });
                            },
                            onSelected: (InventoryItem selection) {
                              setModalState(() {
                                usedItems[selection.id] = (usedItems[selection.id] ?? 0) + 1;
                              });
                            },
                            fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                              return TextField(
                                controller: fieldTextEditingController,
                                focusNode: fieldFocusNode,
                                decoration: InputDecoration(
                                  labelText: l10n.aptDetailsSearchHint,
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                  prefixIcon: const Icon(LucideIcons.search, size: 18),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.patientsClose),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryBlue),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.push('/patients/${apt.patientId}');
            },
            icon: const Icon(LucideIcons.history, size: 18),
            label: Text(l10n.aptDetailsHistoryButton),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            onPressed: () {
              // SAVE LOGIC
              final diffs = <String, int>{};
              for (final entry in apt.usedItems.entries) {
                diffs[entry.key] = -(entry.value);
              }
              for (final entry in usedItems.entries) {
                diffs[entry.key] = (diffs[entry.key] ?? 0) + entry.value;
              }

              final inventory = ref.read(inventoryProvider).valueOrNull ?? [];
              for (final entry in diffs.entries) {
                if (entry.value == 0) continue;
                final itemOpt = inventory.where((i) => i.id == entry.key).firstOrNull;
                if (itemOpt != null) {
                  final updatedItem = InventoryItem(
                    id: itemOpt.id,
                    name: itemOpt.name,
                    category: itemOpt.category,
                    expirationDate: itemOpt.expirationDate,
                    quantity: itemOpt.quantity - entry.value,
                  );
                  ref.read(inventoryProvider.notifier).updateItem(updatedItem);
                }
              }
              
              final updatedApt = Appointment(
                id: apt.id,
                patientId: apt.patientId,
                patientName: apt.patientName,
                date: apt.date,
                time: apt.time,
                doctorId: apt.doctorId,
                place: apt.place,
                procedures: apt.procedures,
                color: apt.color,
                notes: apt.notes,
                usedItems: usedItems,
              );
              ref.read(appointmentsProvider.notifier).updateAppointment(updatedApt);
              
              Navigator.of(ctx).pop();
            },
            icon: const Icon(LucideIcons.save, size: 18),
            label: Text(l10n.aptDetailsSaveItems),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}

Widget _buildDetailRow(BuildContext context, String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 120, child: Text(label, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.bold))),
        Expanded(child: Text(value, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w500))),
      ],
    ),
  );
}
