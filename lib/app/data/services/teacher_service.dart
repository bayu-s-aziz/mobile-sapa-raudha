// lib/app/data/services/teacher_service.dart

import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/teacher_model.dart';
import 'api_client.dart';

class TeacherService extends GetxService {
  final RxList<Teacher> teachers = <Teacher>[].obs;
  late final ApiClient _apiClient;

  @override
  void onInit() {
    super.onInit();
    _apiClient = Get.find<ApiClient>();
  }

  Future<List<Teacher>> getAllTeachers() async {
    try {
      final data = await _apiClient.getList('/api/teachers');

      final teachersList = data.map((json) {
        return Teacher(
          id: json['id'].toString(),
          name: json['name'] ?? '',
          email: json['email'] ?? '',
          phone: json['phone'],
          nip: json['nik'],
          subject: json['subject'],
          photoUrl: json['photo_url'],
          gender: null,
          education: null,
          joinDate: json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
          isActive: true,
          password: json['password_hash'],
        );
      }).toList();

      teachers.value = teachersList;
      return teachersList;
    } catch (e, st) {
      developer.log(
        'Error fetching teachers: $e',
        name: 'TeacherService',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<Teacher?> getTeacherById(String id) async {
    try {
      final response = await _apiClient.get('/api/teachers/$id');
      return Teacher(
        id: response['id'].toString(),
        name: response['name'] ?? '',
        email: response['email'] ?? '',
        phone: response['phone'],
        nip: response['nik'],
        subject: response['subject'],
        gender: null,
        education: null,
        joinDate: response['created_at'] != null
            ? DateTime.parse(response['created_at'])
            : DateTime.now(),
        isActive: true,
      );
    } catch (e, st) {
      developer.log(
        'Error fetching teacher: $e',
        name: 'TeacherService',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  Future<Teacher> createTeacher(Teacher teacher) async {
    try {
      final response = await _apiClient.post('/api/teachers', {
        'nik': teacher.nip,
        'name': teacher.name,
        'email': teacher.email,
        'phone': teacher.phone,
        'role': 'guru',
        'subject': teacher.subject,
        'password': '123456', // Default password
      }, needsAuth: true);

      await getAllTeachers(); // Refresh list
      return Teacher(
        id: response['id'].toString(),
        name: teacher.name,
        email: teacher.email,
        phone: teacher.phone,
        nip: teacher.nip,
        subject: teacher.subject,
      );
    } catch (e, st) {
      developer.log(
        'Error creating teacher: $e',
        name: 'TeacherService',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> updateTeacher(String id, Teacher teacher) async {
    try {
      await _apiClient.put('/api/teachers/$id', {
        'nik': teacher.nip,
        'name': teacher.name,
        'email': teacher.email,
        'phone': teacher.phone,
        'role': 'guru',
        'subject': teacher.subject,
      });

      await getAllTeachers(); // Refresh list
    } catch (e, st) {
      developer.log(
        'Error updating teacher: $e',
        name: 'TeacherService',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> deleteTeacher(String id) async {
    try {
      await _apiClient.delete('/api/teachers/$id');
      teachers.removeWhere((t) => t.id == id);
    } catch (e, st) {
      developer.log(
        'Error deleting teacher: $e',
        name: 'TeacherService',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> uploadTeacherPhoto(String id, File photo) async {
    try {
      await _apiClient.postMultipart(
        '/api/teachers/$id/photo',
        {}, // empty fields
        'photo', // file field name
        photo.path, // file path
      );
      await getAllTeachers(); // Refresh list
    } catch (e, st) {
      developer.log(
        'Error uploading teacher photo: $e',
        name: 'TeacherService',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
