import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sapa_raudha/app/data/services/api_client.dart';
import 'package:sapa_raudha/app/utils/snackbar_helper.dart';
import 'package:sapa_raudha/app/modules/admin_dashboard/admin_dashboard_controller.dart';

class AdminPasswordResetController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final RxList<Map<String, dynamic>> requests = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedFilter = 'pending'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    isLoading.value = true;
    try {
      final response = await _apiClient.get(
        '/api/password-reset-requests?status=${selectedFilter.value}',
      );
      requests.assignAll(
        List<Map<String, dynamic>>.from(response['requests'] ?? []),
      );
    } catch (e) {
      SnackbarHelper.showError('Gagal memuat permintaan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
    fetchRequests();
  }

  Future<void> processRequest(
    int requestId,
    String status, {
    String? notes,
  }) async {
    try {
      final response = await _apiClient.put(
        '/api/password-reset-requests/$requestId/process',
        {'status': status, 'notes': notes},
      );

      if (status == 'completed') {
        final password = response['password'];
        final phoneNumber = response['phone_number'];

        // Show dialog with password and phone number
        Get.dialog(
          AlertDialog(
            title: const Text('Password User'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kirimkan password berikut ke pengguna:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          password ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: password ?? ''),
                          );
                          SnackbarHelper.showSuccess(
                            'Password disalin ke clipboard',
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (phoneNumber != null) ...[
                  Text(
                    'Nomor Telepon:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    phoneNumber,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      _sendToWhatsApp(
                        phoneNumber,
                        response['identifier'] ?? '',
                        password ?? '',
                      );
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Kirim ke WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Atau kirim password melalui SMS ke nomor di atas.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );

        SnackbarHelper.showSuccess('Permintaan berhasil diproses');
      } else {
        SnackbarHelper.showSuccess('Permintaan ditolak');
      }

      fetchRequests();

      // Refresh dashboard notification count
      try {
        final dashboardController = Get.find<AdminDashboardController>();
        dashboardController.fetchPendingPasswordResets();
      } catch (e) {
        // Dashboard controller might not be loaded
      }
    } catch (e) {
      SnackbarHelper.showError('Gagal memproses permintaan: $e');
    }
  }

  void showProcessDialog(Map<String, dynamic> request) {
    final notesController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Proses Permintaan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Identifier: ${request['identifier']}'),
            Text('Nama: ${request['name']}'),
            Text(
              'Tipe: ${request['user_type'] == 'guru' ? 'Guru/Admin' : 'Orang Tua'}',
            ),
            if (request['phone_number'] != null)
              Text('Telepon: ${request['phone_number']}'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Get.back();
              processRequest(
                request['id'],
                'rejected',
                notes: notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Tolak'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              processRequest(
                request['id'],
                'completed',
                notes: notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
              );
            },
            child: const Text('Proses & Lihat Password'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendToWhatsApp(
    String phoneNumber,
    String identifier,
    String password,
  ) async {
    try {
      // Format phone number - remove any non-digit characters
      String formattedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

      // Add country code if not present (assuming Indonesia)
      if (!formattedPhone.startsWith('62')) {
        if (formattedPhone.startsWith('0')) {
          formattedPhone = '62${formattedPhone.substring(1)}';
        } else {
          formattedPhone = '62$formattedPhone';
        }
      }

      // Create WhatsApp message
      final message = Uri.encodeComponent(
        'Assalamu\'alaikum Warahmatullahi Wabarakatuh,\n\n'
        'Yth. Bapak/Ibu/Saudara/i,\n\n'
        'Kami dari Tim Administrasi Raudhatul Athfal Al-Islam telah menerima dan memproses permintaan reset password Anda.\n\n'
        'Berikut adalah informasi akses login Anda:\n\n'
        '📱 NIK/NISN: $identifier\n'
        '🔐 Password: $password\n\n'
        'Silakan login ke aplikasi SAPA Raudhatul Athfal menggunakan informasi di atas.\n\n'
        'Untuk keamanan akun Anda, mohon segera mengganti password setelah login pertama kali.\n\n'
        'Apabila ada pertanyaan atau kendala, silakan hubungi kami.\n\n'
        'Terima kasih atas perhatian dan kerjasamanya.\n\n'
        'Wassalamu\'alaikum Warahmatullahi Wabarakatuh\n\n'
        'Hormat kami,\n'
        'Tim Administrasi\n'
        'Raudhatul Athfal Al-Islam',
      );

      // Create WhatsApp URL
      final whatsappUrl = 'https://wa.me/$formattedPhone?text=$message';
      final uri = Uri.parse(whatsappUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        SnackbarHelper.showSuccess('Membuka WhatsApp...');
      } else {
        SnackbarHelper.showError('Tidak dapat membuka WhatsApp');
      }
    } catch (e) {
      SnackbarHelper.showError('Error: $e');
    }
  }
}
