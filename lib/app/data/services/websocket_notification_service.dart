import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../providers/storage_provider.dart';

class WebSocketNotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;

  final RxBool isConnected = false.obs;
  final RxInt reconnectAttempts = 0.obs;
  final RxList<Map<String, dynamic>> notifications =
      <Map<String, dynamic>>[].obs;

  static const String wsUrl =
      'ws://192.168.1.100:3000/ws'; // Ganti dengan IP server Anda
  static const int maxReconnectAttempts = 10;
  static const Duration reconnectDelay = Duration(seconds: 5);
  static const Duration heartbeatInterval = Duration(seconds: 30);

  late final StorageProvider _storage;

  @override
  Future<void> onInit() async {
    super.onInit();
    _storage = Get.find<StorageProvider>();
    await _initializeLocalNotifications();
    await connect();
  }

  @override
  void onClose() {
    disconnect();
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    super.onClose();
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'sapa_raudha_channel',
      'SAPA Raudha Notifications',
      description: 'Notifikasi dari aplikasi SAPA Raudha',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> connect() async {
    try {
      final token = _storage.getToken();
      if (token == null || token.isEmpty) {
        if (kDebugMode) {
          debugPrint('No auth token available, skipping WebSocket connection');
        }
        return;
      }

      // Close existing connection
      disconnect();

      // Create new connection with auth token in URL
      final uri = Uri.parse('$wsUrl?token=$token');
      _channel = WebSocketChannel.connect(uri);

      // Listen to messages
      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDisconnected,
        cancelOnError: false,
      );

      isConnected.value = true;
      reconnectAttempts.value = 0;
      if (kDebugMode) {
        debugPrint('WebSocket connected successfully');
      }

      // Start heartbeat
      _startHeartbeat();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WebSocket connection error: $e');
      }
      _scheduleReconnect();
    }
  }

  void disconnect() {
    _heartbeatTimer?.cancel();
    _channel?.sink.close(status.goingAway);
    _channel = null;
    isConnected.value = false;
  }

  void _onMessage(dynamic message) {
    try {
      final data = jsonDecode(message.toString());
      if (kDebugMode) {
        debugPrint('WebSocket message received: $data');
      }

      // Handle different message types
      switch (data['type']) {
        case 'notification':
          _handleNotification(data);
          break;
        case 'pong':
          // Heartbeat response
          break;
        case 'message':
          _handleMessage(data);
          break;
        default:
          if (kDebugMode) {
            debugPrint('Unknown message type: ${data['type']}');
          }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error parsing WebSocket message: $e');
      }
    }
  }

  void _handleNotification(Map<String, dynamic> data) {
    final notification = {
      'id': data['id'] ?? DateTime.now().millisecondsSinceEpoch,
      'title': data['title'] ?? 'SAPA Raudha',
      'body': data['body'] ?? '',
      'data': data['data'] ?? {},
      'timestamp': DateTime.now().toIso8601String(),
      'read': false,
    };

    // Add to list
    notifications.insert(0, notification);

    // Show local notification
    _showLocalNotification(
      id: notification['id'] as int,
      title: notification['title'] as String,
      body: notification['body'] as String,
      payload: jsonEncode(notification['data']),
    );
  }

  void _handleMessage(Map<String, dynamic> data) {
    if (kDebugMode) {
      debugPrint('Message received: ${data['message']}');
    }
  }

  void _onError(dynamic error) {
    if (kDebugMode) {
      debugPrint('WebSocket error: $error');
    }
    isConnected.value = false;
    _scheduleReconnect();
  }

  void _onDisconnected() {
    if (kDebugMode) {
      debugPrint('WebSocket disconnected');
    }
    isConnected.value = false;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (reconnectAttempts.value >= maxReconnectAttempts) {
      if (kDebugMode) {
        debugPrint('Max reconnect attempts reached');
      }
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(reconnectDelay, () {
      reconnectAttempts.value++;
      if (kDebugMode) {
        debugPrint('Reconnecting... Attempt ${reconnectAttempts.value}');
      }
      connect();
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(heartbeatInterval, (timer) {
      if (isConnected.value && _channel != null) {
        try {
          _channel!.sink.add(jsonEncode({'type': 'ping'}));
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error sending heartbeat: $e');
          }
          _onDisconnected();
        }
      }
    });
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'sapa_raudha_channel',
          'SAPA Raudha Notifications',
          channelDescription: 'Notifikasi dari aplikasi SAPA Raudha',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        _handleNotificationNavigation(data);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error parsing notification payload: $e');
        }
      }
    }
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'];

    switch (type) {
      case 'announcement':
        final announcementId = data['announcement_id'];
        if (announcementId != null) {
          Get.toNamed(
            '/announcement-detail',
            arguments: {'id': announcementId},
          );
        }
        break;

      case 'leave_request':
        final requestId = data['request_id'];
        if (requestId != null) {
          Get.toNamed('/confirm-leave');
        }
        break;

      case 'attendance':
        Get.toNamed('/attendance-history');
        break;

      case 'password_reset':
        Get.toNamed('/admin-password-reset');
        break;

      default:
        if (kDebugMode) {
          debugPrint('Unknown notification type: $type');
        }
    }
  }

  // Send message to server
  void sendMessage(Map<String, dynamic> message) {
    if (isConnected.value && _channel != null) {
      try {
        _channel!.sink.add(jsonEncode(message));
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error sending message: $e');
        }
      }
    } else {
      if (kDebugMode) {
        debugPrint('WebSocket not connected');
      }
    }
  }

  // Mark notification as read
  void markAsRead(int id) {
    final index = notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      notifications[index]['read'] = true;
      notifications.refresh();
    }
  }

  // Clear all notifications
  void clearAll() {
    notifications.clear();
  }

  // Get unread count
  int get unreadCount => notifications.where((n) => n['read'] == false).length;
}
