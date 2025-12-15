// lib/app/data/models/parent_model.dart

class Parent {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? relation; // 'ayah', 'ibu', 'wali'
  final String? occupation;
  final String? photoUrl;
  final String? address;
  final List<String> studentIds; // ID siswa yang menjadi anak/wali
  final bool isActive;
  final String? password; // For display only
  final String? studentNisn; // NISN anak
  final String? fatherName; // Nama Ayah
  final String? motherName; // Nama Ibu

  Parent({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.relation,
    this.occupation,
    this.photoUrl,
    this.address,
    this.studentIds = const [],
    this.isActive = true,
    this.password,
    this.studentNisn,
    this.fatherName,
    this.motherName,
  });

  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      relation: json['relation'],
      occupation: json['occupation'],
      photoUrl: json['photo_url'],
      address: json['address'],
      studentIds: json['student_ids'] != null
          ? List<String>.from(json['student_ids'])
          : [],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      password: json['password_hash'],
      studentNisn: json['student_nisn'],
      fatherName: json['father_name'],
      motherName: json['mother_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'relation': relation,
      'occupation': occupation,
      'photo_url': photoUrl,
      'address': address,
      'student_ids': studentIds,
      'is_active': isActive ? 1 : 0,
    };
  }

  Parent copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? relation,
    String? occupation,
    String? photoUrl,
    String? address,
    List<String>? studentIds,
    bool? isActive,
  }) {
    return Parent(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      relation: relation ?? this.relation,
      occupation: occupation ?? this.occupation,
      photoUrl: photoUrl ?? this.photoUrl,
      address: address ?? this.address,
      studentIds: studentIds ?? this.studentIds,
      isActive: isActive ?? this.isActive,
    );
  }
}
