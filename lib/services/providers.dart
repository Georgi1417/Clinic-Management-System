import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'supabase_service.dart';

// Patients Notifier
class PatientsNotifier extends AsyncNotifier<List<Patient>> {
  @override
  Future<List<Patient>> build() async {
    return await SupabaseService.getPatients();
  }

  Future<void> addPatient(Patient patient) async {
    final currentList = state.valueOrNull ?? [];
    try {
      final newPatient = await SupabaseService.insertPatient(patient);
      state = AsyncData([...currentList, newPatient]);
    } catch (e, st) {
      state = AsyncError(e, st);
      print('Error adding patient: $e');
    }
  }

  Future<void> updatePatient(Patient updatedPatient) async {
    final currentList = state.valueOrNull ?? [];
    try {
      final returnedPatient = await SupabaseService.updatePatient(updatedPatient);
      state = AsyncData(currentList.map((p) => p.id == returnedPatient.id ? returnedPatient : p).toList());
    } catch (e, st) {
      state = AsyncError(e, st);
      print('Error updating patient: $e');
    }
  }

  Future<void> deletePatient(String id) async {
    final currentList = state.valueOrNull ?? [];
    try {
      await SupabaseService.deletePatient(id);
      state = AsyncData(currentList.where((p) => p.id != id).toList());
    } catch (e, st) {
      state = AsyncError(e, st);
      print('Error deleting patient: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      final ids = (state.valueOrNull ?? []).map((e) => e.id).toList();
      for (final id in ids) {
        await SupabaseService.deletePatient(id);
      }
      state = const AsyncData([]);
    } catch(e) {
      print('Error clearing patients: $e');
    }
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => SupabaseService.getPatients());
  }
}

final patientsProvider = AsyncNotifierProvider<PatientsNotifier, List<Patient>>(() {
  return PatientsNotifier();
});

// Appointments Notifier
class AppointmentsNotifier extends AsyncNotifier<List<Appointment>> {
  @override
  Future<List<Appointment>> build() async {
    return await SupabaseService.getAppointments();
  }

  Future<void> addAppointment(Appointment appointment) async {
    final currentList = state.valueOrNull ?? [];
    try {
      final newAppt = await SupabaseService.insertAppointment(appointment);
      state = AsyncData([...currentList, newAppt]);
    } catch (e, st) {
      state = AsyncError(e, st);
      print('Error adding appointment: $e');
    }
  }

  Future<void> updateAppointment(Appointment updatedAppointment) async {
    final currentList = state.valueOrNull ?? [];
    try {
      final returnedAppt = await SupabaseService.updateAppointment(updatedAppointment);
      state = AsyncData(currentList.map((a) => a.id == returnedAppt.id ? returnedAppt : a).toList());
    } catch (e, st) {
      state = AsyncError(e, st);
      print('Error updating appointment: $e');
    }
  }

  Future<void> deleteAppointment(String id) async {
    final currentList = state.valueOrNull ?? [];
    try {
      await SupabaseService.deleteAppointment(id);
      state = AsyncData(currentList.where((a) => a.id != id).toList());
    } catch (e, st) {
      state = AsyncError(e, st);
      print('Error deleting appointment: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      final ids = (state.valueOrNull ?? []).map((e) => e.id).toList();
      for (final id in ids) {
        await SupabaseService.deleteAppointment(id);
      }
      state = const AsyncData([]);
    } catch(e) {
      print('Error clearing appointments: $e');
    }
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => SupabaseService.getAppointments());
  }
}

final appointmentsProvider = AsyncNotifierProvider<AppointmentsNotifier, List<Appointment>>(() {
  return AppointmentsNotifier();
});

// Inventory Notifier
class InventoryNotifier extends AsyncNotifier<List<InventoryItem>> {
  @override
  Future<List<InventoryItem>> build() async {
    return await SupabaseService.getInventory();
  }

  Future<void> addItem(InventoryItem item) async {
    final currentList = state.valueOrNull ?? [];
    try {
      final newItem = await SupabaseService.insertInventoryItem(item);
      state = AsyncData([...currentList, newItem]);
    } catch (e) {
      print('Error adding inventory: $e');
    }
  }

  Future<void> updateItem(InventoryItem updatedItem) async {
    final currentList = state.valueOrNull ?? [];
    try {
      final returnedItem = await SupabaseService.updateInventoryItem(updatedItem);
      state = AsyncData(currentList.map((i) => i.id == returnedItem.id ? returnedItem : i).toList());
    } catch (e) {
      print('Error updating inventory: $e');
    }
  }

  Future<void> deleteItem(String id) async {
    final currentList = state.valueOrNull ?? [];
    try {
      await SupabaseService.deleteInventoryItem(id);
      state = AsyncData(currentList.where((i) => i.id != id).toList());
    } catch (e) {
      print('Error deleting inventory: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      final ids = (state.valueOrNull ?? []).map((e) => e.id).toList();
      for (final id in ids) {
        await SupabaseService.deleteInventoryItem(id);
      }
      state = const AsyncData([]);
    } catch(e) {
      print('Error clearing inventory: $e');
    }
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => SupabaseService.getInventory());
  }
}

final inventoryProvider = AsyncNotifierProvider<InventoryNotifier, List<InventoryItem>>(() {
  return InventoryNotifier();
});

// Procedures Management
class ProceduresNotifier extends AsyncNotifier<Map<String, List<String>>> {
  @override
  Future<Map<String, List<String>>> build() async {
    return await SupabaseService.getProcedures();
  }

  Future<void> addProcedure(String proc) async {
    final currentState = state.valueOrNull ?? {};
    if (!currentState.containsKey(proc)) {
      try {
        await SupabaseService.insertProcedure(proc);
        state = AsyncData({...currentState, proc: ['General']});
      } catch (e) {
        print('Error adding procedure: $e');
      }
    }
  }

  Future<void> removeProcedure(String proc) async {
    final currentState = Map<String, List<String>>.from(state.valueOrNull ?? {});
    try {
      await SupabaseService.deleteProcedure(proc);
      currentState.remove(proc);
      state = AsyncData(currentState);
    } catch (e) {
      print('Error removing procedure: $e');
    }
  }

  Future<void> addSubType(String proc, String subType) async {
    final currentState = state.valueOrNull ?? {};
    if (currentState.containsKey(proc)) {
      final currentSubTypes = List<String>.from(currentState[proc]!);
      if (!currentSubTypes.contains(subType)) {
        final newSubTypes = [...currentSubTypes, subType];
        try {
          await SupabaseService.updateProcedureSubTypes(proc, newSubTypes);
          state = AsyncData({
            ...currentState,
            proc: newSubTypes,
          });
        } catch (e) {
           print('Error adding procedure subtype: $e');
        }
      }
    }
  }

  Future<void> removeSubType(String proc, String subType) async {
    final currentState = state.valueOrNull ?? {};
    if (currentState.containsKey(proc)) {
      final currentSubTypes = List<String>.from(currentState[proc]!);
      if (currentSubTypes.length > 1) {
        final newSubTypes = currentSubTypes.where((s) => s != subType).toList();
        try {
          await SupabaseService.updateProcedureSubTypes(proc, newSubTypes);
          state = AsyncData({
            ...currentState,
            proc: newSubTypes,
          });
        } catch (e) {
          print('Error removing procedure subtype: $e');
        }
      }
    }
  }

  Future<void> clearAll() async {
    // Optional implementation if needed
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => SupabaseService.getProcedures());
  }
}

final proceduresProvider = AsyncNotifierProvider<ProceduresNotifier, Map<String, List<String>>>(() {
  return ProceduresNotifier();
});

// Storage Config Management
class StorageConfigNotifier extends AsyncNotifier<Map<String, List<String>>> {
  @override
  Future<Map<String, List<String>>> build() async {
    return await SupabaseService.getStorageConfig();
  }

  Future<void> addCategory(String category) async {
    final currentState = state.valueOrNull ?? {};
    if (!currentState.containsKey(category)) {
      try {
        await SupabaseService.insertStorageCategory(category);
        state = AsyncData({...currentState, category: []});
      } catch (e, st) {
        state = AsyncError(e, st);
        print('Error adding storage category: $e');
      }
    }
  }

  Future<void> removeCategory(String category) async {
    final currentState = Map<String, List<String>>.from(state.valueOrNull ?? {});
    try {
      await SupabaseService.deleteStorageCategory(category);
      currentState.remove(category);
      state = AsyncData(currentState);
    } catch (e, st) {
      state = AsyncError(e, st);
      print('Error removing storage category: $e');
    }
  }

  Future<void> addItem(String category, String item) async {
    final currentState = state.valueOrNull ?? {};
    if (currentState.containsKey(category)) {
      final currentItems = List<String>.from(currentState[category]!);
      if (!currentItems.contains(item)) {
        final newItems = [...currentItems, item];
        try {
          await SupabaseService.updateStorageCategoryItems(category, newItems);
          state = AsyncData({
            ...currentState,
            category: newItems,
          });
        } catch (e, st) {
          state = AsyncError(e, st);
          print('Error adding storage item: $e');
        }
      }
    }
  }

  Future<void> removeItem(String category, String item) async {
    final currentState = state.valueOrNull ?? {};
    if (currentState.containsKey(category)) {
      final currentItems = List<String>.from(currentState[category]!);
      final newItems = currentItems.where((s) => s != item).toList();
      try {
        await SupabaseService.updateStorageCategoryItems(category, newItems);
        state = AsyncData({
          ...currentState,
          category: newItems,
        });
      } catch (e, st) {
        state = AsyncError(e, st);
        print('Error removing storage item: $e');
      }
    }
  }

  Future<void> clearAll() async {
    // Optional implementation if needed
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => SupabaseService.getStorageConfig());
  }
}

final storageConfigProvider = AsyncNotifierProvider<StorageConfigNotifier, Map<String, List<String>>>(() {
  return StorageConfigNotifier();
});
