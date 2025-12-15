// lib/app/data/services/parent_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/parent_model.dart';
import 'api_client.dart';

class ParentService extends GetxService {
  final RxList<Parent> parents = <Parent>[].obs;
  late final ApiClient _apiClient;

  @override
  void onInit() {
    super.onInit();
    _apiClient = Get.find<ApiClient>();
  }

  Future<List<Parent>> getAllParents() async {
    try {
      final data = await _apiClient.getList('/api/parents');

      final parentsList = data.map((json) {
        // Determine primary contact name
        String name =
            json['father_name'] ??
            json['mother_name'] ??
            json['guardian_name'] ??
            'Unknown';
        String? relation;
        String? occupation;
        String? phone;

        if (json['father_name'] != null) {
          relation = 'Ayah';
          occupation = json['father_job'];
          phone = json['father_phone'];
        } else if (json['mother_name'] != null) {
          relation = 'Ibu';
          occupation = json['mother_job'];
          phone = json['mother_phone'];
        } else if (json['guardian_name'] != null) {
          relation = 'Wali';
          occupation = json['guardian_job'];
          phone = json['guardian_phone'];
        }

        return Parent(
          id: json['id'].toString(),
          name: name,
          email: '', // Not in DB schema
          phone: phone,
          relation: relation,
          occupation: occupation,
          photoUrl: json['photo_url'],
          studentIds: [json['student_id'].toString()],
          isActive: true,
          password: json['password_hash'],
          studentNisn: json['student_nisn'],
          fatherName: json['father_name'],
          motherName: json['mother_name'],
        );
      }).toList();

      parents.value = parentsList;
      return parentsList;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching parents: $e');
      }
      rethrow;
    }
  }

  Future<Parent?> getParentById(String id) async {
    try {
      final response = await _apiClient.get('/api/parents/$id');

      String name =
          response['father_name'] ??
          response['mother_name'] ??
          response['guardian_name'] ??
          'Unknown';
      String? relation;
      String? occupation;
      String? phone;

      if (response['father_name'] != null) {
        relation = 'Ayah';
        occupation = response['father_job'];
        phone = response['father_phone'];
      } else if (response['mother_name'] != null) {
        relation = 'Ibu';
        occupation = response['mother_job'];
        phone = response['mother_phone'];
      } else if (response['guardian_name'] != null) {
        relation = 'Wali';
        occupation = response['guardian_job'];
        phone = response['guardian_phone'];
      }

      return Parent(
        id: response['id'].toString(),
        name: name,
        email: '',
        phone: phone,
        relation: relation,
        occupation: occupation,
        studentIds: [response['student_id'].toString()],
        isActive: true,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching parent: $e');
      }
      return null;
    }
  }

  Future<void> createParent(Parent parent) async {
    try {
      await _apiClient.post('/api/parents', {
        'student_id': parent.studentIds.isNotEmpty
            ? int.parse(parent.studentIds.first)
            : 0,
        'father_name': parent.relation == 'Ayah' ? parent.name : null,
        'father_job': parent.relation == 'Ayah' ? parent.occupation : null,
        'father_phone': parent.relation == 'Ayah' ? parent.phone : null,
        'mother_name': parent.relation == 'Ibu' ? parent.name : null,
        'mother_job': parent.relation == 'Ibu' ? parent.occupation : null,
        'mother_phone': parent.relation == 'Ibu' ? parent.phone : null,
        'guardian_name': parent.relation == 'Wali' ? parent.name : null,
        'guardian_job': parent.relation == 'Wali' ? parent.occupation : null,
        'guardian_phone': parent.relation == 'Wali' ? parent.phone : null,
        'password': '123456', // Default password
      }, needsAuth: true);

      await getAllParents(); // Refresh list
    } catch (e) {
      if (kDebugMode) {
        print('Error creating parent: $e');
      }
      rethrow;
    }
  }

  Future<void> updateParent(String id, Parent parent) async {
    try {
      // Build request body with only non-null values
      final Map<String, dynamic> body = {};

      if (parent.studentIds.isNotEmpty) {
        body['student_id'] = int.parse(parent.studentIds.first);
      }

      // Father data - use fatherName property, not relation-based logic
      if (parent.fatherName != null && parent.fatherName!.isNotEmpty) {
        body['father_name'] = parent.fatherName;
      }

      // Mother data - use motherName property, not relation-based logic
      if (parent.motherName != null && parent.motherName!.isNotEmpty) {
        body['mother_name'] = parent.motherName;
      }

      // Phone number
      if (parent.phone != null && parent.phone!.isNotEmpty) {
        body['father_phone'] = parent.phone;
        body['mother_phone'] = parent.phone;
      }

      await _apiClient.put('/api/parents/$id', body);

      await getAllParents(); // Refresh list
    } catch (e) {
      if (kDebugMode) {
        print('Error updating parent: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteParent(String id) async {
    try {
      await _apiClient.delete('/api/parents/$id');
      parents.removeWhere((p) => p.id == id);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting parent: $e');
      }
      rethrow;
    }
  }

  Future<void> uploadParentPhoto(String id, File photo) async {
    try {
      await _apiClient.postMultipart(
        '/api/parents/$id/photo',
        {}, // empty fields
        'photo', // file field name
        photo.path, // file path
      );
      await getAllParents(); // Refresh list
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading parent photo: $e');
      }
      rethrow;
    }
  }
}
