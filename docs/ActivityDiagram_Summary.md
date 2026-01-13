# Activity Diagram Summary - Sapa Raudha Mobile App

## File-file yang Telah Dibuat:

### 1. ActivityDiagram_Login.mdj ✅
**Use Case:** Login (Guru & Orang Tua)
**Swimlanes:** 
- User (Guru/Orang Tua)
- System

**Key Activities:**
- Buka Aplikasi
- Input Username & Password
- Validasi Kredensial
- Decision: Valid/Invalid
- Decision: Guru/Orang Tua
- Redirect ke Dashboard
- Simpan Session/Token

**Decision Points:**
- Validasi kredensial (Valid/Invalid)
- Role user (Guru/Orang Tua)

---

### 2. ActivityDiagram_ScanPresensi.mdj ✅
**Use Case:** Scan Presensi Siswa (Guru)
**Swimlanes:**
- Guru
- System

**Key Activities:**
- Pilih Menu Scan Presensi
- Tampilkan Daftar Kelas
- Pilih Kelas
- Aktifkan Kamera
- **Loop:** Scan QR Code Siswa
- Validasi QR Code
- Cek Siswa Terdaftar
- Cek Sudah Presensi
- Catat Kehadiran
- Tampilkan Rekap
- Simpan ke Server

**Decision Points:**
- QR Valid/Invalid
- Siswa Terdaftar/Tidak
- Sudah Presensi/Belum
- Selesai Scan/Lanjut

**Loop:** Scan siswa berikutnya (kembali ke Scan QR jika belum selesai)

---

## Cara Menggunakan File .mdj:

### 1. **Buka di StarUML**
```
File → Open → Pilih file .mdj
```

### 2. **Edit Layout**
- Drag & drop nodes untuk merapikan posisi
- Klik kanan pada diagram → Auto Layout (opsional)

### 3. **Tambahkan Control Flow**
- Klik toolbar "Control Flow" atau "Transition"
- Drag dari node source ke target
- Tambahkan guard condition pada Decision Node:
  - Klik edge/panah
  - Di Properties, isi "Guard" (contoh: [Valid], [Invalid])

### 4. **Customization**
- Warna: Klik node → Properties → fillColor
- Font: Properties → font
- Size: Drag corner untuk resize

### 5. **Export**
```
File → Export Diagram → 
- PNG (untuk laporan)
- PDF (untuk presentasi)
- SVG (untuk editing lanjut)
```

---

## Standar Notasi UML Activity Diagram:

### Symbols:
- ⚫ **Initial Node** (filled circle) - Start
- ⭕ **Activity Final Node** (circle with filled circle inside) - End
- ▭ **Action** (rounded rectangle) - Aktivitas
- ◇ **Decision Node** (diamond) - Percabangan
- ◇ **Merge Node** (diamond) - Penggabungan
- ▭ **Fork/Join** (thick bar) - Parallel activities

### Guard Conditions:
Tulis di edge/panah untuk decision:
- `[Valid]`, `[Invalid]`
- `[Ya]`, `[Tidak]`
- `[Guru]`, `[Orang Tua]`

### Loop:
Gunakan edge dari activity akhir kembali ke activity awal loop dengan guard condition

---

## File Selanjutnya yang Akan Dibuat:

3. ⏳ ActivityDiagram_ReviewIzin.mdj - Review Permohonan Izin (Guru)
4. ⏳ ActivityDiagram_AjukanIzin.mdj - Ajukan Permohonan Izin (Orang Tua)  
5. ⏳ ActivityDiagram_BuatPengumuman.mdj - Buat Pengumuman (Guru)
6. ⏳ ActivityDiagram_LihatKehadiran.mdj - Lihat Kehadiran Anak (Orang Tua)

---

## Tips untuk Laporan KP:

### Di Bab Analisis Sistem:
1. **Jelaskan tujuan** activity diagram
2. **Describe flow** untuk setiap diagram (1-2 paragraf)
3. **Highlight decision points** & business rules
4. **Insert diagram** sebagai gambar (PNG/PDF)
5. **Beri caption & numbering** (Gambar 3.1, Gambar 3.2, dst)

### Format Caption:
```
Gambar 3.1 Activity Diagram Login
Gambar 3.2 Activity Diagram Scan Presensi Siswa
Gambar 3.3 Activity Diagram Review Permohonan Izin
```

### Penjelasan per Diagram (Template):
```
Activity diagram [nama use case] menggambarkan alur proses [deskripsi singkat].
Proses dimulai dari [initial action], kemudian [step berikutnya]. 
Terdapat decision point pada [nama decision] dengan kondisi [guard conditions].
Proses berakhir ketika [kondisi end].
```

---

**Status:** 2/6 Activity Diagrams telah dibuat ✅
**Next:** Membuat 4 activity diagram tersisa
