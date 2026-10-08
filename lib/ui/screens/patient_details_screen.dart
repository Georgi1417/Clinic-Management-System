import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../models/models.dart';
import '../../services/providers.dart';
import '../widgets/appointment_details_modal.dart';

import '../../core/localization/translations.dart';
import '../../core/localization/app_languages.dart';

class PatientDetailsScreen extends ConsumerWidget {
  final String patientId;

  const PatientDetailsScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(patientsProvider);
    final appointmentsAsync = ref.watch(appointmentsProvider);
    final l10n = context.l10n(ref);
    final currentLang = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: patientsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (patients) {
          final patient = patients.firstWhere(
            (p) => p.id == patientId,
            orElse: () => Patient(id: '', name: 'Not Found', egn: '', phone: '', email: '', lastVisit: null, ills: ''),
          );

          if (patient.id.isEmpty) {
            return Center(child: Text(l10n.patientsNotFoundDetail));
          }

          return Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.arrowLeft, size: 28),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 16),
                    Text(l10n.patientsPortfolio, style: Theme.of(context).textTheme.displayMedium),
                  ],
                ),
                const SizedBox(height: 32),

                // Patient Info Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerTheme.color ?? const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        child: Text(patient.initials, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 32, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(patient.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                            const SizedBox(height: 4),
                            Text('ID: ${patient.id}', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14)),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                _buildInfoChip(context, LucideIcons.idCard, '${l10n.patientsFieldEGN}: ${patient.egn}'),
                                _buildInfoChip(context, LucideIcons.phone, patient.phone),
                                if (patient.email.isNotEmpty) _buildInfoChip(context, LucideIcons.mail, patient.email),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (patient.ills.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).colorScheme.error.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 20),
                            const SizedBox(width: 8),
                            Text(l10n.patientsFieldConditions, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.error, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(patient.ills, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15, height: 1.5)),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                // Timeline
                Expanded(
                  child: appointmentsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                    data: (appointments) {
                      final allApts = appointments.where((a) => a.patientId == patientId).toList();
                      
                      final now = DateTime.now();
                      
                      final upcoming = allApts.where((a) => a.actualDateTime.isAfter(now)).toList()
                        ..sort((a, b) => a.actualDateTime.compareTo(b.actualDateTime)); // Soonest first
                        
                      final past = allApts.where((a) => !a.actualDateTime.isAfter(now)).toList()
                        ..sort((a, b) => b.actualDateTime.compareTo(a.actualDateTime)); // Newest first

                      if (allApts.isEmpty) {
                        return Center(child: Text(l10n.patientsHistoryNoAppts, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)));
                      }

                      return ListView(
                        children: [
                          if (upcoming.isNotEmpty) ...[
                            Text(l10n.patientsHistoryUpcoming, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                            const SizedBox(height: 16),
                            ...upcoming.map((a) => _buildVisitCard(context, ref, a, l10n, isUpcoming: true, currentLang: currentLang)),
                            const SizedBox(height: 32),
                          ],
                          
                          if (past.isNotEmpty || upcoming.isEmpty) ...[
                            Text(l10n.patientsHistoryPast, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                            const SizedBox(height: 16),
                            if (past.isEmpty)
                               Text(l10n.patientsHistoryNoPast, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color))
                            else
                               ...past.map((a) => _buildVisitCard(context, ref, a, l10n, isUpcoming: false, currentLang: currentLang)),
                          ]
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildVisitCard(BuildContext context, WidgetRef ref, Appointment visit, Translations l10n, {required bool isUpcoming, required AppLanguage currentLang}) {
    return GestureDetector(
      onTap: () => showAppointmentDetailsModal(context, ref, visit),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerTheme.color ?? const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: visit.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(isUpcoming ? LucideIcons.calendarClock : LucideIcons.calendarCheck, color: visit.color, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${visit.place == 'Clinic' ? l10n.appointmentsPlaceClinic : l10n.appointmentsPlaceHome} (${visit.procedures.map((p) => p.procedure).join(', ')})', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
                      const SizedBox(height: 4),
                      Text('${DateFormat('MMMM dd, yyyy', currentLang == AppLanguage.en ? 'en_US' : 'bg_BG').format(visit.date)} at ${visit.time}', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${l10n.commonDoctorPrefix} ${visit.doctorId}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(context).colorScheme.onSecondaryContainer)),
              )
            ],
          ),
          if (visit.notes != null && visit.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Text(l10n.patientsTreatmentNotes, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 6),
            Text(visit.notes!, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.5, fontSize: 14)),
          ],
        ],
      ),
      ),
    );
  }
}
