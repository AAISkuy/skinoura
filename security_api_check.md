# Laporan Keamanan API Key

Dokumen ini berisi analisis keamanan dan rekomendasi penanganan terkait temuan kunci API rahasia (*secret API key*) dengan format `sk_live_***`.

---

## 1. Analisis Temuan

* **Tipe Kunci**: Live Secret API Key (kemungkinan Stripe atau layanan sejenis).
* **Risiko Keamanan**: **Kritis (Critical)**. Kunci dengan awalan `sk_live_` adalah kunci produksi aktif yang memberikan akses penuh ke akun atau layanan terkait (seperti sistem pembayaran, database, atau API berbayar).
* **Pencarian Lokal**: Pencarian di dalam codebase lokal proyek **Skinoura** tidak menemukan referensi hardcoded dari kunci API yang bersangkutan.

---

## 2. Risiko Jika Kunci API Bocor

Jika kunci API rahasia ini terekspos di tempat umum (misalnya di repositori GitHub publik, log aplikasi, atau kode frontend):

1. **Akses Tidak Sah**: Pihak ketiga dapat melakukan transaksi, membaca data sensitif pengguna, atau memodifikasi konfigurasi akun Anda.
2. **Kerugian Finansial**: Penggunaan API secara berlebihan oleh pihak yang tidak bertanggung jawab dapat menyebabkan tagihan membengkak secara drastis.
3. **Penyalahgunaan Data**: Data transaksi atau data pribadi pengguna yang dikelola oleh API tersebut dapat diunduh atau disalahgunakan.

---

## 3. Langkah Mitigasi (Tindakan Segera)

Jika kunci API tersebut merupakan kunci asli milik Anda atau organisasi Anda, lakukan langkah-langkah berikut segera:

### A. Revoke / Batalkan Kunci API
1. Masuk ke dashboard penyedia layanan (misalnya [Stripe Dashboard](https://dashboard.stripe.com/) jika itu adalah Stripe Key).
2. Temukan menu **API Keys / Developers**.
3. Cari kunci yang bersangkutan dan klik opsi **Revoke / Roll / Delete** untuk menonaktifkannya segera.

### B. Generate Kunci Baru
1. Buat kunci rahasia baru dari dashboard penyedia layanan.
2. Ganti kunci lama di server produksi Anda dengan kunci baru tersebut.

### C. Amankan Penyimpanan Kunci
* **Jangan pernah menyimpan API key rahasia langsung di dalam kode aplikasi (hardcoded)**, terutama pada aplikasi mobile (Flutter) atau frontend web yang dapat didekompilasi oleh pengguna.
* Gunakan **Environment Variables** (seperti file `.env` yang masuk dalam daftar `.gitignore`) atau simpan kunci tersebut di sisi **backend server** yang aman, sehingga aplikasi Flutter hanya berkomunikasi dengan backend Anda tanpa mengetahui kunci rahasianya secara langsung.
* Gunakan tools seperti **GitGuardian** atau **TruffleHog** untuk memindai repositori Git Anda secara otomatis guna mendeteksi kebocoran kredensial di masa mendatang.
