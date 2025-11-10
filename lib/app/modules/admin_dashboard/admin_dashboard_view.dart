import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin_dashboard_controller.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dasbor Admin'), centerTitle: true),
      body: Center(
        child: Text(
          'Selamat Datang di Dasbor Admin',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
