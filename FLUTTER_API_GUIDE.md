# Guide Migrasi API Flutter dari Node.js ke Laravel

## 📋 Ringkasan

Project Laravel Anda sudah memiliki API endpoints yang lengkap untuk aplikasi Flutter. API Laravel ini lebih robust, terintegrasi dengan sistem autentikasi Fortify, dan sudah memiliki controller yang terstruktur.

## 🔄 Perbandingan Endpoints

### 1. Authentication

#### Node.js (Lama)
```
POST /auth/login
```

#### Laravel (Baru)
```
POST /api/auth/login
```

**Request Body (sama):**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response Laravel:**
```json
{
  "two_factor": false
}
```

> **Catatan:** Laravel menggunakan session-based authentication. Untuk Flutter, Anda bisa menggunakan Sanctum untuk token-based authentication (lihat bagian setup di bawah).

---

### 2. Students

#### Node.js vs Laravel

| Node.js | Laravel | Metode | Deskripsi |
|---------|---------|--------|-----------|
| `GET /students` | `GET /api/students` | GET | List semua siswa |
| `GET /students/:id` | `GET /api/students/:id` | GET | Detail siswa by ID |
| `GET /students/nisn/:nisn` | `GET /api/students/:id` | GET | Detail siswa (gunakan ID) |
| - | `POST /api/students` | POST | Buat siswa baru |
| - | `PUT /api/students/:id` | PUT | Update siswa |
| - | `DELETE /api/students/:id` | DELETE | Hapus siswa |
| - | `GET /api/students/class/:classId` | GET | Siswa by kelas |
| - | `GET /api/students/statistics` | GET | Statistik siswa |
| - | `GET /api/students/:id/attendance` | GET | Riwayat absensi siswa |

**Response Laravel (GET /api/students):**
```json
{
  "data": [
    {
      "id": 1,
      "nisn": "1234567890",
      "nama_lengkap": "Ahmad Budi Santoso",
      "kelas_id": 1,
      "kelas": {
        "id": 1,
        "nama_kelas": "1A"
      },
      "jenis_kelamin": "L",
      "tanggal_lahir": "2015-01-15",
      "alamat": "Jl. Contoh No. 123"
    }
  ],
  "meta": {
    "current_page": 1,
    "total": 50
  }
}
```

---

### 3. Announcements (Pengumuman)

| Node.js | Laravel | Metode | Deskripsi |
|---------|---------|--------|-----------|
| `GET /announcements` | `GET /api/announcements` | GET | List pengumuman |
| `GET /announcements/:id` | `GET /api/announcements/:id` | GET | Detail pengumuman |
| `POST /announcements` | `POST /api/announcements` | POST | Buat pengumuman |
| `DELETE /announcements/:id` | `DELETE /api/announcements/:id` | DELETE | Hapus pengumuman |
| - | `PUT /api/announcements/:id` | PUT | Update pengumuman |
| - | `GET /api/announcements/class/:classId` | GET | Pengumuman by kelas |
| - | `POST /api/announcements/:id/upload-attachment` | POST | Upload lampiran |

**Request Body (POST /api/announcements):**
```json
{
  "judul": "Libur Nasional",
  "konten": "Sekolah libur pada tanggal...",
  "target_audience": "siswa",
  "target_kelas_id": null
}
```

**Response:**
```json
{
  "data": {
    "id": 1,
    "judul": "Libur Nasional",
    "konten": "Sekolah libur pada tanggal...",
    "penulis_id": 1,
    "penulis": {
      "id": 1,
      "name": "Admin",
      "email": "admin@example.com"
    },
    "target_audience": "siswa",
    "target_kelas_id": null,
    "attachments": [],
    "created_at": "2026-01-22T10:00:00.000000Z"
  }
}
```

---

### 4. Attendance (Kehadiran)

| Node.js | Laravel | Metode | Deskripsi |
|---------|---------|--------|-----------|
| `POST /attendance/scan` | `POST /api/attendance` | POST | Rekam presensi |
| `GET /attendance/student/:nisn` | `GET /api/students/:id/attendance` | GET | Riwayat absensi siswa |
| `GET /attendance/class/:classId/date/:date` | `GET /api/attendance/class-summary?kelas_id=:id&tanggal=:date` | GET | Absensi kelas |
| `GET /attendance/stats` | `GET /api/attendance/statistics` | GET | Statistik absensi |
| - | `POST /api/attendance/bulk-update` | POST | Update massal |
| - | `GET /api/attendance/student/:id/report` | GET | Laporan siswa |

**Request Body (POST /api/attendance):**
```json
{
  "siswa_id": 1,
  "tanggal": "2026-01-22",
  "status": "hadir",
  "waktu_masuk": "07:30:00",
  "keterangan": "Tepat waktu"
}
```

**Bulk Update:**
```json
{
  "attendances": [
    {
      "siswa_id": 1,
      "tanggal": "2026-01-22",
      "status": "hadir"
    },
    {
      "siswa_id": 2,
      "tanggal": "2026-01-22",
      "status": "izin"
    }
  ]
}
```

---

### 5. Leave Requests (Pengajuan Izin)

| Node.js | Laravel | Metode | Deskripsi |
|---------|---------|--------|-----------|
| `POST /leave-requests` | `POST /api/leave-requests` | POST | Ajukan izin |
| `GET /leave-requests` | `GET /api/leave-requests` | GET | List pengajuan |
| `PUT /leave-requests/:id/approve` | `POST /api/leave-requests/:id/approve` | POST | Setujui izin |
| `PUT /leave-requests/:id/reject` | `POST /api/leave-requests/:id/reject` | POST | Tolak izin |
| - | `GET /api/leave-requests/pending` | GET | Izin pending |
| - | `GET /api/leave-requests/student/:id` | GET | Izin by siswa |
| - | `POST /api/leave-requests/bulk-approve` | POST | Setujui massal |

**Request Body (POST /api/leave-requests):**
```json
{
  "siswa_id": 1,
  "tanggal_mulai": "2026-01-25",
  "tanggal_selesai": "2026-01-26",
  "alasan": "Sakit demam",
  "jenis": "sakit"
}
```

**Response:**
```json
{
  "data": {
    "id": 1,
    "siswa_id": 1,
    "siswa": {
      "id": 1,
      "nama_lengkap": "Ahmad Budi"
    },
    "tanggal_mulai": "2026-01-25",
    "tanggal_selesai": "2026-01-26",
    "alasan": "Sakit demam",
    "jenis": "sakit",
    "status": "pending",
    "disetujui_oleh": null,
    "catatan_persetujuan": null,
    "created_at": "2026-01-22T10:00:00.000000Z"
  }
}
```

---

### 6. Profile & User Management

| Endpoint | Metode | Deskripsi |
|----------|--------|-----------|
| `GET /api/users` | GET | List semua users |
| `GET /api/users/:id` | GET | Detail user |
| `POST /api/users` | POST | Buat user baru |
| `PUT /api/users/:id` | PUT | Update user |
| `DELETE /api/users/:id` | DELETE | Hapus user |
| `GET /api/users/by-role/:role` | GET | Users by role |
| `GET /api/users/statistics` | GET | Statistik users |
| `POST /api/users/:id/upload-photo` | POST | Upload foto profil |

---

### 7. Teachers & Parents

#### Teachers
| Endpoint | Metode | Deskripsi |
|----------|--------|-----------|
| `GET /api/teachers` | GET | List guru |
| `POST /api/teachers` | POST | Buat guru baru |
| `GET /api/teachers/:id` | GET | Detail guru |
| `PUT /api/teachers/:id` | PUT | Update guru |
| `DELETE /api/teachers/:id` | DELETE | Hapus guru |

#### Parents
| Endpoint | Metode | Deskripsi |
|----------|--------|-----------|
| `GET /api/parents` | GET | List orang tua |
| `POST /api/parents` | POST | Buat orang tua baru |
| `GET /api/parents/:id` | GET | Detail orang tua |
| `PUT /api/parents/:id` | PUT | Update orang tua |
| `DELETE /api/parents/:id` | DELETE | Hapus orang tua |

---

## 🔧 Setup Laravel untuk Flutter

### 1. Install Laravel Sanctum (Token-based Authentication)

Laravel Sanctum sudah terinstall secara default di Laravel 11. Untuk mengaktifkannya:

**File: `config/sanctum.php`**
```php
'stateful' => explode(',', env('SANCTUM_STATEFUL_DOMAINS', sprintf(
    '%s%s',
    'localhost,localhost:3000,127.0.0.1,127.0.0.1:8000,::1',
    Sanctum::currentApplicationUrlWithPort()
))),
```

### 2. Update User Model untuk Sanctum

**File: `app/Models/User.php`**
```php
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, TwoFactorAuthenticatable;
    
    // ... rest of the code
}
```

### 3. Modifikasi Login API untuk Return Token

Buat controller baru untuk API Authentication:

**File: `app/Http/Controllers/Api/AuthController.php`**
```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use App\Models\User;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Login API untuk Flutter
     */
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
            'device_name' => 'string|nullable'
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        // Buat token
        $token = $user->createToken($request->device_name ?? 'flutter-app')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
            ]
        ]);
    }

    /**
     * Logout API
     */
    public function logout(Request $request)
    {
        // Revoke current token
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logged out successfully'
        ]);
    }

    /**
     * Get current user profile
     */
    public function profile(Request $request)
    {
        return response()->json([
            'user' => $request->user()
        ]);
    }
}
```

### 4. Update API Routes

**File: `routes/api.php`**

Ganti bagian authentication dengan:

```php
use App\Http\Controllers\Api\AuthController;

// Public authentication routes
Route::post('/auth/login', [AuthController::class, 'login']);

// Protected routes dengan Sanctum
Route::middleware('auth:sanctum')->group(function () {
    // Auth endpoints
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/profile', [AuthController::class, 'profile']);
    
    // User Management Routes
    Route::prefix('users')->group(function () {
        Route::get('/', [UserController::class, 'index']);
        Route::post('/', [UserController::class, 'store']);
        Route::get('/statistics', [UserController::class, 'getStatistics']);
        Route::get('/by-role/{role}', [UserController::class, 'getByRole']);
        Route::get('/{id}', [UserController::class, 'show']);
        Route::put('/{id}', [UserController::class, 'update']);
        Route::delete('/{id}', [UserController::class, 'destroy']);
        Route::post('/{id}/upload-photo', [UserController::class, 'uploadPhoto']);
    });

    // ... rest of your routes
});
```

### 5. Setup CORS

**File: `config/cors.php`**
```php
return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['*'], // Untuk development, di production gunakan domain spesifik
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => true,
];
```

### 6. Environment Variables

**File: `.env`**
```env
APP_URL=http://localhost:8000
SANCTUM_STATEFUL_DOMAINS=localhost:3000,127.0.0.1:8000
SESSION_DRIVER=cookie
SESSION_DOMAIN=localhost
```

---

## 📱 Implementasi di Flutter

### 1. Setup HTTP Client dengan Token

**File: `lib/services/api_service.dart`**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://your-domain.com/api';
  
  // Get token dari storage
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  // Save token ke storage
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  // Clear token (logout)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
  
  // Get headers dengan token
  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'device_name': 'flutter-app',
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['token']);
      return data;
    } else {
      throw Exception('Login failed');
    }
  }
  
  // Logout
  Future<void> logout() async {
    final headers = await getHeaders();
    await http.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: headers,
    );
    await clearToken();
  }
  
  // Generic GET request
  Future<dynamic> get(String endpoint) async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
  
  // Generic POST request
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to post data');
    }
  }
  
  // Generic PUT request
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final headers = await getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update data');
    }
  }
  
  // Generic DELETE request
  Future<dynamic> delete(String endpoint) async {
    final headers = await getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    
    if (response.statusCode == 200 || response.statusCode == 204) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return null;
    } else {
      throw Exception('Failed to delete data');
    }
  }
}
```

### 2. Contoh Implementasi untuk Students

**File: `lib/services/student_service.dart`**
```dart
import 'api_service.dart';
import '../models/student.dart';

class StudentService {
  final ApiService _apiService = ApiService();
  
  // Get all students
  Future<List<Student>> getStudents({int? classId}) async {
    String endpoint = '/students';
    if (classId != null) {
      endpoint = '/students/class/$classId';
    }
    
    final response = await _apiService.get(endpoint);
    final List<dynamic> data = response['data'];
    return data.map((json) => Student.fromJson(json)).toList();
  }
  
  // Get student by ID
  Future<Student> getStudent(int id) async {
    final response = await _apiService.get('/students/$id');
    return Student.fromJson(response['data']);
  }
  
  // Get student attendance
  Future<List<Attendance>> getStudentAttendance(int studentId) async {
    final response = await _apiService.get('/students/$studentId/attendance');
    final List<dynamic> data = response['data'];
    return data.map((json) => Attendance.fromJson(json)).toList();
  }
}
```

### 3. Contoh Model Student

**File: `lib/models/student.dart`**
```dart
class Student {
  final int id;
  final String nisn;
  final String namaLengkap;
  final int? kelasId;
  final String? jenisKelamin;
  final String? tanggalLahir;
  final String? alamat;
  final Kelas? kelas;
  
  Student({
    required this.id,
    required this.nisn,
    required this.namaLengkap,
    this.kelasId,
    this.jenisKelamin,
    this.tanggalLahir,
    this.alamat,
    this.kelas,
  });
  
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      nisn: json['nisn'],
      namaLengkap: json['nama_lengkap'],
      kelasId: json['kelas_id'],
      jenisKelamin: json['jenis_kelamin'],
      tanggalLahir: json['tanggal_lahir'],
      alamat: json['alamat'],
      kelas: json['kelas'] != null ? Kelas.fromJson(json['kelas']) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nisn': nisn,
      'nama_lengkap': namaLengkap,
      'kelas_id': kelasId,
      'jenis_kelamin': jenisKelamin,
      'tanggal_lahir': tanggalLahir,
      'alamat': alamat,
    };
  }
}

class Kelas {
  final int id;
  final String namaKelas;
  
  Kelas({required this.id, required this.namaKelas});
  
  factory Kelas.fromJson(Map<String, dynamic> json) {
    return Kelas(
      id: json['id'],
      namaKelas: json['nama_kelas'],
    );
  }
}
```

### 4. Contoh Penggunaan di Widget

**File: `lib/screens/students_screen.dart`**
```dart
import 'package:flutter/material.dart';
import '../services/student_service.dart';
import '../models/student.dart';

class StudentsScreen extends StatefulWidget {
  @override
  _StudentsScreenState createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final StudentService _studentService = StudentService();
  List<Student> _students = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadStudents();
  }
  
  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final students = await _studentService.getStudents();
      setState(() {
        _students = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    return ListView.builder(
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final student = _students[index];
        return ListTile(
          title: Text(student.namaLengkap),
          subtitle: Text('NISN: ${student.nisn} - Kelas: ${student.kelas?.namaKelas ?? '-'}'),
          onTap: () {
            // Navigate to detail
          },
        );
      },
    );
  }
}
```

---

## 🚀 Langkah-langkah Migrasi

### 1. Persiapan Laravel

```bash
# 1. Pastikan semua dependencies terinstall
composer install

# 2. Setup database
php artisan migrate

# 3. Generate application key (jika belum)
php artisan key:generate

# 4. Create storage link untuk file uploads
php artisan storage:link

# 5. Setup permissions untuk storage
chmod -R 775 storage bootstrap/cache

# 6. Jalankan server
php artisan serve
```

### 2. Testing API dengan Postman/Thunder Client

#### Login
```http
POST http://localhost:8000/api/auth/login
Content-Type: application/json

{
  "email": "admin@example.com",
  "password": "password",
  "device_name": "postman"
}
```

Response:
```json
{
  "token": "1|xxxxxxxxxxxxxxxxxxxxxx",
  "user": {
    "id": 1,
    "name": "Admin",
    "email": "admin@example.com",
    "role": "admin"
  }
}
```

#### Get Students (dengan token)
```http
GET http://localhost:8000/api/students
Authorization: Bearer 1|xxxxxxxxxxxxxxxxxxxxxx
```

### 3. Update Flutter App

1. **Update base URL** di `ApiService`:
   ```dart
   static const String baseUrl = 'http://192.168.1.100:8000/api'; // IP server Anda
   ```

2. **Update semua endpoint calls** sesuai mapping di atas

3. **Update models** untuk match dengan response Laravel

4. **Test authentication flow**

5. **Test semua fitur** satu per satu

---

## 📝 Checklist Migrasi

- [ ] Setup Laravel Sanctum
- [ ] Buat AuthController untuk Flutter
- [ ] Update API routes
- [ ] Setup CORS
- [ ] Test authentication dengan Postman
- [ ] Update Flutter ApiService
- [ ] Update semua service classes di Flutter
- [ ] Update semua models di Flutter
- [ ] Test login flow
- [ ] Test students endpoints
- [ ] Test announcements endpoints
- [ ] Test attendance endpoints
- [ ] Test leave requests endpoints
- [ ] Test file upload/download
- [ ] Handle error responses
- [ ] Update UI untuk menampilkan data baru
- [ ] Testing end-to-end

---

## ⚠️ Perbedaan Penting

### 1. Authentication
- **Node.js**: Manual JWT implementation
- **Laravel**: Laravel Sanctum (lebih aman, built-in)

### 2. Response Format
- **Node.js**: Direct data object
- **Laravel**: Wrapped dalam `data` key (dapat dimodifikasi di controller)

### 3. File Upload
- **Node.js**: Manual handling
- **Laravel**: Built-in file storage system dengan `Storage` facade

### 4. Validation
- **Node.js**: Manual validation
- **Laravel**: FormRequest validation (lebih robust)

### 5. Error Handling
- **Node.js**: Custom error messages
- **Laravel**: Standardized error responses dengan HTTP status codes

---

## 🔒 Security Considerations

1. **CORS**: Konfigurasi dengan benar untuk production
2. **HTTPS**: Gunakan HTTPS di production
3. **Token Expiration**: Set expiration time untuk tokens
4. **Rate Limiting**: Aktifkan rate limiting di Laravel
5. **Input Validation**: Semua input harus divalidasi
6. **SQL Injection**: Laravel Eloquent sudah protect by default
7. **XSS Protection**: Sanitize semua user input

---

## 🐛 Troubleshooting

### Token tidak valid
- Pastikan token disimpan dengan benar
- Check format: `Bearer <token>`
- Token mungkin expired, login ulang

### CORS Error
- Update `config/cors.php`
- Pastikan headers correct di Flutter

### 401 Unauthorized
- Token tidak ada atau invalid
- Redirect ke login screen

### File upload gagal
- Check permissions folder `storage`
- Check max upload size di `php.ini`

### Database connection error
- Check `.env` file
- Pastikan MySQL running
- Check credentials

---

## 📚 Resources

- [Laravel Sanctum Documentation](https://laravel.com/docs/11.x/sanctum)
- [Flutter HTTP Package](https://pub.dev/packages/http)
- [Flutter Dio Package](https://pub.dev/packages/dio) (Alternative, lebih powerful)
- [Laravel API Resources](https://laravel.com/docs/11.x/eloquent-resources)

---

## 🎯 Next Steps

1. Buat AuthController di Laravel
2. Update routes/api.php
3. Test dengan Postman
4. Update Flutter app satu fitur per satu
5. Deploy ke production

---

**Catatan**: Guide ini dapat disesuaikan dengan kebutuhan spesifik aplikasi Anda. Jika ada pertanyaan atau butuh bantuan implementasi, silakan tanya!
