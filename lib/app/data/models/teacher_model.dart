// lib/app/data/models/teacher_model.dart

class Teacher {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? nip; // Nomor Induk Pegawai
  final String? subject; // Mata pelajaran yang diampu
  final String? photoUrl;
  final String? address;
  final String? gender;
  final DateTime? birthDate;
  final String? education; // Pendidikan terakhir
  final DateTime? joinDate; // Tanggal bergabung
  final bool isActive;
  final String? password; // For display only, not stored

  Teacher({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.nip,
    this.subject,
    this.photoUrl,
    this.address,
    this.gender,
    this.birthDate,
    this.education,
    this.joinDate,
    this.isActive = true,
    this.password,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      nip: json['nip'],
      subject: json['subject'],
      photoUrl: json['photo_url'],
      address: json['address'],
      gender: json['gender'],
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : null,
      education: json['education'],
      joinDate: json['join_date'] != null
          ? DateTime.parse(json['join_date'])
          : null,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      password: json['password_hash'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'nip': nip,
      'subject': subject,
      'photo_url': photoUrl,
      'address': address,
      'gender': gender,
      'birth_date': birthDate?.toIso8601String(),
      'education': education,
      'join_date': joinDate?.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  Teacher copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? nip,
    String? subject,
    String? photoUrl,
    String? address,
    String? gender,
    DateTime? birthDate,
    String? education,
    DateTime? joinDate,
    bool? isActive,
  }) {
    return Teacher(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      nip: nip ?? this.nip,
      subject: subject ?? this.subject,
      photoUrl: photoUrl ?? this.photoUrl,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      education: education ?? this.education,
      joinDate: joinDate ?? this.joinDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
