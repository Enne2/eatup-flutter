import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../widgets/status_card.dart';
import '../services/notification_service.dart';
import '../models/settings_model.dart';
import 'settings_screen.dart';

/// Schermata principale dell'app per gestire i promemoria della mensa
class HomeScreen extends StatefulWidget {
  final FlutterLocalNotificationsPlugin notificationsPlugin;
  
  const HomeScreen({super.key, required this.notificationsPlugin});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _permissionGranted = false;
  bool _serviceRunning = false;
  String _todayStatus = 'non_set';
  TimeOfDay? _endTime;
  Timer? _statusCheckTimer;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _checkServiceStatus();
    _checkTodayStatus();
    _loadSettings();
    
    // Aggiorna lo stato ogni 5 secondi
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkTodayStatus();
    });
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsModel.load();
    if (mounted) {
      setState(() {
        _endTime = settings.endTime;
      });
    }
  }

  Future<void> _checkTodayStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-DD').format(DateTime.now());
    final lastActionDate = prefs.getString('last_action_date') ?? '';
    final actionType = prefs.getString('action_type') ?? '';
    
    String status = 'non_set';
    if (lastActionDate == today) {
      status = actionType;
    }
    
    if (mounted && _todayStatus != status) {
      setState(() {
        _todayStatus = status;
      });
    }
  }

  Future<void> _checkServiceStatus() async {
    final isRunning = await NotificationService.isServiceRunning();
    setState(() {
      _serviceRunning = isRunning;
    });
  }

  Future<void> _requestPermissions() async {
    final permissionGranted = await NotificationService.requestPermissions();
    
    setState(() {
      _permissionGranted = permissionGranted;
    });
    
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }
  }

  Future<void> _startForegroundService() async {
    await NotificationService.startForegroundService();
    _checkServiceStatus();
  }

  Future<void> _stopForegroundService() async {
    await NotificationService.stopForegroundService();
    _checkServiceStatus();
  }

  Future<void> _markAsBooked() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-DD').format(DateTime.now());
    await prefs.setString('last_action_date', today);
    await prefs.setString('action_type', 'booked');
    
    // Cancella tutte le notifiche di promemoria
    await NotificationService.cancelNotification();
    
    // Riavvia il servizio per aggiornare lo stato
    await NotificationService.restartForegroundService();
    
    _checkTodayStatus();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Prenotazione registrata!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _markAsNotGoing() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-DD').format(DateTime.now());
    await prefs.setString('last_action_date', today);
    await prefs.setString('action_type', 'not_going');
    
    // Cancella tutte le notifiche di promemoria
    await NotificationService.cancelNotification();
    
    // Riavvia il servizio per aggiornare lo stato
    await NotificationService.restartForegroundService();
    
    _checkTodayStatus();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrato: domani non vai in mensa'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _resetStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_action_date');
    await prefs.remove('action_type');
    _checkTodayStatus();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stato resettato'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: const Text('eatUp - Promemoria Mensa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Impostazioni',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
              
              // Se le impostazioni sono cambiate, suggerisci il riavvio del servizio
              if (result == true && mounted) {
                await _loadSettings(); // Ricarica le impostazioni
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('⚠️ Riavvia il servizio per applicare le modifiche'),
                    action: SnackBarAction(
                      label: 'RIAVVIA',
                      onPressed: () async {
                        await NotificationService.restartForegroundService();
                        _checkServiceStatus();
                      },
                    ),
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // App Icon
                Container(
                  width: 120,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.webp',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback se l'immagine non viene caricata
                        return Container(
                          color: Theme.of(context).colorScheme.primary,
                          child: const Icon(
                            Icons.restaurant_menu,
                            size: 60,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                StatusCard(
                  status: _todayStatus,
                  endTime: _endTime,
                ),
                const SizedBox(height: 30),
                
                // Azioni manuali
                if (_todayStatus == 'non_set')
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _markAsBooked,
                            icon: const Icon(Icons.check),
                            label: const Text('Già fatto'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _markAsNotGoing,
                            icon: const Icon(Icons.cancel),
                            label: const Text('Domani non vado'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _resetStatus,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Resetta Stato'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(200, 50),
                    ),
                  ),
                
                const SizedBox(height: 30),
                
                // Controlli servizio
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Servizio in Background',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _serviceRunning ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_permissionGranted)
                          ElevatedButton.icon(
                            onPressed: _serviceRunning 
                              ? _stopForegroundService 
                              : _startForegroundService,
                            icon: Icon(_serviceRunning ? Icons.stop : Icons.play_arrow),
                            label: Text(_serviceRunning ? 'Ferma Servizio' : 'Avvia Servizio'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _serviceRunning ? Colors.red : Colors.blue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          )
                        else
                          Column(
                            children: [
                              const Text(
                                'Permessi notifiche necessari',
                                style: TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _requestPermissions,
                                child: const Text('Richiedi Permessi'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
