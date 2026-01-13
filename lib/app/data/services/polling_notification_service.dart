import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:workmanager/workmanager.dart';
import '../providers/storage_provider.dart';
import 'api_client.dart';

// Background task dispatcher
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Initialize storage
      final storage = StorageProvider();
      await storage.init();

      final token = storage.getToken();
      if (token == null || token.isEmpty) {
        return Future.value(true);
      }

      // Create API client with proper initialization
      final apiClient = ApiClient(
        baseUrl: 'http://api.ra-alislam.sch.id', // Update with your server URL
      );

      // Fetch new notifications from server
      final response = await apiClient.get('/api/notifications/unread');

      if (response['success'] == true && response['notifications'] != null) {
        final notifications = response['notifications'] as List;

        // Show local notifications for each unread notification
        final localNotifications = FlutterLocalNotificationsPlugin();

        for (var notification in notifications) {
          await _showNotification(
            localNotifications,
            notification['id'] ?? DateTime.now().millisecondsSinceEpoch,
            notification['title'] ?? 'SAPA Raudha',
            notification['body'] ?? '',
            jsonEncode(notification['data'] ?? {}),
          );
        }
      }

      return Future.value(true);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Background task error: $e');
      }
      return Future.value(false);
    }
  });
}

Future<void> _showNotification(
  FlutterLocalNotificationsPlugin plugin,
  dynamic id,
  String title,
  String body,
  String payload,
) async {
  final notificationId = id is int ? id : id.hashCode;

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'sapa_raudha_channel',
    'SAPA Raudha Notifications',
    channelDescription: 'Notifikasi dari aplikasi SAPA Raudha',
    importance: Importance.high,
    priority: Priority.high,
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

  await plugin.show(notificationId, title, body, details, payload: payload);
}

class PollingNotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  late final ApiClient _apiClient;

  final RxList<Map<String, dynamic>> notifications =
      <Map<String, dynamic>>[].obs;
  final RxBool isPollingEnabled = false.obs;

  static const String backgroundTaskName = 'notification_polling';
  static const Duration pollingInterval = Duration(minutes: 15);

  @override
  Future<void> onInit() async {
    super.onInit();
    _apiClient = Get.find<ApiClient>();

    await _initializeLocalNotifications();
    await _initializeBackgroundTasks();
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

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'sapa_raudha_channel',
      'SAPA Raudha Notifications',
      description: 'Notifikasi dari aplikasi SAPA Raudha',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> _initializeBackgroundTasks() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
  }

  Future<void> startPolling() async {
    if (isPollingEnabled.value) return;

    try {
      await Workmanager().registerPeriodicTask(
        backgroundTaskName,
        backgroundTaskName,
        frequency: pollingInterval,
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );

      isPollingEnabled.value = true;
      if (kDebugMode) {
        debugPrint('Background polling started');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error starting polling: $e');
      }
    }
  }

  Future<void> stopPolling() async {
    try {
      await Workmanager().cancelByUniqueName(backgroundTaskName);
      isPollingEnabled.value = false;
      if (kDebugMode) {
        debugPrint('Background polling stopped');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error stopping polling: $e');
      }
    }
  }

  // Fetch notifications manually (for foreground)
  Future<void> fetchNotifications() async {
    try {
      final response = await _apiClient.get('/api/notifications');

      if (response['success'] == true && response['notifications'] != null) {
        notifications.value = List<Map<String, dynamic>>.from(
          response['notifications'] as List,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching notifications: $e');
      }
    }
  }

  // Mark notification as read
  Future<void> markAsRead(int id) async {
    try {
      await _apiClient.put('/api/notifications/$id/read', {});

      final index = notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        notifications[index]['read'] = true;
        notifications.refresh();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error marking notification as read: $e');
      }
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null && response.payload!.isNotEmpty) {
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
        Get.toNamed('/confirm-leave');
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

  int get unreadCount => notifications.where((n) => n['read'] == false).length;

  @override
  void onClose() {
    stopPolling();
    super.onClose();
  }
}
