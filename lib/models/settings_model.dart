import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

/// Modello per gestire le impostazioni dell'app
class SettingsModel {
  Set<int> selectedDays;
  TimeOfDay startTime;
  TimeOfDay endTime;

  SettingsModel({
    required this.selectedDays,
    required this.startTime,
    required this.endTime,
  });

  /// Costruttore con valori di default (Lun-Ven, 16:00-19:00)
  factory SettingsModel.defaultSettings() {
    return SettingsModel(
      selectedDays: {1, 2, 3, 4, 5}, // Lunedì-Venerdì
      startTime: const TimeOfDay(hour: 16, minute: 0),
      endTime: const TimeOfDay(hour: 19, minute: 0),
    );
  }

  /// Carica le impostazioni da SharedPreferences
  static Future<SettingsModel> load() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Carica giorni selezionati
    final daysString = prefs.getString('notification_days') ?? '1,2,3,4,5';
    final days = daysString.split(',').map((e) => int.parse(e)).toSet();
    
    // Carica orari
    final startHour = prefs.getInt('start_hour') ?? 16;
    final startMinute = prefs.getInt('start_minute') ?? 0;
    final endHour = prefs.getInt('end_hour') ?? 19;
    final endMinute = prefs.getInt('end_minute') ?? 0;
    
    return SettingsModel(
      selectedDays: days,
      startTime: TimeOfDay(hour: startHour, minute: startMinute),
      endTime: TimeOfDay(hour: endHour, minute: endMinute),
    );
  }

  /// Salva le impostazioni in SharedPreferences
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Salva giorni selezionati
    final daysString = selectedDays.toList()..sort();
    await prefs.setString('notification_days', daysString.join(','));
    
    // Salva orari
    await prefs.setInt('start_hour', startTime.hour);
    await prefs.setInt('start_minute', startTime.minute);
    await prefs.setInt('end_hour', endTime.hour);
    await prefs.setInt('end_minute', endTime.minute);
  }

  /// Verifica se un dato momento è nell'orario configurato
  bool isInTimeRange(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    
    // Converti orari in minuti totali per confronto
    final currentMinutes = hour * 60 + minute;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    
    return currentMinutes >= startMinutes && currentMinutes < endMinutes;
  }

  /// Verifica se un dato giorno è abilitato per le notifiche
  bool isDayEnabled(int weekday) {
    return selectedDays.contains(weekday);
  }

  /// Verifica se dovrebbe inviare notifiche in questo momento
  bool shouldNotifyNow(DateTime dateTime) {
    return isDayEnabled(dateTime.weekday) && isInTimeRange(dateTime);
  }
}
