import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/providers.dart';
import '../../models/models.dart';

import '../../core/localization/translations.dart';
import '../../core/localization/app_languages.dart';

class PatientsScreen extends ConsumerStatefulWidget {
  const PatientsScreen({super.key});

  @override
  ConsumerState<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends ConsumerState<PatientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientsProvider);
    final appointmentsAsync = ref.watch(appointmentsProvider);
    final l10n = context.l10n(ref);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.patientsTitle, style: Theme.of(context).textTheme.displayMedium),
                ElevatedButton.icon(
                  onPressed: () => _showAddPatientDialog(context, ref, l10n),
                  icon: const Icon(LucideIcons.plus),
                  label: Text(l10n.patientsAddButton),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Search / Filter row
            Row(
              children: [
                SizedBox(
                  width: 350,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.patientsSearchHint,
                      prefixIcon: Icon(LucideIcons.search, color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).textTheme.bodyMedium?.color, size: 20),
                      fillColor: Theme.of(context).cardTheme.color,
                    ),
                  ),
                ),

              ],
            ),
            const SizedBox(height: 24),
            
            // Table mapping to Patient Model
            Expanded(
              child: Card(
                child: patientsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  data: (patients) {
                    final filteredPatients = patients.where((p) {
                      if (_searchQuery.isEmpty) return true;
                      return p.name.toLowerCase().contains(_searchQuery) ||
                             p.id.toLowerCase().contains(_searchQuery) ||
                             p.egn.toLowerCase().contains(_searchQuery) ||
                             p.phone.toLowerCase().contains(_searchQuery);
                    }).toList();

                    return Column(
                      children: [
                        _buildTableHeader(l10n),
                        const Divider(height: 1),
                        Expanded(
                          child: filteredPatients.isEmpty
                              ? Center(child: Text(l10n.patientsNotFound, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)))
                              : ListView.separated(
                                  itemCount: filteredPatients.length,
                                  separatorBuilder: (context, index) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final p = filteredPatients[index];
                                    DateTime? actualLastVisit;
                                    if (appointmentsAsync.valueOrNull != null) {
                                      final pAppts = appointmentsAsync.valueOrNull!.where((a) => a.patientId == p.id).toList();
                                      final pastAppts = pAppts.where((a) => a.date.isBefore(DateTime.now().add(const Duration(days: 1))));
                                      if (pastAppts.isNotEmpty) {
                                        var sorted = pastAppts.toList()..sort((a, b) => b.date.compareTo(a.date));
                                        final lastAppt = sorted.first;
                                        DateTime d = lastAppt.date;
                                        int hour = d.hour;
                                        int min = d.minute;
                                        try {
                                          List<String> parts = lastAppt.time.split(' ');
                                          List<String> hm = parts[0].split(':');
                                          hour = int.parse(hm[0]);
                                          min = int.parse(hm[1]);
                                          if (parts.length > 1 && parts[1].toUpperCase() == 'PM' && hour < 12) {
                                            hour += 12;
                                          } else if (parts.length > 1 && parts[1].toUpperCase() == 'AM' && hour == 12) {
                                            hour = 0;
                                          }
                                        } catch (_) {}
                                        actualLastVisit = DateTime(d.year, d.month, d.day, hour, min);
                                      }
                                    }
                                    final patientToRender = Patient(id: p.id, name: p.name, egn: p.egn, phone: p.phone, email: p.email, lastVisit: actualLastVisit, ills: p.ills);

                                    return _buildPatientRow(context, patientToRender, l10n);
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(Translations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(l10n.tableId, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(flex: 3, child: Text(l10n.patientsTableInfo, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(flex: 2, child: Text(l10n.patientsFieldEGN.toUpperCase(), style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(flex: 2, child: Text(l10n.tablePhone, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(flex: 2, child: Text(l10n.tableLastVisit, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(flex: 1, child: Text(l10n.patientsTableActions, textAlign: TextAlign.right, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.bold, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildPatientRow(BuildContext context, Patient patient, Translations l10n) {
    return InkWell(
      onTap: () => _showPatientModal(context, patient, l10n),
      hoverColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Expanded(flex: 1, child: Text(patient.id, style: const TextStyle(fontWeight: FontWeight.w600))),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                    child: Text(patient.initials, style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patient.name, style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
                      Text(patient.email, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(flex: 2, child: Text(patient.egn)),
            Expanded(flex: 2, child: Text(patient.phone)),
            Expanded(
              flex: 2, 
              child: Text(patient.lastVisit != null ? DateFormat('MMM dd, yyyy', l10n.language == AppLanguage.en ? 'en_US' : 'bg_BG').format(patient.lastVisit!) : l10n.tableNoVisits, 
                style: TextStyle(color: patient.lastVisit == null ? Theme.of(context).textTheme.bodyMedium?.color : Theme.of(context).textTheme.bodyLarge?.color)
              )
            ),
            Expanded(
              flex: 1,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(icon: const Icon(LucideIcons.pencil, color: AppTheme.primaryBlue, size: 20), onPressed: () => _showEditPatientDialog(context, ref, patient, l10n)),
                    IconButton(icon: const Icon(LucideIcons.trash2, color: AppTheme.error, size: 20), onPressed: () => _confirmDeletePatient(context, ref, patient, l10n)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPatientModal(BuildContext context, Patient patient, Translations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
              child: Text(patient.initials, style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient.name),
                Text('ID: ${patient.id}', style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color)),
              ],
            )
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 32),
              _buildDetailRow(l10n.patientsFieldEGN, patient.egn),
              _buildDetailRow(l10n.patientsFieldPhone, patient.phone),
              _buildDetailRow(l10n.patientsFieldEmail, patient.email),
              _buildDetailRow(l10n.tableLastVisit, patient.lastVisit != null ? DateFormat('MMMM dd, yyyy - HH:mm', l10n.language == AppLanguage.en ? 'en_US' : 'bg_BG').format(patient.lastVisit!) : l10n.tableNoVisits),
              if (patient.ills.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDetailRow(l10n.patientsFieldConditions, patient.ills),
              ]
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.patientsClose),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.push('/patients/${patient.id}');
            },
            child: Text(l10n.patientsViewFullHistory),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showAddPatientDialog(BuildContext context, WidgetRef ref, Translations l10n) {
    final formKey = GlobalKey<FormState>();
    final fnameController = TextEditingController();
    final snameController = TextEditingController();
    final egnController = TextEditingController();
    final phoneController = TextEditingController(text: '+359 ');
    final emailController = TextEditingController();
    final illsController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.patientsDialogAddTitle),
        content: SizedBox(
          width: 500,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: fnameController,
                          decoration: InputDecoration(labelText: l10n.patientsFieldFirstName, border: const OutlineInputBorder()),
                          validator: (val) => val == null || val.isEmpty ? l10n.patientsFieldRequired : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: snameController,
                          decoration: InputDecoration(labelText: l10n.patientsFieldSurname, border: const OutlineInputBorder()),
                          validator: (val) => val == null || val.isEmpty ? l10n.patientsFieldRequired : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: egnController,
                    decoration: InputDecoration(labelText: l10n.patientsFieldEGN, border: const OutlineInputBorder()),
                    validator: (val) => val == null || val.isEmpty ? l10n.patientsFieldRequired : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: l10n.patientsFieldPhone, border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: l10n.patientsFieldEmail, border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: illsController,
                    maxLines: 3,
                    decoration: InputDecoration(labelText: l10n.patientsFieldConditions, border: const OutlineInputBorder()),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.commonCancel)),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final currentList = ref.read(patientsProvider).valueOrNull ?? [];
                final newPatient = Patient(
                  id: 'P-${1100 + currentList.length}',
                  name: '${fnameController.text.trim()} ${snameController.text.trim()}',
                  egn: egnController.text.trim(),
                  phone: phoneController.text.trim(),
                  email: emailController.text.trim(),
                  lastVisit: null,
                  ills: illsController.text.trim(),
                );
                ref.read(patientsProvider.notifier).addPatient(newPatient);
                Navigator.of(ctx).pop();
              }
            },
            child: Text(l10n.patientsSavePatient),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _confirmDeletePatient(BuildContext context, WidgetRef ref, Patient patient, Translations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.patientsDialogRemoveTitle),
        content: Text('${l10n.patientsDialogRemoveConfirm}\n\n${patient.name}'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.commonCancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              ref.read(patientsProvider.notifier).deletePatient(patient.id);
              Navigator.of(ctx).pop();
            },
            child: Text(l10n.commonDelete),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showEditPatientDialog(BuildContext context, WidgetRef ref, Patient patient, Translations l10n) {
    final formKey = GlobalKey<FormState>();
    
    // Split name intelligently
    final nameParts = patient.name.split(' ');
    final fname = nameParts.isNotEmpty ? nameParts[0] : '';
    final sname = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final fnameController = TextEditingController(text: fname);
    final snameController = TextEditingController(text: sname);
    final egnController = TextEditingController(text: patient.egn);
    final phoneController = TextEditingController(text: patient.phone);
    final emailController = TextEditingController(text: patient.email);
    final illsController = TextEditingController(text: patient.ills);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${l10n.patientsDialogEditTitle}: ${patient.name}'),
        content: SizedBox(
          width: 500,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: fnameController,
                          decoration: InputDecoration(labelText: l10n.patientsFieldFirstName, border: const OutlineInputBorder()),
                          validator: (val) => val == null || val.isEmpty ? l10n.patientsFieldRequired : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: snameController,
                          decoration: InputDecoration(labelText: l10n.patientsFieldSurname, border: const OutlineInputBorder()),
                          validator: (val) => val == null || val.isEmpty ? l10n.patientsFieldRequired : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: egnController,
                    decoration: InputDecoration(labelText: l10n.patientsFieldEGN, border: const OutlineInputBorder()),
                    validator: (val) => val == null || val.isEmpty ? l10n.patientsFieldRequired : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: l10n.patientsFieldPhone, border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: l10n.patientsFieldEmail, border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: illsController,
                    maxLines: 3,
                    decoration: InputDecoration(labelText: l10n.patientsFieldConditions, border: const OutlineInputBorder()),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.commonCancel)),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final updatedPatient = Patient(
                  id: patient.id,
                  name: '${fnameController.text.trim()} ${snameController.text.trim()}',
                  egn: egnController.text.trim(),
                  phone: phoneController.text.trim(),
                  email: emailController.text.trim(),
                  lastVisit: patient.lastVisit,
                  ills: illsController.text.trim(),
                );
                ref.read(patientsProvider.notifier).updatePatient(updatedPatient);
                Navigator.of(ctx).pop();
              }
            },
            child: Text(l10n.patientsSaveChanges),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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
}
