import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/modules/scan_presence/scan_presence_controller.dart';
import 'package:sapa_raudha/app/data/services/attendance_service.dart';

class DummyAttendanceService extends AttendanceService {
  dynamic lastCode;
  bool confirmCheckoutCalled = false;

  @override
  Future<Map<String, dynamic>> scanAttendance(dynamic code, {bool confirmCheckout = false}) async {
    lastCode = code;
    if (confirmCheckout) confirmCheckoutCalled = true;

    // Simulate create attendance response with check_in
    if (code == '123456') {
      return {'data': {'check_in': '08:00:00'}, 'student': {'name': 'Test Student'}};
    }

    // Simulate existing attendance requiring checkout confirmation
    if (code == '654321') {
      return {
        'confirm_checkout': true,
        'student': {'name': 'Already Present'},
        'attendance': {'id': 9, 'check_in': '07:50:00'}
      };
    }

    // Default: not found
    throw Exception('Siswa tidak ditemukan');
  }

  @override
  Future<Map<String, dynamic>?> findStudentByNis(String nis) async {
    if (nis == '123456') return {'id': 1, 'name': 'Test Student', 'nis': nis};
    if (nis == '654321') return {'id': 2, 'name': 'Already Present', 'nis': nis};
    return null;
  }
}

void main() {
  group('ScanPresenceController _extractNis', () {
    late ScanPresenceController ctrl;

    setUp(() {
      Get.testMode = true;
      Get.reset();
      ctrl = ScanPresenceController();
    });

    });

// Test helper controller that overrides dialog behavior and vibration
class TestScanPresenceController extends ScanPresenceController {
  final bool shouldConfirm;
  bool vibrated = false;

  TestScanPresenceController({this.shouldConfirm = true});

  @override
  Future<bool?> showCheckInConfirmation(String title, String content) async {
    return shouldConfirm;
  }

  @override
  Future<void> vibrate() async {
    vibrated = true;
  }
}


  group('ScanPresenceController integration flows', () {
    late ScanPresenceController ctrl;
    late DummyAttendanceService svc;

    setUp(() {
      Get.reset();
      svc = DummyAttendanceService();
      Get.put<AttendanceService>(svc);
      // Use a Test controller that overrides confirmation dialog to auto-confirm
      ctrl = TestScanPresenceController();
      ctrl.onInit();
    });

    test('extracts 6-digit NIS from JSON', () {
      final raw = '{"nis":"123456"}';
      expect(ctrl._extractNis(raw), '123456');
    });

    test('extracts 6-digit NIS from plain digits', () {
      final raw = '123456';
      expect(ctrl._extractNis(raw), '123456');
    });

    test('prefers 6-digit and not shorter sequences', () {
      final raw = 'NIS: 0123456'; // 7 digits
      expect(ctrl._extractNis(raw), '0123456');
    });

    test('returns null for non-digit content', () {
      final raw = 'hello world';
      expect(ctrl._extractNis(raw), isNull);
    });
  });

  group('ScanPresenceController integration flows', () {
    late TestScanPresenceController ctrl;
    late DummyAttendanceService svc;

    setUp(() {
      Get.reset();
      svc = DummyAttendanceService();
      Get.put<AttendanceService>(svc);
      // Use a Test controller that overrides confirmation dialog to auto-confirm
      ctrl = TestScanPresenceController();
      ctrl.onInit();
    });

    test('submits attendance for check-in when NIS present and vibrates', () async {
      await ctrl._submitAttendance('123456');
      expect(svc.lastCode, '123456');
      expect(ctrl.vibrated, isTrue);
    });

    test('prompts checkout when required and handles confirm and vibrates', () async {
      // Simulate server indicating checkout required
      final res = await svc.scanAttendance('654321');
      expect(res['confirm_checkout'], isTrue);

      // Now simulate confirming checkout via controller flow
      // We directly call _submitAttendance which will prompt and then perform checkout
      await ctrl._submitAttendance('654321');
      // Confirm that service was asked to perform checkout
      expect(svc.confirmCheckoutCalled, isTrue);
      expect(ctrl.vibrated, isTrue);
    });
  });
}
