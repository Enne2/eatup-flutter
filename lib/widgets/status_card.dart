import 'package:flutter/material.dart';

/// Widget che mostra lo stato corrente della prenotazione
class StatusCard extends StatelessWidget {
  final String status;
  final TimeOfDay? endTime;

  const StatusCard({
    super.key,
    required this.status,
    this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String title;
    String subtitle;
    
    final now = DateTime.now();
    final weekday = now.weekday;
    final isWeekend = weekday == 6 || weekday == 7;
    
    // Verifica se siamo oltre l'orario configurato e nessuna scelta è stata fatta
    bool isLate = false;
    if (endTime != null && status == 'non_set' && !isWeekend) {
      final currentMinutes = now.hour * 60 + now.minute;
      final endMinutes = endTime!.hour * 60 + endTime!.minute;
      isLate = currentMinutes >= endMinutes;
    }
    
    if (isLate) {
      icon = Icons.warning;
      color = Colors.red;
      title = 'In Ritardo! ⚠️';
      subtitle = 'L\'orario per prenotare è scaduto';
    } else {
      switch (status) {
        case 'booked':
          icon = Icons.check_circle;
          color = Colors.green;
          title = 'Prenotazione Effettuata ✓';
          subtitle = 'Hai già prenotato la mensa per domani';
          break;
        case 'not_going':
          icon = Icons.cancel;
          color = Colors.orange;
          title = 'Non Vai Domani';
          subtitle = 'Hai indicato che domani non vai in mensa';
          break;
        default:
          icon = Icons.notifications_active;
          color = Colors.grey;
          title = 'Nessuna Azione';
          subtitle = 'Riceverai notifiche negli orari configurati';
      }
      
      if (isWeekend && status == 'non_set') {
        icon = Icons.weekend;
        color = Colors.blue;
        title = 'Weekend';
        subtitle = 'Buon riposo! Il servizio riprenderà lunedì';
      }
    }
    
    return Card(
      elevation: 8,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
