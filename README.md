# Proyek Aplikasi To-Do Full-Stack: Plan Paw

Selamat datang di Plan Paw, aplikasi to-do list (atau daftar rencana) lintas platform yang dibangun dengan Flutter di sisi frontend dan Go (Golang) dengan GraphQL di sisi backend. Proyek ini mendemonstrasikan arsitektur aplikasi full-stack modern, lengkap dengan autentikasi, manajemen data real-time, dan fitur pengingat.

## Daftar Isi

- [Fitur Utama](#fitur-utama)
- [Teknologi yang Digunakan](#teknologi-yang-digunakan)
- [Prasyarat](#prasyarat)
- [Panduan Instalasi & Konfigurasi](#panduan-instalasi--konfigurasi)
  - [Backend (Go & GraphQL)](#backend-go--graphql)
  - [Frontend (Flutter)](#frontend-flutter)
- [Ringkasan API GraphQL](#ringkasan-api-graphql)

## Fitur Utama

* **Autentikasi Pengguna**: Sistem registrasi dan login aman menggunakan JWT (JSON Web Tokens).
* **Manajemen Rencana (CRUD)**: Pengguna dapat membuat, membaca, memperbarui, dan menghapus catatan atau rencana mereka.
* **Kategorisasi**: Kelompokkan setiap rencana ke dalam kategori yang telah ditentukan (Contoh: Pekerjaan, Pribadi, Studi, dll.).
* **Fitur Favorit**: Tandai rencana yang paling penting sebagai favorit untuk akses cepat.
* **Checklist dalam Rencana**: Setiap rencana dapat berisi beberapa item checklist yang dapat ditandai sebagai selesai.
* **Pengingat & Notifikasi**: Atur waktu pengingat untuk setiap rencana dan dapatkan notifikasi pop-up di dalam aplikasi.
* **Pencarian & Penyaringan**: Cari rencana berdasarkan judul atau konten, dan saring berdasarkan kategori atau status favorit.
* **Forum Diskusi Real-time**: Sebuah layar diskusi di mana pengguna dapat mengirim dan menerima pesan secara langsung menggunakan WebSockets.
* **Profil Pengguna**: Lihat informasi profil dan lakukan logout dengan aman.

---

## Teknologi yang Digunakan

**Frontend:**
<p>
  [![Flutter 3.8.1](https://img.shields.io/badge/Flutter-3.8.1-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/docs/releases/stable/3.8.1)
  [![GraphQL Flutter 5.0.0](https://img.shields.io/badge/GraphQL_Flutter-5.0.0-E0524B?style=for-the-badge&logo=graphql&logoColor=white)](https://pub.dev/packages/graphql_flutter)
  [![WebSocket Channel 2.4.0](https://img.shields.io/badge/WebSocket_Channel-2.4.0-5B3E93?style=for-the-badge&logo=websocket&logoColor=white)](https://pub.dev/packages/web_socket_channel)
  [![Shared Preferences 2.0.0](https://img.shields.io/badge/Shared_Preferences-2.0.0-02569B?style=for-the-badge&logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CHGl2ZSBpZD0iTGlzdCIgc3R5bGU9ImZpbGw6IzAwMDAwMDsiIHZpZXdCb3g9IjAgMCA1MCA1MCI%2BPHBhdGggZD0yNC44MmMwLDEzLjc1LDE1Ljg5LDE4LjI0LDE4LjI5LDE4LjI0YzEuMzQsMCwxLjg2LTEuNTUsMS41NS0yLjg5Yy0wLjQxLTEuNTUtMS4wMy00LjE2LTEuMzQtNS4xOWMtMC4yMS0wLjYyLTAuNTItMS4yNC0wLjUxLTEuODZjMC4xLTAuNzIsMC42Mi0xLjQ0LDEuMjQtMS45NmMxLjM0LTAuOSwyLjY2LTEuNzUsMy44OS0yLjQ3YzIuMDUtMS4xMyw0LjEyLTEuNjYsNi4wNy0xLjYzYzIuMDgsMC4wNSwzLjYyLDAuNjQsNS4xNywxLjM3YzEuNTUsMC43MiwyLjU4LDEuNzUsMy43MywzLjA4YzEuMjQsMS4yNCwxLjk2LDIuNTcsMi4yOCwzLjcyYzAuNDEsMi40Ny0xLjE0LDMuMDktMi4yOCwzLjA5Yy01LjUzLDAtMTAuNjgsMC0xNS43MiwwYy0yLjA3LDAtMy40MSwxLjU0LTMuMjgsMy41MmMwLjEzLDEuOTIsMS42NSwzLjI5LDMuMDgsNC4yMWMyLjQ2LDEuNTQsNS4zOSwzLjQxLDguMzIsNC43NWMzLjE3LDEuNDUsNi41OCwzLjM0LDkuOTYsMy43M2MzLjYxLDAuNDEsNy4xNS0xLjI0LDEwLjA0LTQuNDVjNC43NS01LjUzLDYuNTYtMTIuMjgsNi4xNS0xOC40MUM0Ny44NiwyNy4wOCw1MCwyNi40Niw1MCwyNC44MlpNMTcuMDgsMjguMjRjLTAuNDEtMC41Mi0xLjA0LTAuODItMS45Ni0wLjc3Yy0wLjkyLDAuMDUtMS41NSwwLjU3LTEuOTYsMS4wNGMt0uNDEsMC41MS0wLjYyLDAuOTItMC40MSwxLjQ1bDAuMjEsMC42MmIwLjExLDAuMTEsMC4yMiwwLjIxLDAuMzIsMC40MWMwLjYzLDAuOTQsMS40NSwxLjgyLDIuNTcsMi4yM3MxLjg3LDAuNjIsMi40OC0xLjA0LDIuNjktMi4wNmYtMC4wNS0wLjQxLTAuMjEtMC44MS0wLjQyLTEuMzRaIiBmaWxsPSIjMDAwMDAwIj48L3BhdGg%2BPjwvaXZlPg%3D%3D&color=blue)](https://pub.dev/packages/shared_preferences)
</p>

**Backend:**
<p>
  [![Go (Golang)](https://img.shields.io/badge/Go-Golang-00ADD8?style=for-the-badge&logo=go&logoColor=white)](https://go.dev/)
  [![gqlgen framework](https://img.shields.io/badge/gqlgen-framework-E0524B?style=for-the-badge&logo=graphql&logoColor=white)](https://gqlgen.com/)
  [![GORM ORM](https://img.shields.io/badge/GORM-ORM-8892BF?style=for-the-badge&logo=gopher&logoColor=white)](https://gorm.io/)
  [![Gorilla WebSocket library](https://img.shields.io/badge/Gorilla_WebSocket-library-007ACC?style=for-the-badge&logo=websocket&logoColor=white)](https://github.com/gorilla/websocket)
  [![PostgreSQL Database](https://img.shields.io/badge/PostgreSQL-Database-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
</p>

---

## Prasyarat

Sebelum memulai, pastikan Anda telah menginstal perangkat lunak berikut:

* **Flutter SDK** (versi 3.8.1 atau yang kompatibel)
* **Go (Golang)**
* **PostgreSQL**
* Sebuah IDE atau editor teks seperti Visual Studio Code, Android Studio, atau GoLand.

---

## Panduan Instalasi & Konfigurasi

### Backend (Go & GraphQL)

1.  **Buka Direktori Backend:**
    ```bash
    cd graphql_api
    ```

2.  **Konfigurasi Database:**
    * Pastikan layanan PostgreSQL Anda berjalan.
    * Buat sebuah database baru dengan nama `todolist_graphql_go`.
    * Konfigurasi koneksi database terdapat di `graphql_api/config/db.go`. Sesuaikan string koneksi jika diperlukan.
        ```go
        dsn := "host=localhost user=postgres password=12345 dbname=todolist_graphql_go port=5432"
        ```

3.  **Konfigurasi Lingkungan:**
    * Proyek memerlukan secret key untuk JWT. Buat file `.env` di dalam direktori `graphql_api/`.
    * Isi file `.env` dengan variabel berikut:
        ```
        JWT_SECRET="kunci_rahasia_anda_yang_sangat_aman" # Ganti dengan string acak yang kuat
        ```
        **Penting**: `JWT_SECRET` harus sangat rahasia dan aman. Jangan pernah membagikannya secara publik.

4.  **Instal Dependensi:**
    * Jalankan perintah berikut untuk mengunduh semua modul Go yang dibutuhkan.
    ```bash
    go mod tidy
    ```

5.  **Jalankan Server:**
    ```bash
    go run server.go
    ```
    Server akan berjalan di `http://localhost:8080`. Anda dapat mengakses GraphQL Playground di `http://localhost:8080/` untuk menguji API.

### Frontend (Flutter)

1.  **Buka Direktori Frontend:**
    ```bash
    cd flutter_app
    ```

2.  **Konfigurasi Endpoint API:**
    * Aplikasi Flutter terhubung ke server Go. Endpoint default sudah diatur ke `localhost`.
    * File konfigurasi utama berada di `flutter_app/lib/graphql/client.dart`.
    * **Penting:** Jika Anda menjalankan aplikasi pada Android Emulator, ganti `localhost` dengan `10.0.2.2`.
        * GraphQL Endpoint: `http://10.0.2.2:8080/query`
        * WebSocket Endpoint (di `lib/features/diskusi/screens/diskusi_screen.dart`): `ws://10.0.2.2:8080/ws`

3.  **Instal Dependensi:**
    ```bash
    flutter pub get
    ```

4.  **Jalankan Aplikasi:**
    * Pastikan Anda memiliki perangkat (emulator atau fisik) yang berjalan, lalu jalankan:
    ```bash
    # Untuk menjalankan di web (Chrome)
    flutter run -d chrome

    # Untuk menjalankan di Android (Emulator/Perangkat Fisik)
    flutter run

    # Untuk menjalankan di Desktop (Windows/macOS/Linux)
    flutter run -d <windows|macos|linux>
    ```

---

## Ringkasan API GraphQL

Berikut adalah beberapa kueri dan mutasi utama yang tersedia. Untuk daftar lengkap, silakan merujuk ke `graphql_api/graph/schema.graphqls` atau `flutter_app/lib/graphql/query_mutation.dart`.

**Kueri (Queries):**
* `me`: Mendapatkan detail pengguna yang sedang login.
* `users`: Mendapatkan daftar semua pengguna.
* `notes`: Mendapatkan semua rencana milik pengguna yang sedang login.
* `notesByCategory(idCategory: ID!)`: Mendapatkan rencana berdasarkan ID kategori.
* `favoriteNotes`: Mendapatkan semua rencana yang telah ditandai sebagai favorit.
* `categories`: Mendapatkan daftar semua kategori yang tersedia.

**Mutasi (Mutations):**
* `register(name: ..., email: ..., password: ...)`: Mendaftarkan pengguna baru dan mengembalikan token.
* `login(email: ..., password: ...)`: Login pengguna dan mengembalikan token.
* `createNote(title: ..., content: ..., idCategory: ..., reminderTime: ...)`: Membuat rencana baru.
* `updateNote(id: ..., title: ..., content: ..., isFavorite: ..., ...)`: Memperbarui rencana yang ada.
* `deleteNote(id: Int!)`: Menghapus sebuah rencana.