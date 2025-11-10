import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin_user_management_controller.dart';

class AdminUserManagementView extends GetView<AdminUserManagementController> {
  // ignore: use_super_parameters
  const AdminUserManagementView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manajemen Pengguna (Siswa, Guru, Ortu)'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Halaman untuk CRUD Pengguna (Siswa, Guru, Orang Tua)',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
