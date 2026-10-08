import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/providers.dart';
import '../../models/models.dart';
import '../widgets/appointment_details_modal.dart';

import '../../core/localization/translations.dart';
import '../../core/localization/app_languages.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final appointmentsAsync = ref.watch(appointmentsProvider);
    final l10n = context.l10n(ref);
    final currentLang = ref.watch(languageProvider);

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
                Text(l10n.appointmentsTitle, style: Theme.of(context).textTheme.displayMedium),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showAddAppointmentDialog(context, ref, l10n),
                      icon: const Icon(LucideIcons.plus),
                      label: Text(l10n.appointmentsAddButton),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Calendar Area
                  Expanded(
                    flex: 3,
                    child: Card(
                      child: Column(
                        children: [
                          TableCalendar(
                            locale: currentLang == AppLanguage.en ? 'en_US' : 'bg_BG',
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: _focusedDay,
                            calendarFormat: _calendarFormat,
                            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                            eventLoader: (day) {
                              final apts = appointmentsAsync.valueOrNull ?? [];
                              return apts.where((apt) => isSameDay(apt.date, day)).toList();
                            },
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                            },
                            onFormatChanged: (format) {
                              if (_calendarFormat != format) {
                                setState(() {
                                  _calendarFormat = format;
                                });
                              }
                            },
                            onPageChanged: (focusedDay) {
                              _focusedDay = focusedDay;
                            },
                            headerStyle: HeaderStyle(
                              formatButtonVisible: true,
                              titleCentered: true,
                              formatButtonDecoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                              ),
                              formatButtonTextStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                            ),
                            calendarStyle: CalendarStyle(
                              selectedDecoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              todayDecoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              markerDecoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: appointmentsAsync.when(
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (err, stack) => Center(child: Text('Error: $err')),
                              data: (appointments) {
                                // Filter by selected day
                                final dayApts = appointments.where((apt) => isSameDay(apt.date, _selectedDay)).toList();
                                dayApts.sort((a, b) => a.actualDateTime.compareTo(b.actualDateTime));
                                if (dayApts.isEmpty) {
                                  return Center(
                                    child: Text(l10n.appointmentsNoApptsDay, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                                  );
                                }
                                return ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: dayApts.length,
                                  itemBuilder: (context, index) {
                                    final apt = dayApts[index];
                                    return _buildDailyAppointmentCard(apt, l10n);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  
                  // Specific Day Side Panel Overview
                  Expanded(
                    flex: 1,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.appointmentsTodaySchedule, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text(DateFormat('EEEE, MMMM dd', currentLang == AppLanguage.en ? 'en_US' : 'bg_BG').format(DateTime.now()), style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                          const Divider(height: 32),
                          
                          Expanded(
                            child: appointmentsAsync.when(
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (err, stack) => Center(child: Text('Error: $err')),
                              data: (appointments) {
                                final todayApts = appointments.where((apt) => isSameDay(apt.date, DateTime.now())).toList();
                                todayApts.sort((a, b) => a.actualDateTime.compareTo(b.actualDateTime));
                                return ListView.separated(
                                  itemCount: todayApts.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    return _buildCompactAptCard(todayApts[index], l10n);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyAppointmentCard(Appointment apt, Translations l10n) {
    return GestureDetector(
      onTap: () => showAppointmentDetailsModal(context, ref, apt),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: apt.color.withOpacity(0.05),
          border: Border(left: BorderSide(color: apt.color, width: 4)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(apt.time, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(apt.patientName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
                        const SizedBox(height: 4),
                        Text('${apt.place == 'Clinic' ? l10n.appointmentsPlaceClinic : l10n.appointmentsPlaceHome} (${apt.procedures.map((p) => '${p.procedure} - ${p.type}').join(', ')}) • ID: ${apt.patientId}', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(icon: const Icon(LucideIcons.pencil, color: AppTheme.primaryBlue, size: 20), onPressed: () => _showEditAppointmentDialog(context, ref, apt, l10n)),
                IconButton(icon: const Icon(LucideIcons.trash2, color: AppTheme.error, size: 20), onPressed: () => _confirmDeleteAppointment(context, ref, apt, l10n)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAppointment(BuildContext context, WidgetRef ref, Appointment apt, Translations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.appointmentsDialogCancelTitle),
        content: Text('${l10n.appointmentsDialogCancelConfirm}\n\n${apt.patientName}'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.appointmentsDialogCancelNo)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              final inventory = ref.read(inventoryProvider).valueOrNull ?? [];
              for (final entry in apt.usedItems.entries) {
                final itemOpt = inventory.where((i) => i.id == entry.key).firstOrNull;
                if (itemOpt != null) {
                  final updatedItem = InventoryItem(
                    id: itemOpt.id,
                    name: itemOpt.name,
                    category: itemOpt.category,
                    expirationDate: itemOpt.expirationDate,
                    quantity: itemOpt.quantity + entry.value,
                  );
                  ref.read(inventoryProvider.notifier).updateItem(updatedItem);
                }
              }

              ref.read(appointmentsProvider.notifier).deleteAppointment(apt.id);
              Navigator.of(ctx).pop();
            },
            child: Text(l10n.appointmentsDialogCancelYes),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showAddAppointmentDialog(BuildContext context, WidgetRef ref, Translations l10n) {
    final patientsAsync = ref.read(patientsProvider);
    if (patientsAsync.value == null || patientsAsync.value!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.appointmentsErrorNoPatients)));
      return;
    }

    final proceduresMap = ref.read(proceduresProvider).valueOrNull ?? {};
    final procedures = proceduresMap.keys.toList();
    if (procedures.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.appointmentsErrorNoProcedures)));
      return;
    }
    final formKey = GlobalKey<FormState>();
    Patient? selectedPatient;
    String? selectedPlace = 'Clinic';
    final pStart = procedures.contains('IV') ? 'IV' : procedures.first;
    List<ProcedureSelection> selectedProcedures = [
      ProcedureSelection(procedure: pStart, type: proceduresMap[pStart]!.first)
    ];
    DateTime selectedDate = _selectedDay ?? DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text(l10n.appointmentsDialogAddTitle),
          content: SizedBox(
            width: 500,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Autocomplete<Patient>(
                      displayStringForOption: (Patient option) => '${option.name} (ID: ${option.id})',
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return patientsAsync.valueOrNull ?? [];
                        }
                        return (patientsAsync.valueOrNull ?? []).where((Patient p) {
                          final query = textEditingValue.text.toLowerCase();
                          return p.name.toLowerCase().contains(query) ||
                                 p.id.toLowerCase().contains(query) ||
                                 p.egn.contains(query) ||
                                 p.phone.contains(query);
                        });
                      },
                      onSelected: (Patient selection) => setModalState(() => selectedPatient = selection),
                      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: l10n.appointmentsFieldSearchPatient,
                            hintText: l10n.appointmentsFieldSearchHint,
                            prefixIcon: const Icon(LucideIcons.search, size: 20),
                            border: const OutlineInputBorder()
                          ),
                          validator: (val) => selectedPatient == null ? l10n.appointmentsFieldSearchPatient : null,
                          onChanged: (val) {
                             if (selectedPatient != null) setModalState(() => selectedPatient = null);
                          },
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            borderRadius: BorderRadius.circular(8),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 200, maxWidth: 450),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final Patient option = options.elementAt(index);
                                  return InkWell(
                                    onTap: () => onSelected(option),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(option.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Text('ID: ${option.id} • Phone: ${option.phone}', style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.utc(2020),
                                lastDate: DateTime.utc(2030),
                              );
                              if (d != null) setModalState(() => selectedDate = d);
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(labelText: l10n.appointmentsFieldDate, border: const OutlineInputBorder()),
                              child: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final t = await showTimePicker(context: context, initialTime: selectedTime);
                              if (t != null) setModalState(() => selectedTime = t);
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(labelText: l10n.appointmentsFieldTime, border: const OutlineInputBorder()),
                              child: Text(selectedTime.format(context)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedPlace,
                      decoration: InputDecoration(labelText: l10n.appointmentsFieldPlace, border: const OutlineInputBorder()),
                      items: [
                        DropdownMenuItem(value: 'Clinic', child: Text(l10n.appointmentsPlaceClinic)),
                        DropdownMenuItem(value: 'Home Visit', child: Text(l10n.appointmentsPlaceHome)),
                      ],
                      onChanged: (val) => setModalState(() => selectedPlace = val),
                    ),
                    const SizedBox(height: 16),
                    ...selectedProcedures.asMap().entries.map((entry) {
                      final int idx = entry.key;
                      final ProcedureSelection sel = entry.value;
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: sel.procedure,
                                  decoration: InputDecoration(labelText: l10n.appointmentsFieldProcedure, border: const OutlineInputBorder()),
                                  items: procedures.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                                  onChanged: (val) => setModalState(() {
                                    selectedProcedures[idx] = ProcedureSelection(procedure: val!, type: proceduresMap[val]!.first);
                                  }),
                                ),
                              ),
                              if (selectedProcedures.length > 1) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(LucideIcons.trash2, color: AppTheme.error),
                                  onPressed: () => setModalState(() => selectedProcedures.removeAt(idx)),
                                )
                              ]
                            ]
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: sel.type,
                            decoration: InputDecoration(labelText: l10n.appointmentsFieldType, border: const OutlineInputBorder()),
                            items: (proceduresMap[sel.procedure] ?? ['General']).map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                            onChanged: (val) => setModalState(() {
                              selectedProcedures[idx] = ProcedureSelection(procedure: sel.procedure, type: val!);
                            }),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }).toList(),
                    TextButton.icon(
                      onPressed: () => setModalState(() {
                        final proc = procedures.first;
                        selectedProcedures.add(ProcedureSelection(procedure: proc, type: proceduresMap[proc]!.first));
                      }),
                      icon: const Icon(LucideIcons.plus),
                      label: Text(l10n.settingsProceduresAdd),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: InputDecoration(labelText: l10n.appointmentsFieldNotes, border: const OutlineInputBorder()),
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
                  final newApt = Appointment(
                    id: 'A-${DateTime.now().millisecondsSinceEpoch}',
                    patientId: selectedPatient!.id,
                    patientName: selectedPatient!.name,
                    date: selectedDate,
                    time: selectedTime.format(context),
                    doctorId: 'D-1', // Default
                    place: selectedPlace!,
                    procedures: selectedProcedures,
                    color: selectedPlace == 'Home Visit' ? const Color(0xFFF59E0B) : const Color(0xFF3B82F6),
                    notes: notesController.text,
                  );
                  ref.read(appointmentsProvider.notifier).addAppointment(newApt);
                  Navigator.of(ctx).pop();
                }
              },
              child: Text(l10n.appointmentsFieldSchedule),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  void _showEditAppointmentDialog(BuildContext context, WidgetRef ref, Appointment apt, Translations l10n) {
    final proceduresMap = ref.read(proceduresProvider).valueOrNull ?? {};
    final procedures = proceduresMap.keys.toList();
    final formKey = GlobalKey<FormState>();
    String? selectedPlace = ['Clinic', 'Home Visit'].contains(apt.place) ? apt.place : 'Clinic';
    List<ProcedureSelection> selectedProcedures = apt.procedures.isNotEmpty 
        ? List.from(apt.procedures) 
        : [ProcedureSelection(procedure: procedures.first, type: proceduresMap[procedures.first]!.first)];
    DateTime selectedDate = apt.date;
    
    // Parse existing time
    TimeOfDay selectedTime = TimeOfDay.now();
    try {
      final parts = apt.time.split(' ');
      final hm = parts[0].split(':');
      int h = int.parse(hm[0]);
      int m = int.parse(hm[1]);
      if (parts.length > 1 && parts[1].toUpperCase() == 'PM' && h < 12) h += 12;
      if (parts.length > 1 && parts[1].toUpperCase() == 'AM' && h == 12) h = 0;
      selectedTime = TimeOfDay(hour: h, minute: m);
    } catch (_) {}

    final notesController = TextEditingController(text: apt.notes);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text('${l10n.appointmentsDialogEditTitle}: ${apt.patientName}'),
          content: SizedBox(
            width: 500,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.utc(2020),
                              lastDate: DateTime.utc(2030),
                            );
                            if (d != null) setModalState(() => selectedDate = d);
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(labelText: l10n.appointmentsFieldDate, border: const OutlineInputBorder()),
                            child: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final t = await showTimePicker(context: context, initialTime: selectedTime);
                            if (t != null) setModalState(() => selectedTime = t);
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(labelText: l10n.appointmentsFieldTime, border: const OutlineInputBorder()),
                            child: Text(selectedTime.format(context)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedPlace,
                    decoration: InputDecoration(labelText: l10n.appointmentsFieldPlace, border: const OutlineInputBorder()),
                    items: [
                      DropdownMenuItem(value: 'Clinic', child: Text(l10n.appointmentsPlaceClinic)),
                      DropdownMenuItem(value: 'Home Visit', child: Text(l10n.appointmentsPlaceHome)),
                    ],
                    onChanged: (val) => setModalState(() => selectedPlace = val),
                  ),
                  const SizedBox(height: 16),
                  ...selectedProcedures.asMap().entries.map((entry) {
                    final int idx = entry.key;
                    final ProcedureSelection sel = entry.value;
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: sel.procedure,
                                decoration: InputDecoration(labelText: l10n.appointmentsFieldProcedure, border: const OutlineInputBorder()),
                                items: procedures.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                                onChanged: (val) => setModalState(() {
                                  selectedProcedures[idx] = ProcedureSelection(procedure: val!, type: proceduresMap[val]!.first);
                                }),
                              ),
                            ),
                            if (selectedProcedures.length > 1) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(LucideIcons.trash2, color: AppTheme.error),
                                onPressed: () => setModalState(() => selectedProcedures.removeAt(idx)),
                              )
                            ]
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: sel.type,
                          decoration: InputDecoration(labelText: l10n.appointmentsFieldType, border: const OutlineInputBorder()),
                          items: (proceduresMap[sel.procedure] ?? ['General']).map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                          onChanged: (val) => setModalState(() {
                            selectedProcedures[idx] = ProcedureSelection(procedure: sel.procedure, type: val!);
                          }),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                  TextButton.icon(
                    onPressed: () => setModalState(() {
                      final proc = procedures.first;
                      selectedProcedures.add(ProcedureSelection(procedure: proc, type: proceduresMap[proc]!.first));
                    }),
                    icon: const Icon(LucideIcons.plus),
                    label: const Text('Add Procedure'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notesController,
                    maxLines: 2,
                    decoration: InputDecoration(labelText: l10n.appointmentsFieldNotes, border: const OutlineInputBorder()),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.commonCancel)),
            ElevatedButton(
              onPressed: () {
                final updatedApt = Appointment(
                  id: apt.id,
                  patientId: apt.patientId,
                  patientName: apt.patientName,
                  date: selectedDate,
                  time: selectedTime.format(context),
                  doctorId: apt.doctorId,
                  place: selectedPlace!,
                  procedures: selectedProcedures,
                  color: selectedPlace == 'Home Visit' ? const Color(0xFFF59E0B) : const Color(0xFF3B82F6),
                  notes: notesController.text,
                  usedItems: apt.usedItems, // Retain existing used items silently
                );
                ref.read(appointmentsProvider.notifier).updateAppointment(updatedApt);
                Navigator.of(ctx).pop();
              },
              child: Text(l10n.patientsSaveChanges),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildCompactAptCard(Appointment apt, Translations l10n) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => showAppointmentDetailsModal(context, ref, apt),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: apt.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(LucideIcons.clock, color: apt.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(apt.patientName, style: TextStyle(fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
                  Text('${apt.time} - ${apt.place == 'Clinic' ? l10n.appointmentsPlaceClinic : l10n.appointmentsPlaceHome} (${apt.procedures.map((p) => '${p.procedure} - ${p.type}').join(', ')})', style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
