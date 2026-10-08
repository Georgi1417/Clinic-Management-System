import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/providers.dart';
import '../../models/models.dart';
import '../widgets/appointment_details_modal.dart';

import '../../core/localization/translations.dart';
import '../../core/localization/app_languages.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(patientsProvider);
    final appointmentsAsync = ref.watch(appointmentsProvider);
    final l10n = context.l10n(ref);
    final currentLang = ref.watch(languageProvider);

    Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dashboardOverview,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.dashboardSubtitle,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: l10n.dashboardTotalPatients,
                    value: patientsAsync.maybeWhen(data: (d) => d.length.toString(), orElse: () => '...'),
                    icon: LucideIcons.users,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: l10n.dashboardTodayAppointments,
                    value: appointmentsAsync.maybeWhen(data: (d) => d.where((a) => a.date.day == DateTime.now().day).length.toString(), orElse: () => '...'),
                    icon: LucideIcons.calendar,
                    color: AppTheme.warning,
                  ),
                ),

              ],
            ),
            
            const SizedBox(height: 32),
            
            // Main Content Split
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recent Patients Table
                Expanded(
                  flex: 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.dashboardRecentPatients, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 16),
                        patientsAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, stack) => Text('Error: $err'),
                          data: (patients) => _buildPatientsTable(context, patients, appointmentsAsync, l10n),
                        ),
                      ],
                    ),
                  ),
                ),
                ),
                const SizedBox(width: 24),
                
                // Upcoming Appointments List
                Expanded(
                  flex: 1,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.dashboardTodayAppointments, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('EEEE, MMMM d', currentLang == AppLanguage.en ? 'en_US' : 'bg_BG').format(DateTime.now()), 
                          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13)
                        ),
                        const SizedBox(height: 16),
                        appointmentsAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, stack) => Text('Error: $err'),
                          data: (appointments) {
                            final todayAppts = appointments.where((a) {
                              final now = DateTime.now();
                              return a.date.year == now.year && a.date.month == now.month && a.date.day == now.day && a.actualDateTime.isAfter(now);
                            }).toList();
                            todayAppts.sort((a, b) => a.actualDateTime.compareTo(b.actualDateTime));

                            if (todayAppts.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Center(child: Text(l10n.dashboardNoUpcomingAppts, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color))),
                              );
                            }

                            return Column(
                              children: todayAppts.map((apt) => _buildAppointmentItem(context, ref, apt)).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
              Text(
                value,
                style: theme.textTheme.displayMedium?.copyWith(
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildPatientsTable(BuildContext context, List<Patient> patients, AsyncValue<List<Appointment>> appointmentsAsync, Translations l10n) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 1, child: Text(l10n.tableId, style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontWeight: FontWeight.bold))),
            Expanded(flex: 2, child: Text(l10n.tableName, style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontWeight: FontWeight.bold))),
            Expanded(flex: 2, child: Text(l10n.tablePhone, style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontWeight: FontWeight.bold))),
            Expanded(flex: 2, child: Text(l10n.tableLastVisit, style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontWeight: FontWeight.bold))),
          ],
        ),
        const Divider(height: 32),
        ...patients.take(4).map((patient) {
          DateTime? actualLastVisit;
          if (appointmentsAsync.value != null) {
            final pAppts = appointmentsAsync.value!.where((a) => a.patientId == patient.id).toList();
            final now = DateTime.now();
            final pastAppts = pAppts.where((a) => !a.actualDateTime.isAfter(now));
            if (pastAppts.isNotEmpty) {
              var sorted = pastAppts.toList()..sort((a, b) => b.actualDateTime.compareTo(a.actualDateTime));
              actualLastVisit = sorted.first.actualDateTime;
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                Expanded(flex: 1, child: Text(patient.id, style: const TextStyle(fontWeight: FontWeight.w600))),
                Expanded(
                  flex: 2, 
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
                        child: Text(patient.initials, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                      ),
                      const SizedBox(width: 8),
                      Text(patient.name, style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Expanded(flex: 2, child: Text(patient.phone)),
                Expanded(
                  flex: 2, 
                  child: Text(actualLastVisit != null ? DateFormat('MMM dd, yyyy', l10n.language == AppLanguage.en ? 'en_US' : 'bg_BG').format(actualLastVisit) : l10n.tableNoVisits, 
                    style: TextStyle(color: actualLastVisit == null ? Theme.of(context).textTheme.bodyMedium?.color : Theme.of(context).textTheme.bodyLarge?.color)
                  )
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAppointmentItem(BuildContext context, WidgetRef ref, Appointment apt) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => showAppointmentDetailsModal(context, ref, apt),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: apt.color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(apt.patientName, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${apt.time} - ${apt.place} (${apt.procedures.map((p) => p.procedure).join(', ')})', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
