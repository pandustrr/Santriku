#  Santriku - Aplikasi Mobile Pondok Pesantren Digital

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter Badge"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart Badge"/>
  <img src="https://img.shields.io/badge/Material--3-795548?style=for-the-badge" alt="Material 3 Badge"/>
</p>

**Santriku** adalah aplikasi mobile berbasis Flutter yang dirancang untuk mendigitalisasi operasional harian di lingkungan Pondok Pesantren. Proyek ini dibuat berdasarkan **Proposal Kelompok 11 - Proyek Pengembangan Aplikasi Mobile (PBM)**, Universitas Jember.

Aplikasi ini mengintegrasikan sistem pelacakan kehadiran berbasis QR Code, manajemen konsumsi harian santri, dan pengajuan perizinan keluar pondok secara digital.

---

##  Fitur Utama Berdasarkan Role

Aplikasi ini membagi hak akses dan fitur menjadi 3 peranan utama:

### 1. Admin
* **Dashboard Ringkasan**: Statistik jumlah santri aktif, pengurus, wali santri, dan tingkat kehadiran hari ini.
* **Kelola Pengguna**: Penambahan, pembaruan, dan penonaktifan akun santri, pengurus, serta wali santri.
* **Rekap Laporan**: Unduh rekapitulasi data absensi bulanan untuk keperluan evaluasi pesantren.

### 2. Pengurus
* **Scan Absensi QR**: Memindai kode QR kartu santri untuk mencatat kehadiran kegiatan wajib (shalat berjamaah, pengajian, sekolah).
* **Scan Konsumsi QR**: Memvalidasi jatah makan harian santri untuk mencegah pengambilan ganda.
* **Persetujuan Perizinan**: Panel persetujuan cepat (Approve/Reject) untuk surat perizinan santri yang diajukan oleh wali.

### 3. Wali Santri
* **Real-time Monitoring**: Memantau kehadiran santri di pondok serta status makan harian.
* **Pengajuan Izin Digital**: Formulir izin sakit/acara keluarga dilengkapi dengan opsi unggah dokumen bukti (misal: surat keterangan dokter).
* **Riwayat Aktivitas**: Laporan riwayat log harian santri yang langsung terhubung ke dashboard orang tua.

---

## Struktur Proyek 

Proyek ini menggunakan struktur folder modular untuk memudahkan perluasan fitur (scalability) di masa depan:

```
lib/
├── main.dart                          # Entry point aplikasi & konfigurasi global
├── core/                              # Sumber daya bersama (Shared Resources)
│   ├── core.dart                      # Barrel export modul core
│   ├── constants/
│   │   └── app_strings.dart           # String statis teks aplikasi
│   ├── models/
│   │   └── user_role.dart             # Model enum & helper UserRole
│   └── theme/
│       ├── app_colors.dart            # Palet warna khas pesantren (Teal & Gold)
│       └── app_theme.dart             # Tema global aplikasi (Dark Theme & Poppins)
│
└── features/                          # Fitur aplikasi berbasis modul & role
    ├── auth/                          # Modul Autentikasi
    │   ├── auth.dart                  # Barrel export modul auth
    │   ├── screens/
    │   │   └── login_screen.dart      # Form Login dengan pemilihan role interaktif
    │   └── widgets/                   # Widget kustom khusus autentikasi
    │
    ├── admin/                         # Modul Fitur Admin
    │   ├── admin.dart
    │   └── screens/
    │       └── admin_dashboard_screen.dart
    │
    ├── pengurus/                      # Modul Fitur Pengurus
    │   ├── pengurus.dart
    │   └── screens/
    │       ├── pengurus_dashboard_screen.dart
    │       ├── scan_qr_screen.dart    # Mock scanner kamera dengan garis laser animasi
    │       └── absensi_result_screen.dart # Hasil status scan QR
    │
    └── wali/                          # Modul Fitur Wali Santri
        ├── wali.dart
        └── screens/
            ├── wali_dashboard_screen.dart
            └── pengajuan_izin_screen.dart
```