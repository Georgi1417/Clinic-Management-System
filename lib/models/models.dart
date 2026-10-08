import 'package:flutter/material.dart';
import 'dart:convert';

class ProcedureSelection {
  final String procedure;
  final String type;

  ProcedureSelection({required this.procedure, required this.type});

  factory ProcedureSelection.fromJson(Map<String, dynamic> json) => ProcedureSelection(
        procedure: json['procedure'] as String? ?? '',
        type: json['type'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'procedure': procedure,
        'type': type,
      };

  @override
  String toString() => '$procedure - $type';
}

class Patient {
  final String id;
  final String name;
  final String egn;
  final String phone;
  final String email;
  final DateTime? lastVisit;
  final String ills;

  Patient({
    required this.id,
    required this.name,
    required this.egn,
    required this.phone,
    required this.email,
    this.lastVisit,
    this.ills = '',
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['display_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      egn: json['egn'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      lastVisit: json['last_visit'] != null ? DateTime.parse(json['last_visit']) : null,
      ills: json['ills'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'display_id': id,
      'name': name,
      'egn': egn,
      'phone': phone,
      'email': email,
      'last_visit': lastVisit?.toIso8601String(),
      'ills': ills,
    };
  }

  String get initials {
    List<String> names = name.split(" ");
    if (names.length > 1) {
      return names[0][0] + names[names.length - 1][0];
    }
    return name.isNotEmpty ? name[0] : '';
  }
}

class InventoryItem {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final DateTime? expirationDate;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    this.expirationDate,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['display_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      quantity: json['quantity'] is num ? (json['quantity'] as num).toInt() : int.tryParse(json['quantity'].toString()) ?? 0,
      expirationDate: json['expiration_date'] != null ? DateTime.tryParse(json['expiration_date'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'display_id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'expiration_date': expirationDate?.toIso8601String(),
    };
  }
}

class Appointment {
  final String id;
  final String patientId;
  final String patientName;
  final DateTime date;
  final String time;
  final String doctorId;
  final String place; // 'Clinic' or 'Home Visit'
  final List<ProcedureSelection> procedures;
  final Color color;
  final String? notes;
  final Map<String, int> usedItems;

  Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.date,
    required this.time,
    required this.doctorId,
    required this.place,
    required this.procedures,
    required this.color,
    this.notes,
    this.usedItems = const {},
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    Color parsedColor = Colors.blue; 
    if (json['color'] != null) {
      String hexColor = json['color'].toString().replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      parsedColor = Color(int.parse(hexColor, radix: 16));
    }

    Map<String, int> parsedItems = {};
    if (json['used_items'] != null) {
      try {
        final itemsMap = json['used_items'] as Map;
        parsedItems = itemsMap.map((key, value) => MapEntry(key.toString(), (value as num).toInt()));
      } catch (e) {
        print("Error parsing used_items: $e");
      }
    }

    List<ProcedureSelection> proceduresList = [];
    if (json['procedure'] != null) {
      final rawProc = json['procedure'];
      if (rawProc is List) {
        proceduresList = rawProc.map((e) => ProcedureSelection.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      } else {
        final procStr = rawProc.toString();
        if (procStr.trim().startsWith('[')) {
          try {
            dynamic decoded = jsonDecode(procStr);
            if (decoded is String) decoded = jsonDecode(decoded); // Handle double encoding
            
            if (decoded is List) {
              proceduresList = decoded.map((e) => ProcedureSelection.fromJson(Map<String, dynamic>.from(e as Map))).toList();
            } else {
              proceduresList.add(ProcedureSelection(procedure: procStr, type: json['procedure_type'] as String? ?? ''));
            }
          } catch (_) {
            proceduresList.add(ProcedureSelection(procedure: procStr, type: json['procedure_type'] as String? ?? ''));
          }
        } else {
          proceduresList.add(ProcedureSelection(procedure: procStr, type: json['procedure_type'] as String? ?? ''));
        }
      }
    }

    return Appointment(
      id: json['display_id'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? '',
      patientName: json['patient_name'] as String? ?? '',
      date: json['appointment_date'] != null ? DateTime.parse(json['appointment_date']) : DateTime.now(),
      time: json['appointment_time'] as String? ?? '',
      doctorId: json['doctor_id'] as String? ?? '',
      place: json['place'] as String? ?? '',
      procedures: proceduresList,
      color: parsedColor,
      notes: json['notes'] as String?,
      usedItems: parsedItems,
    );
  }

  Map<String, dynamic> toJson() {
    String hexColor = color.value.toRadixString(16).padLeft(8, '0').toUpperCase();
    return {
      'display_id': id,
      'patient_id': patientId,
      'patient_name': patientName,
      'appointment_date': "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      'appointment_time': time,
      'doctor_id': doctorId,
      'place': place,
      'procedure': procedures.isEmpty ? '' : jsonEncode(procedures.map((p) => p.toJson()).toList()),
      'procedure_type': procedures.isEmpty ? '' : procedures.first.type,
      'color': '#$hexColor',
      'notes': notes,
      'used_items': usedItems,
    };
  }

  DateTime get actualDateTime {
    int hour = date.hour;
    int min = date.minute;
    try {
      List<String> parts = time.split(' ');
      List<String> hm = parts[0].split(':');
      hour = int.parse(hm[0]);
      min = int.parse(hm[1]);
      if (parts.length > 1 && parts[1].toUpperCase() == 'PM' && hour < 12) {
        hour += 12;
      } else if (parts.length > 1 && parts[1].toUpperCase() == 'AM' && hour == 12) {
        hour = 0;
      }
    } catch (_) {}
    return DateTime(date.year, date.month, date.day, hour, min);
  }
}
