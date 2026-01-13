# Penjelasan Sequence Diagram

## 1. Login (Guru & Orang Tua)
Sequence diagram ini menggambarkan proses autentikasi pengguna (guru dan orang tua) di aplikasi Sapa Raudha. Pengguna memasukkan NIK/NISN dan password melalui halaman login, sistem mengirimkan kredensial ke API server yang kemudian melakukan query ke database untuk verifikasi data. Setelah user tervalidasi, database mengembalikan data pengguna beserta role-nya, API server menghasilkan token autentikasi dan mengembalikannya ke aplikasi, token disimpan di storage lokal, dan pengguna diarahkan ke dashboard sesuai dengan role mereka (guru atau orang tua).

## 2. Ajukan Izin (Orang Tua)
Sequence diagram ini mendeskripsikan alur pengajuan izin oleh orang tua untuk anaknya di sekolah. Orang tua memilih menu ajukan izin dan melihat form kosong, kemudian mengisi formulir dengan data seperti tanggal izin, alasan, dan lampiran pendukung jika ada, setelah mengklik submit, sistem mengirimkan data ke API server yang melakukan insert record izin baru ke database, kemudian sistem menangani upload lampiran jika ada, dan memberikan konfirmasi sukses kepada pengguna dengan menampilkan nomor referensi izin yang telah dibuat.

## 3. Buat Pengumuman (Guru)
Sequence diagram ini menunjukkan proses pembuatan dan publikasi pengumuman oleh guru kepada orang tua dan siswa. Guru memilih menu buat pengumuman dan mengisi formulir dengan judul, isi konten, serta lampiran opsional (seperti dokumen atau gambar), setelah mengklik publikasikan, sistem mengirimkan data pengumuman ke API server untuk disimpan ke database dengan ID unik, jika ada lampiran maka sistem melakukan upload file ke storage, dan terakhir sistem menampilkan konfirmasi kesuksesan pengumuman telah dipublikasikan.

## 4. Review Izin (Guru)
Sequence diagram ini menggambarkan proses review dan persetujuan izin oleh guru terhadap pengajuan izin dari orang tua. Guru memilih menu review izin dan sistem mengambil daftar izin dengan status pending dari database melalui API server, guru dapat memilih satu izin dan melihat detail lengkapnya termasuk alasan dan lampiran, guru kemudian membuat keputusan untuk menyetujui atau menolak dengan memberikan catatan, sistem mengirimkan update status ke API server yang mengubah status izin di database, dan menampilkan konfirmasi kesuksesan perubahan status.

## 5. Lihat Kehadiran (Orang Tua)
Sequence diagram ini menunjukkan cara orang tua memantau rekam kehadiran anaknya di sekolah melalui aplikasi. Orang tua memilih menu kehadiran dan sistem mengambil data presensi siswa dari database berdasarkan ID siswa melalui query API server, sistem menampilkan rekap kehadiran dalam format ringkas (misalnya persentase kehadiran, jumlah hadir dan absen), orang tua dapat memilih untuk melihat detail harian untuk melihat informasi lebih detail tentang setiap hari seperti jam masuk, jam pulang, dan keterangan.

## 6. Lihat Pengumuman (Guru & Orang Tua)
Sequence diagram ini mendeskripsikan alur pengambilan dan tampilan daftar pengumuman untuk guru dan orang tua. Pengguna memilih menu pengumuman dan sistem mengambil daftar pengumuman dari database melalui API server dengan urutan terbaru terlebih dahulu, sistem menampilkan daftar pengumuman dalam format list dengan judul dan tanggal, pengguna dapat memilih satu pengumuman untuk melihat detail lengkap termasuk isi konten, dan jika ada lampiran dapat mengunduhnya dengan mengklik tombol download yang tersedia.

## 7. Scan Presensi (QR Code)
Sequence diagram ini menunjukkan mekanisme presensi modern menggunakan pemindai QR code di aplikasi. Guru atau siswa membuka halaman scan presensi dan sistem membuka akses ke kamera perangkat, pengguna mengarahkan kamera ke QR code yang ditampilkan di pintu masuk atau papan absensi, aplikasi melakukan scan dan mengekstrak data NISN siswa dari QR code, sistem mengirimkan NISN ke API server untuk mencari data siswa di database dan melakukan insert record presensi baru dengan timestamp otomatis, data presensi disimpan dan sistem menampilkan konfirmasi bahwa presensi telah berhasil dicatat.

## 8. Update Profile Photo (User)
Sequence diagram ini menggambarkan proses update foto profil pengguna (guru atau orang tua) di aplikasi. Pengguna memilih menu update foto profil dan sistem menampilkan pilihan sumber foto (kamera untuk ambil foto baru atau galeri untuk memilih foto yang sudah ada), pengguna memilih sumber dan memilih atau mengambil foto yang ingin dijadikan foto profil, sistem menampilkan preview foto untuk konfirmasi, setelah pengguna mengkonfirmasi, sistem melakukan upload foto ke storage server, mengubah URL foto di database dengan record pengguna, dan menampilkan pesan sukses bahwa foto profil telah diperbarui.
