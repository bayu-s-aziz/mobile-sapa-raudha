# Self-Hosted Push Notification - SAPA Raudha

Implementasi push notification tanpa ketergantungan pada Firebase atau layanan cloud messaging lainnya.

## Arsitektur

```
┌─────────────┐         WebSocket          ┌─────────────┐
│   Flutter   │ ←────────────────────────→ │   Server    │
│     App     │                             │  (Node.js)  │
└─────────────┘                             └─────────────┘
      ↓                                            ↓
 Local Notifications                         Database
                                              (MySQL)
```

## Fitur

✅ **Real-time Notifications** via WebSocket  
✅ **Persistent Storage** di database MySQL  
✅ **Local Notifications** untuk tampilan notifikasi  
✅ **Background Polling** sebagai fallback  
✅ **Auto-reconnect** jika koneksi terputus  
✅ **Heartbeat mechanism** untuk menjaga koneksi  
✅ **Broadcast** ke semua user atau role tertentu  
✅ **Targeted notifications** ke user spesifik  

## Dependencies

### Flutter (`pubspec.yaml`)

```yaml
dependencies:
  web_socket_channel: ^3.0.1      # WebSocket client
  flutter_local_notifications: ^18.0.1  # Local notifications
  workmanager: ^0.5.2             # Background tasks (optional)
```

### Backend (`package.json`)

```json
{
  "dependencies": {
    "ws": "^8.16.0",              // WebSocket server
    "express": "^5.2.1",
    "mysql2": "^3.15.3",
    "jsonwebtoken": "^9.0.3"
  }
}
```

## Setup

### 1. Database Migration

Jalankan SQL migration:

```bash
cd server
mysql -u root -p sapa_raudha < migrations/notifications.sql
```

### 2. Install Dependencies

**Backend:**
```bash
cd server
npm install
```

**Flutter:**
```bash
flutter pub get
```

### 3. Konfigurasi

Update WebSocket URL di `websocket_notification_service.dart`:

```dart
static const String wsUrl = 'ws://YOUR_SERVER_IP:3000/ws';
```

Ganti `YOUR_SERVER_IP` dengan:
- `localhost` untuk emulator Android
- `10.0.2.2` untuk emulator Android (alias localhost)
- IP local network untuk physical device (contoh: `192.168.1.100`)

### 4. Update main.dart

```dart
import 'package:sapa_raudha/app/data/services/websocket_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await Get.putAsync(() => StorageProvider().init());
  Get.put(ApiClient());
  Get.put(WebSocketNotificationService());

  runApp(const MainApp());
}
```

### 5. Connect setelah Login

Update `auth_service.dart`:

```dart
Future<Map<String, dynamic>> login({
  required String identifier,
  required String password,
}) async {
  // ...existing login code...
  
  // Connect to WebSocket notification service
  if (Get.isRegistered<WebSocketNotificationService>()) {
    final notificationService = Get.find<WebSocketNotificationService>();
    await notificationService.connect();
  }
  
  return res;
}

Future<void> logout() async {
  // Disconnect from WebSocket
  if (Get.isRegistered<WebSocketNotificationService>()) {
    final notificationService = Get.find<WebSocketNotificationService>();
    notificationService.disconnect();
  }
  
  // ...existing logout code...
}
```

## Penggunaan

### Send Notification dari Backend

#### Broadcast ke semua user:
```javascript
app.createAndSendNotification({
  title: 'Pengumuman Penting',
  body: 'Sekolah libur besok',
  isBroadcast: true,
  data: { type: 'announcement' }
});
```

#### Broadcast ke role tertentu:
```javascript
app.createAndSendNotification({
  title: 'Info untuk Orang Tua',
  body: 'Rapat orang tua hari Sabtu',
  userRole: 'parent',
  isBroadcast: true,
  data: { type: 'announcement' }
});
```

#### Send ke user spesifik:
```javascript
app.createAndSendNotification({
  title: 'Izin Disetujui',
  body: 'Permohonan izin anak Anda telah disetujui',
  userId: 123,
  userRole: 'parent',
  data: { 
    type: 'leave_request',
    request_id: 456
  }
});
```

### Notification Badge di Flutter

```dart
class NotificationBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notificationService = Get.find<WebSocketNotificationService>();
    
    return Obx(() => Badge(
      label: Text('${notificationService.unreadCount}'),
      isLabelVisible: notificationService.unreadCount > 0,
      child: IconButton(
        icon: Icon(Icons.notifications),
        onPressed: () => Get.toNamed('/notifications'),
      ),
    ));
  }
}
```

### Notification List Screen

```dart
class NotificationListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final service = Get.find<WebSocketNotificationService>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifikasi'),
        actions: [
          TextButton(
            onPressed: service.clearAll,
            child: Text('Hapus Semua'),
          ),
        ],
      ),
      body: Obx(() => ListView.builder(
        itemCount: service.notifications.length,
        itemBuilder: (context, index) {
          final notif = service.notifications[index];
          return ListTile(
            title: Text(notif['title']),
            subtitle: Text(notif['body']),
            trailing: notif['read'] 
              ? null 
              : Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
            onTap: () {
              service.markAsRead(notif['id']);
              // Handle navigation based on data
            },
          );
        },
      )),
    );
  }
}
```

## Monitoring & Debugging

### Check WebSocket Connection

```dart
// Di Flutter
final service = Get.find<WebSocketNotificationService>();
print('Connected: ${service.isConnected.value}');
print('Reconnect attempts: ${service.reconnectAttempts.value}');
```

### Backend Logs

```javascript
// Server akan log:
// - WebSocket connected: User 123 (parent)
// - WebSocket disconnected: User 123 (parent)
// - Broadcast to parent: 5 connections
```

## Keuntungan vs Firebase

| Aspek | Self-Hosted | Firebase |
|-------|-------------|----------|
| **Biaya** | Free (hanya hosting) | Free tier terbatas |
| **Kontrol** | Full control | Terbatas |
| **Privacy** | Data tetap di server sendiri | Data di Google |
| **Kompleksitas** | Setup lebih simple | Setup kompleks |
| **Real-time** | Ya (WebSocket) | Ya (FCM) |
| **Offline** | Perlu polling/background service | Native support |
| **Reliability** | Tergantung server | 99.9% uptime |

## Troubleshooting

### WebSocket tidak connect

1. Cek IP server benar
2. Pastikan server running
3. Cek firewall tidak block port 3000
4. Pastikan token valid

### Notifikasi tidak muncul

1. Cek permission granted
2. Cek notification channel created
3. Test dengan local notification dulu

### Background polling tidak jalan

1. Pastikan `workmanager` sudah di-initialize
2. Cek battery optimization settings
3. Android 12+ perlu exact alarm permission

## Production Checklist

- [ ] Ganti JWT_SECRET dengan secret yang kuat
- [ ] Setup SSL/TLS untuk WebSocket (wss://)
- [ ] Implement rate limiting
- [ ] Setup monitoring & logging
- [ ] Backup database regularly
- [ ] Test dengan berbagai kondisi network
- [ ] Handle edge cases (server restart, dll)

## Alternative: Background Polling

Jika WebSocket tidak ideal untuk use case Anda, gunakan `PollingNotificationService` dengan interval 15 menit untuk check notifikasi baru dari server.

```dart
// Di main.dart
Get.put(PollingNotificationService());

// Setelah login
final pollingService = Get.find<PollingNotificationService>();
await pollingService.startPolling();

// Saat logout
await pollingService.stopPolling();
```

## Support

Untuk pertanyaan atau issue, silakan buka issue di repository ini.
