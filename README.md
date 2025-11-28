# Material You Dashboard App 🎨

Aplikasi Flutter dengan implementasi Material You (Material Design 3) yang menampilkan dashboard interaktif dengan fitur modifikasi warna preset.

## 📱 Fitur Utama

### 1. **Home Screen - Color Customization**
- ✨ Pilih warna seed untuk menghasilkan color scheme Material You
- 🎲 Random color generator
- 🎨 Color picker untuk memilih warna custom
- 💾 Simpan preset warna favorit
- 🌓 Toggle dark/light mode
- 🔄 Dynamic color dari sistem (Android 12+)
- ⚡ Auto-apply mode untuk langsung menerapkan warna

### 2. **Dashboard Screen**
- 🕐 **Jam Digital** - Update real-time setiap detik
- 📅 **Tanggal Lengkap** - Format: Hari, Tanggal Bulan Tahun
- 🔍 **Google Search Bar** - Cari langsung di Google
- 📱 **Quick Apps** - Akses cepat ke:
  - YouTube
  - Google Maps
  - Gmail
  - Google Drive
- 🎨 **Material You Colors** - Semua elemen mengikuti warna yang dipilih

## 🚀 Cara Menjalankan

### Prerequisites
- Flutter SDK (versi 3.9.2 atau lebih baru)
- Android Studio / VS Code
- Emulator atau perangkat fisik

### Langkah-langkah

1. **Clone atau buka project**
   ```bash
   cd "d:\Download\Kuliah\Semester 5\Mobile Application\flutter\materialyoud3"
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi**
   
   **Untuk Android:**
   ```bash
   flutter run
   ```
   
   **Untuk Windows:**
   ```bash
   flutter run -d windows
   ```
   
   **Untuk Web:**
   ```bash
   flutter run -d chrome
   ```

4. **Build APK (opsional)**
   ```bash
   flutter build apk --release
   ```

## 📂 Struktur Project

```
lib/
├── main.dart                      # Entry point & state management
├── home_screen.dart               # Halaman utama untuk customisasi warna
├── dashboard_screen.dart          # Dashboard dengan jam, tanggal, dan apps
├── preview_screen.dart            # Preview komponen Material You
└── preview_components_screen.dart # Detail komponen UI

assets/
└── icons/
    ├── youtube.svg
    ├── googlemaps.svg
    ├── gmail.svg
    └── googledrive.svg
```

## 🎨 Cara Menggunakan

### Mengubah Warna Theme

1. **Dari Home Screen:**
   - Tap pada salah satu color swatch untuk set sebagai seed color
   - Klik ikon 🎲 untuk random color
   - Klik ikon 🎨 untuk membuka color picker
   - Gunakan "Use as Primary" di SnackBar untuk apply warna

2. **Menyimpan Preset:**
   - Klik ikon 💾 untuk menyimpan warna saat ini
   - Preset akan muncul di baris horizontal
   - Tap preset untuk apply
   - Long-press untuk menghapus

3. **Toggle Mode:**
   - Gunakan switch untuk dark/light mode
   - Enable "Auto-apply" untuk langsung menerapkan warna saat tap swatch

### Mengakses Dashboard

1. Klik ikon **Dashboard** (📊) di AppBar home screen
2. Dashboard akan menampilkan:
   - Jam dan tanggal real-time
   - Search bar untuk Google
   - Grid aplikasi (YouTube, Maps, Gmail, Drive)
3. Tap ikon aplikasi untuk membuka pencarian Google
4. Semua warna mengikuti theme yang dipilih di home screen

## 🛠️ Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  dynamic_color: ^1.8.1          # Material You dynamic colors
  shared_preferences: ^2.0.15    # Persistent storage
  flutter_colorpicker: ^1.1.0    # Color picker dialog
  intl: ^0.18.0                  # Date/time formatting
  url_launcher: ^6.1.10          # Open URLs
  flutter_svg: ^1.1.6            # SVG icon support
```

## 📸 Screenshots

### Home Screen
- Color swatches dengan hex values
- Preset colors
- Dark/Light mode toggle
- Random & custom color picker

### Dashboard
- Large clock display
- Full date format
- Google search integration
- App icons dengan Material You colors

## 💡 Tips

1. **Untuk Dynamic Colors (Android 12+):**
   - Toggle "Use System Dynamic" untuk menggunakan warna wallpaper
   
2. **Hemat Baterai:**
   - Edit `dashboard_screen.dart` line 23
   - Ubah `Duration(seconds: 1)` menjadi `Duration(minutes: 1)`

3. **Custom Apps:**
   - Edit array `apps` di `dashboard_screen.dart` (line 58-63)
   - Tambah SVG icons di `assets/icons/`
   - Update `pubspec.yaml` jika perlu

## 🔧 Troubleshooting

**SVG icons tidak muncul:**
- Pastikan file SVG ada di `assets/icons/`
- Cek `pubspec.yaml` sudah include `assets/icons/`
- Jalankan `flutter pub get` lagi

**Warna tidak tersimpan:**
- Cek permission storage (Android)
- Pastikan `shared_preferences` terinstall

**Build error:**
- Jalankan `flutter clean`
- Kemudian `flutter pub get`
- Build ulang

## 📝 Catatan

- Aplikasi ini dibuat untuk demonstrasi Material You / Material Design 3
- Ikon aplikasi akan membuka Google search (bukan aplikasi asli)
- Semua preferensi warna disimpan secara lokal
- Compatible dengan Android, iOS, Windows, Web, macOS, Linux

## 👨‍💻 Development

Dibuat dengan ❤️ menggunakan Flutter & Material Design 3

---

**Selamat mencoba! 🚀**
