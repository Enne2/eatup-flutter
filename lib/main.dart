import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inizializza il plugin delle notifiche
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await NotificationService.initialize();
  
  // Inizializza la porta di comunicazione per il foreground task
  FlutterForegroundTask.initCommunicationPort();
  
  runApp(MyApp(notificationsPlugin: flutterLocalNotificationsPlugin));
}

/// App principale
class MyApp extends StatelessWidget {
  final FlutterLocalNotificationsPlugin notificationsPlugin;
  
  const MyApp({super.key, required this.notificationsPlugin});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Promemoria Mensa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: WithForegroundTask(
        child: HomeScreen(notificationsPlugin: notificationsPlugin),
      ),
    );
  }
}
