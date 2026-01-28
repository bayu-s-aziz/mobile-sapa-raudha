import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'attendance_service.dart';

/// Manages shared attendance state for student list and detail pages.
/// Ensures attendance status is synchronized across the app and resets daily at 00:01 GMT+7.
class AttendanceStateManager extends GetxService {
  late final AttendanceService _attendanceService;

  // Map of student_id -> Map with today's attendance data
  final RxMap<int, Map<String, dynamic>> todayAttendanceMap =
      <int, Map<String, dynamic>>{}.obs;

  // Track the last date we loaded to detect midnight reset
  final RxString lastLoadedDate = ''.obs;

  // Timer for daily reset at 00:01 GMT+7
  Timer? _dailyResetTimer;

  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  @override
  void onInit() {
    super.onInit();
    _attendanceService = Get.find<AttendanceService>();
    _setupDailyReset();
  }

  /// Setup timer for daily reset at 00:01 GMT+7
  void _setupDailyReset() {
    // Schedule next reset at 00:01 GMT+7
    _scheduleDailyReset();
  }

  void _scheduleDailyReset() {
    // Cancel previous timer if any
    _dailyResetTimer?.cancel();

    // Get current UTC time
    final nowUtc = DateTime.now().toUtc();
    // Convert to GMT+7 (UTC+7)
    final nowGmt7 = nowUtc.add(const Duration(hours: 7));

    // Calculate time until next 00:01 GMT+7
    var nextResetTime = DateTime.utc(
      nowGmt7.year,
      nowGmt7.month,
      nowGmt7.day,
      0,
      1,
    );

    // If current time is past 00:01, schedule for tomorrow
    if (nowGmt7.isAfter(nextResetTime)) {
      nextResetTime = nextResetTime.add(const Duration(days: 1));
    }

    // Convert back to local time for duration calculation
    final nextResetLocal = nextResetTime.subtract(const Duration(hours: 7));
    final durationUntilReset = nextResetLocal.difference(DateTime.now());

    _dailyResetTimer = Timer(durationUntilReset, () {
      _performDailyReset();
      // Schedule next day's reset
      _scheduleDailyReset();
    });
  }

  void _performDailyReset() {
    // Clear all cached attendance data
    todayAttendanceMap.clear();
    lastLoadedDate.value = '';
  }

  /// Get today's attendance for a specific student
  /// Returns null if no attendance record exists for today
  Map<String, dynamic>? getTodayAttendance(int studentId) {
    _checkAndResetIfNeeded();
    final entry = todayAttendanceMap[studentId];
    if (entry == null || entry.isEmpty) return null;
    return entry;
  }

  /// Fetch and cache today's attendance for a specific student
  Future<Map<String, dynamic>?> fetchTodayAttendance(int studentId) async {
    _checkAndResetIfNeeded();

    try {
      final today = _dateFormatter.format(DateTime.now());

      final response = await _attendanceService.getAttendance(
        studentId: studentId,
        date: today,
        perPage: 1,
      );

      if (response['data'] is List && response['data'].isNotEmpty) {
        final attendanceData = response['data'][0] as Map<String, dynamic>;
        todayAttendanceMap[studentId] = attendanceData;
        return attendanceData;
      } else {
        // Ensure no stale empty map remains — remove key instead of storing an empty map
        if (todayAttendanceMap.containsKey(studentId)) {
          todayAttendanceMap.remove(studentId);
        }
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Update attendance and sync across all observers
  Future<void> updateAttendance(
    int studentId,
    Map<String, dynamic> attendanceData,
  ) async {
    // Update the cached data immediately
    todayAttendanceMap[studentId] = attendanceData;

    // Notify all listeners
    todayAttendanceMap.refresh();
  }

  /// Check if date has changed and perform reset if needed
  void _checkAndResetIfNeeded() {
    final today = _dateFormatter.format(DateTime.now());

    if (lastLoadedDate.value != today) {
      _performDailyReset();
      lastLoadedDate.value = today;
    }
  }

  @override
  void onClose() {
    _dailyResetTimer?.cancel();
    super.onClose();
  }
}
