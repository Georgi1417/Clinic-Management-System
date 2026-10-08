import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SupabaseService {
  static final _supabase = Supabase.instance.client;

  // Patients
  static Future<List<Patient>> getPatients() async {
    final response = await _supabase.from('patients').select().order('created_at');
    final data = response as List<dynamic>? ?? [];
    return data.map((json) => Patient.fromJson(json as Map<String, dynamic>)).toList();
  }

  static Future<Patient> insertPatient(Patient patient) async {
    final data = await _supabase.from('patients').insert(patient.toJson()).select().single();
    return Patient.fromJson(data);
  }

  static Future<Patient> updatePatient(Patient patient) async {
    final data = await _supabase.from('patients').update(patient.toJson()).eq('display_id', patient.id).select().single();
    return Patient.fromJson(data);
  }

  static Future<void> deletePatient(String id) async {
    await _supabase.from('patients').delete().eq('display_id', id);
  }

  // Appointments
  static Future<List<Appointment>> getAppointments() async {
    final response = await _supabase.from('appointments').select().order('created_at');
    final data = response as List<dynamic>? ?? [];
    return data.map((json) => Appointment.fromJson(json as Map<String, dynamic>)).toList();
  }

  static Future<Appointment> insertAppointment(Appointment appointment) async {
    final data = await _supabase.from('appointments').insert(appointment.toJson()).select().single();
    return Appointment.fromJson(data);
  }

  static Future<Appointment> updateAppointment(Appointment appointment) async {
    final data = await _supabase.from('appointments').update(appointment.toJson()).eq('display_id', appointment.id).select().single();
    return Appointment.fromJson(data);
  }

  static Future<void> deleteAppointment(String id) async {
    await _supabase.from('appointments').delete().eq('display_id', id);
  }

  // Inventory
  static Future<List<InventoryItem>> getInventory() async {
    final response = await _supabase.from('inventory').select().order('created_at');
    final data = response as List<dynamic>? ?? [];
    return data.map((json) => InventoryItem.fromJson(json as Map<String, dynamic>)).toList();
  }

  static Future<InventoryItem> insertInventoryItem(InventoryItem item) async {
    final data = await _supabase.from('inventory').insert(item.toJson()).select().single();
    return InventoryItem.fromJson(data);
  }

  static Future<InventoryItem> updateInventoryItem(InventoryItem item) async {
    final data = await _supabase.from('inventory').update(item.toJson()).eq('display_id', item.id).select().single();
    return InventoryItem.fromJson(data);
  }

  static Future<void> deleteInventoryItem(String id) async {
    await _supabase.from('inventory').delete().eq('display_id', id);
  }

  // Storage Config
  static Future<Map<String, List<String>>> getStorageConfig() async {
    final response = await _supabase.from('storage_config').select();
    final data = response as List<dynamic>? ?? [];
    final Map<String, List<String>> categories = {};
    for (var row in data) {
      final String name = row['category_name'];
      final List<dynamic> itemsData = row['items'] ?? [];
      categories[name] = itemsData.map((e) => e.toString()).toList();
    }
    return categories;
  }

  static Future<void> updateStorageCategoryItems(String categoryName, List<String> items) async {
    await _supabase.from('storage_config').upsert({
      'category_name': categoryName,
      'items': items,
    }, onConflict: 'category_name');
  }

  static Future<void> insertStorageCategory(String categoryName) async {
     await _supabase.from('storage_config').insert({
      'category_name': categoryName,
      'items': [],
    });
  }

  static Future<void> deleteStorageCategory(String categoryName) async {
    await _supabase.from('storage_config').delete().eq('category_name', categoryName);
  }

  // Procedures
  static Future<Map<String, List<String>>> getProcedures() async {
    final response = await _supabase.from('procedures_config').select();
    final data = response as List<dynamic>? ?? [];
    final Map<String, List<String>> procedures = {};
    for (var row in data) {
      final String name = row['procedure_name'];
      final List<dynamic> subsData = row['sub_types'] ?? [];
      procedures[name] = subsData.map((e) => e.toString()).toList();
    }
    return procedures;
  }

  static Future<void> updateProcedureSubTypes(String procedureName, List<String> subTypes) async {
    // Upsert or just update based on name
    await _supabase.from('procedures_config').upsert({
      'procedure_name': procedureName,
      'sub_types': subTypes,
    }, onConflict: 'procedure_name');
  }

  static Future<void> insertProcedure(String procedureName) async {
     await _supabase.from('procedures_config').insert({
      'procedure_name': procedureName,
      'sub_types': ['General'],
    });
  }

  static Future<void> deleteProcedure(String procedureName) async {
    await _supabase.from('procedures_config').delete().eq('procedure_name', procedureName);
  }
}
