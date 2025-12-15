import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sapa_raudha/app/utils/app_colors.dart';
import 'admin_student_form_controller.dart';

class AdminStudentFormView extends GetView<AdminStudentFormController> {
  const AdminStudentFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.alternate),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Siswa',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        // Photo picker
                        Center(
                          child: Column(
                            children: [
                              Obx(() {
                                final photoFile =
                                    controller.selectedPhoto.value;
                                final photoUrl =
                                    controller.existingStudent?['photo_url'];

                                return GestureDetector(
                                  onTap: controller.pickPhoto,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: AppColors.alternate,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.primary,
                                        width: 2,
                                      ),
                                    ),
                                    child: photoFile != null
                                        ? ClipOval(
                                            child: Image.file(
                                              photoFile,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : photoUrl != null
                                        ? ClipOval(
                                            child: Image.network(
                                              photoUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Icon(
                                                      Icons.person,
                                                      size: 60,
                                                      color: AppColors
                                                          .secondaryText,
                                                    );
                                                  },
                                            ),
                                          )
                                        : Icon(
                                            Icons.person,
                                            size: 60,
                                            color: AppColors.secondaryText,
                                          ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: controller.pickPhoto,
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Pilih Foto'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controller.nisnController,
                                decoration: InputDecoration(
                                  labelText: 'NISN *',
                                  hintText: 'Masukkan NISN siswa',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.secondaryBackground,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'NISN tidak boleh kosong';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: controller.nisController,
                                decoration: InputDecoration(
                                  labelText: 'NIS',
                                  hintText: 'Masukkan NIS siswa',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.secondaryBackground,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: controller.nameController,
                          decoration: InputDecoration(
                            labelText: 'Nama Lengkap *',
                            hintText: 'Masukkan nama lengkap siswa',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: AppColors.secondaryBackground,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nama tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Obx(
                                () => DropdownButtonFormField<int>(
                                  initialValue:
                                      controller.selectedClassId.value,
                                  decoration: InputDecoration(
                                    labelText: 'Kelas *',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.secondaryBackground,
                                  ),
                                  items: controller.classes
                                      .map(
                                        (c) => DropdownMenuItem<int>(
                                          value: c['id'] as int,
                                          child: Text(c['name'] ?? ''),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) =>
                                      controller.selectedClassId.value = value,
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Kelas tidak boleh kosong';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Obx(
                                () => DropdownButtonFormField<String>(
                                  initialValue: controller.selectedGender.value,
                                  decoration: InputDecoration(
                                    labelText: 'Jenis Kelamin *',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.secondaryBackground,
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'L',
                                      child: Text('Laki-laki'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'P',
                                      child: Text('Perempuan'),
                                    ),
                                  ],
                                  onChanged: (value) =>
                                      controller.selectedGender.value = value,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Jenis kelamin tidak boleh kosong';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controller.birthPlaceController,
                                decoration: InputDecoration(
                                  labelText: 'Tempat Lahir *',
                                  hintText: 'Masukkan tempat lahir',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.secondaryBackground,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Tempat lahir tidak boleh kosong';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: controller.birthDateController,
                                decoration: InputDecoration(
                                  labelText: 'Tanggal Lahir *',
                                  hintText: 'Pilih tanggal lahir',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.secondaryBackground,
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                readOnly: true,
                                onTap: () =>
                                    controller.selectBirthDate(context),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Tanggal lahir tidak boleh kosong';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: controller.addressController,
                          decoration: InputDecoration(
                            labelText: 'Alamat *',
                            hintText: 'Masukkan alamat lengkap',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: AppColors.secondaryBackground,
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Alamat tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Data Orang Tua',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controller.fatherNameController,
                                decoration: InputDecoration(
                                  labelText: 'Nama Ayah',
                                  hintText: 'Masukkan nama ayah',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.secondaryBackground,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: controller.motherNameController,
                                decoration: InputDecoration(
                                  labelText: 'Nama Ibu',
                                  hintText: 'Masukkan nama ibu',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.secondaryBackground,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controller.fatherPhoneController,
                                decoration: InputDecoration(
                                  labelText: 'Telepon Ayah',
                                  hintText: 'Masukkan nomor telepon ayah',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.secondaryBackground,
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: controller.motherPhoneController,
                                decoration: InputDecoration(
                                  labelText: 'Telepon Ibu',
                                  hintText: 'Masukkan nomor telepon ibu',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.secondaryBackground,
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: controller.passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password Orang Tua *',
                            hintText: 'Masukkan password untuk login orang tua',
                            helperText: 'Password untuk login orang tua',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: AppColors.secondaryBackground,
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (controller.isEditMode.value == false) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Password tidak boleh kosong';
                              }
                              if (value.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Get.back(),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Batal'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Obx(
                                () => ElevatedButton(
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : controller.save,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: controller.isLoading.value
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : const Text('Simpan'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        border: Border(bottom: BorderSide(color: AppColors.alternate)),
      ),
    );
  }
}
