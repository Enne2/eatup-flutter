# 🍽️ EatUp - Promemoria Mensa Intelligente

<div align="center">

**App Android per ricordarti di prenotare la mensa con notifiche personalizzabili**

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Android](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android)](https://www.android.com/)

</div>

## 📱 Cos'è EatUp?

EatUp è un'app Flutter progettata per aiutarti a **non dimenticare mai di prenotare la mensa**! 

Con notifiche intelligenti configurabili, EatUp ti ricorda negli orari che preferisci e smette di disturbarti non appena hai prenotato o se hai deciso di non andare.

### ✨ Caratteristiche Principali

- 🔔 **Notifiche Personalizzabili**: Scegli giorni della settimana e orari
- 🎯 **Azioni Rapide**: Rispondi direttamente dalle notifiche
- 💾 **Stato Persistente**: L'app ricorda le tue scelte
- 🔄 **Reset Automatico**: Si resetta ogni giorno
- 🌙 **Funziona in Background**: Servizio foreground sempre attivo
- ⚡ **Leggera e Veloce**: Minimo impatto sulla batteria
- 🎨 **UI Moderna**: Material 3 Design

## 🚀 Come Funziona

### Flusso Tipico

1. **Configura** giorni e orari nelle impostazioni (es: Lun-Ven, 16:00-19:00)
2. **Avvia** il servizio in background
3. **Ricevi** notifiche ogni 5 minuti negli orari configurati
4. **Rispondi** con "Già fatto ✓" o "Domani non vado"
5. **Relax** - le notifiche si fermano fino al giorno dopo

### Notifiche Intelligenti

```
📱 16:00 - "Ricordati di prenotare la mensa!"
   [Già fatto ✓]  [Domani non vado]

📱 16:05 - "Ricordati di prenotare la mensa!"
   [Già fatto ✓]  [Domani non vado]

✋ 16:07 - Premi "Già fatto ✓"
   ✅ Notifiche fermate per oggi
   🔄 Reset automatico domani mattina
```

## 🛠️ Tecnologie

### Framework & Linguaggi
- **Flutter 3.9.2** - UI cross-platform
- **Dart 3.0+** - Linguaggio di programmazione

### Packages Principali
- `flutter_local_notifications` ^19.4.2 - Notifiche locali
- `flutter_foreground_task` ^8.17.0 - Servizio in background
- `shared_preferences` ^2.3.3 - Storage locale
- `intl` ^0.19.0 - Formattazione date

### Architettura

```
lib/
├── main.dart                    # Entry point
├── models/                      # Modelli dati
│   └── settings_model.dart      # Gestione impostazioni
├── screens/                     # Schermate UI
│   ├── home_screen.dart        # Schermata principale
│   └── settings_screen.dart    # Configurazione
├── services/                    # Business logic
│   └── notification_service.dart # Gestione notifiche
└── widgets/                     # Widget riutilizzabili
    └── status_card.dart        # Card stato prenotazione
```

## 📦 Installazione

### Prerequisiti

- Flutter SDK 3.9.2 o superiore
- Android SDK (API 21+)
- Android Studio / VS Code

### Download APK

Scarica l'ultima release APK dalla sezione [Releases](https://github.com/YOUR_USERNAME/eatup-flutter/releases)

### Build da Sorgente

```bash
# Clona il repository
git clone https://github.com/YOUR_USERNAME/eatup-flutter.git
cd eatup-flutter/eatup_flutter

# Installa le dipendenze
flutter pub get

# Esegui su dispositivo/emulatore
flutter run

# Build APK di release
flutter build apk --release
```

## ⚙️ Configurazione

### Prima Esecuzione

1. **Concedi i permessi**:
   - Notifiche (obbligatorio)
   - Esecuzione in background (raccomandato)
   - Ignora ottimizzazioni batteria (raccomandato)

2. **Configura le impostazioni**:
   - Tocca l'icona ⚙️ in alto a destra
   - Seleziona i giorni (es: Lun, Mar, Mer, Gio, Ven)
   - Imposta l'orario (es: 16:00 - 19:00)
   - Salva

3. **Avvia il servizio**:
   - Torna alla schermata principale
   - Premi "Avvia Servizio"
   - Il pallino diventerà verde 🟢

### Personalizzazione

#### Cambiare l'icona delle notifiche
Modifica `android/app/src/main/res/drawable/ic_notification.xml`

Vedi la guida completa in [NOTIFICATION_ICON.md](NOTIFICATION_ICON.md)

#### Cambiare il logo dell'app
Sostituisci `assets/images/logo.webp` e rigenera le icone:

```bash
flutter pub run flutter_launcher_icons
```

Vedi la guida completa in [LOGO_SETUP.md](LOGO_SETUP.md)

## 🎯 Casi d'Uso

### Studenti Universitari
Ricevi promemoria per prenotare il pranzo/cena in mensa universitaria.

### Lavoratori Aziendali
Non dimenticare di prenotare il pasto aziendale entro l'orario limite.

### Mense Scolastiche
Aiuta i genitori a ricordarsi di prenotare i pasti per i figli.

## 📱 Permessi Android

L'app richiede i seguenti permessi:

| Permesso | Scopo | Obbligatorio |
|----------|-------|--------------|
| `POST_NOTIFICATIONS` | Mostrare notifiche | ✅ Si |
| `RECEIVE_BOOT_COMPLETED` | Riavvio automatico | ⚠️ Raccomandato |
| `WAKE_LOCK` | Svegliare il dispositivo | ⚠️ Raccomandato |
| `FOREGROUND_SERVICE` | Servizio in background | ✅ Si |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Affidabilità notifiche | ⚠️ Raccomandato |

## 🔧 Configurazione Avanzata

### Cambiare l'intervallo delle notifiche

In `lib/services/notification_service.dart`, modifica:

```dart
eventAction: ForegroundTaskEventAction.repeat(300000), // 5 minuti
```

Valori comuni:
- `60000` = 1 minuto
- `300000` = 5 minuti (default)
- `600000` = 10 minuti

### Personalizzare i giorni di default

In `lib/models/settings_model.dart`, modifica:

```dart
selectedDays: {1, 2, 3, 4, 5}, // Lun-Ven
```

### Personalizzare l'orario di default

```dart
startTime: const TimeOfDay(hour: 16, minute: 0),
endTime: const TimeOfDay(hour: 19, minute: 0),
```

## 📚 Documentazione Aggiuntiva

- [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) - Architettura del progetto
- [LOGO_SETUP.md](LOGO_SETUP.md) - Configurazione logo e icona
- [NOTIFICATION_ICON.md](NOTIFICATION_ICON.md) - Personalizzazione icone notifiche
- [ICON_GUIDE.md](ICON_GUIDE.md) - Guida completa alle icone

## 🐛 Troubleshooting

### Le notifiche non arrivano

1. Verifica che il servizio sia attivo (pallino verde)
2. Controlla di essere nell'orario configurato
3. Assicurati che non sia weekend (se configurato solo Lun-Ven)
4. Disabilita le ottimizzazioni batteria per l'app

### Il servizio si ferma

1. Vai nelle impostazioni Android
2. Batteria → Ottimizzazione batteria
3. Trova "EatUp" e disabilita l'ottimizzazione
4. Riavvia il servizio

### L'app crasha

```bash
# Pulisci e ricompila
flutter clean
flutter pub get
flutter run
```

## 🤝 Contribuire

I contributi sono benvenuti! 

1. Fork il progetto
2. Crea un branch (`git checkout -b feature/AmazingFeature`)
3. Commit le modifiche (`git commit -m 'Add some AmazingFeature'`)
4. Push al branch (`git push origin feature/AmazingFeature`)
5. Apri una Pull Request

## 📝 TODO / Roadmap

- [ ] Supporto iOS
- [ ] Notifiche con suoni personalizzabili
- [ ] Widget per la home screen
- [ ] Statistiche di prenotazione
- [ ] Sincronizzazione cloud (opzionale)
- [ ] Temi personalizzati
- [ ] Supporto multilingua

## 📄 Licenza

Questo progetto è sotto licenza MIT - vedi il file [LICENSE](LICENSE) per i dettagli.

## 👨‍💻 Autore

Sviluppato con ❤️ usando Flutter

## 🙏 Ringraziamenti

- [Flutter Team](https://flutter.dev/) - Framework fantastico
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) - Plugin notifiche
- [flutter_foreground_task](https://pub.dev/packages/flutter_foreground_task) - Background service
- Comunità Flutter per il supporto

---

<div align="center">

**⭐ Se ti piace EatUp, lascia una stella! ⭐**

Made with Flutter 💙

</div>
