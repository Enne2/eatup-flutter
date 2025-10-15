import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/settings_model.dart';

/// Entry point per il foreground service
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MensaReminderTaskHandler());
}

/// Handler per il task in foreground che gestisce i promemoria della mensa
class MensaReminderTaskHandler extends TaskHandler {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('Mensa reminder service started at $timestamp');
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');
    
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    
    await _notificationsPlugin.initialize(initializationSettings);
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    final now = timestamp.toLocal();
    
    // Carica le impostazioni
    final settings = await SettingsModel.load();
    
    // Verifica se dovrebbe inviare notifiche ora
    if (!settings.shouldNotifyNow(now)) {
      return;
    }
    
    // Controlla se già prenotato o se ha detto "non vado"
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-DD').format(now);
    final lastActionDate = prefs.getString('last_action_date') ?? '';
    final actionType = prefs.getString('action_type') ?? '';
    
    // Se è un nuovo giorno, resetta lo stato
    if (lastActionDate != today) {
      await prefs.remove('last_action_date');
      await prefs.remove('action_type');
    } else if (actionType == 'booked' || actionType == 'not_going') {
      // Già gestito per oggi, non inviare notifica
      print('Already handled for today: $actionType');
      return;
    }
    
    // Invia notifica
    await _sendNotification();
  }

  Future<void> _sendNotification() async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'mensa_reminder',
      'Promemoria Mensa',
      channelDescription: 'Notifiche per ricordarti di prenotare la mensa',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: 'ic_notification',
      ticker: 'Ricorda di prenotare la mensa!',
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'already_booked',
          'Già fatto ✓',
          showsUserInterface: true,
        ),
        const AndroidNotificationAction(
          'not_going',
          'Domani non vado',
          showsUserInterface: true,
        ),
      ],
    );
    
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );
    
    await _notificationsPlugin.show(
      0,
      '🍽️ Promemoria Mensa',
      'Ricordati di prenotare la mensa per domani!',
      notificationDetails,
    );
    
    print('Notification sent at ${DateTime.now()}');
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print('Mensa reminder service destroyed at $timestamp');
  }
}

/// Service per gestire il foreground task e le notifiche
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inizializza il plugin delle notifiche
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  /// Gestisce il tap sulle notifiche
  static void _onNotificationTap(NotificationResponse response) async {
    if (response.actionId == 'already_booked') {
      await _markAsBooked();
    } else if (response.actionId == 'not_going') {
      await _markAsNotGoing();
    }
  }

  /// Marca come già prenotato
  static Future<void> _markAsBooked() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-DD').format(DateTime.now());
    await prefs.setString('last_action_date', today);
    await prefs.setString('action_type', 'booked');
    await cancelNotification();
  }

  /// Marca come "non vado domani"
  static Future<void> _markAsNotGoing() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-DD').format(DateTime.now());
    await prefs.setString('last_action_date', today);
    await prefs.setString('action_type', 'not_going');
    await cancelNotification();
  }

  /// Cancella le notifiche
  static Future<void> cancelNotification() async {
    await _notificationsPlugin.cancel(0);
  }

  /// Richiedi i permessi per le notifiche
  static Future<bool> requestPermissions() async {
    final bool? result = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    return result ?? false;
  }

  /// Avvia il foreground service
  static Future<bool> startForegroundService() async {
    print('🔵 [DEBUG] startForegroundService called');
    
    if (await FlutterForegroundTask.isRunningService) {
      print('⚠️  [DEBUG] Service already running, returning false');
      return false;
    }
    
    // Carica le impostazioni per mostrare l'intervallo orario
    final settings = await SettingsModel.load();
    final notificationText = _buildNotificationText(settings);
    
    print('🔵 [DEBUG] Initializing FlutterForegroundTask...');
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'mensa_service',
        channelName: 'Servizio Mensa',
        channelDescription: 'Servizio per promemoria prenotazione mensa',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(300000), // Controlla ogni 5 minuti
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
    
    print('🔵 [DEBUG] Starting foreground service with custom icon...');
    print('🔵 [DEBUG] Icon metadata name: notificationIcon');
    print('🔵 [DEBUG] Notification text: $notificationText');
    
    await FlutterForegroundTask.startService(
      serviceId: 256,
      notificationTitle: 'Servizio Promemoria Mensa',
      notificationText: notificationText,
      notificationIcon: const NotificationIcon(
        metaDataName: 'notificationIcon',
      ),
      callback: startCallback,
    );
    
    print('✅ [DEBUG] Foreground service started successfully');
    return true;
  }

  /// Costruisce il testo della notifica con l'intervallo orario
  static String _buildNotificationText(SettingsModel settings) {
    final days = <String>[];
    
    // Mappa dei giorni della settimana (1=Lun, 2=Mar, ecc.)
    const dayNames = {
      1: 'Lun',
      2: 'Mar',
      3: 'Mer',
      4: 'Gio',
      5: 'Ven',
      6: 'Sab',
      7: 'Dom',
    };
    
    // Costruisci lista giorni attivi
    for (final day in settings.selectedDays.toList()..sort()) {
      if (dayNames.containsKey(day)) {
        days.add(dayNames[day]!);
      }
    }
    
    final daysText = days.isEmpty ? 'Nessun giorno' : days.join(', ');
    
    // Formatta orari come HH:mm
    final startTime = '${settings.startTime.hour.toString().padLeft(2, '0')}:${settings.startTime.minute.toString().padLeft(2, '0')}';
    final endTime = '${settings.endTime.hour.toString().padLeft(2, '0')}:${settings.endTime.minute.toString().padLeft(2, '0')}';
    
    return 'Attivo: $daysText • $startTime-$endTime';
  }

  /// Ferma il foreground service
  static Future<bool> stopForegroundService() async {
    print('🔴 [DEBUG] stopForegroundService called');
    
    if (!await FlutterForegroundTask.isRunningService) {
      print('⚠️  [DEBUG] Service not running, returning false');
      return false;
    }
    
    print('🔴 [DEBUG] Stopping foreground service...');
    await FlutterForegroundTask.stopService();
    print('✅ [DEBUG] Foreground service stopped');
    return true;
  }

  /// Riavvia il foreground service (utile dopo cambio impostazioni)
  static Future<void> restartForegroundService() async {
    print('🔄 [DEBUG] restartForegroundService called');
    
    if (await FlutterForegroundTask.isRunningService) {
      print('🔄 [DEBUG] Service is running, stopping it first...');
      await stopForegroundService();
      await Future.delayed(const Duration(milliseconds: 500));
      print('🔄 [DEBUG] Now starting service again...');
      await startForegroundService();
    } else {
      print('⚠️  [DEBUG] Service was not running during restart attempt');
    }
  }

  /// Verifica se il servizio è in esecuzione
  static Future<bool> isServiceRunning() async {
    return await FlutterForegroundTask.isRunningService;
  }
}
