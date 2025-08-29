# REI

Aplikasi edukasi untuk anak-anak yang dibangun dengan Flutter dan Supabase. (Display name: REI)

## 🎯 Fitur Utama

- **Tema Ceria & Ramah Anak**: Desain colorful dengan warna-warna cerah yang menarik untuk anak-anak
- **Multiple Games**: Berbagai kategori game edukatif (Matematika, Bahasa, Puzzle, Kreativitas)
- **User Management**: Sistem login/register dengan Supabase Auth
- **Progress Tracking**: Melacak level dan score pemain
- **Leaderboard**: Sistem ranking untuk memotivasi anak-anak
- **Responsive Design**: Mendukung berbagai ukuran layar

## 📁 Struktur Folder

```
lib/
│
├── core/                   # Core utilities dan konstanta
│   ├── constants/         # Konstanta aplikasi
│   │   ├── colors.dart    # Pallet warna ceria dan konsisten
│   │   ├── dimensions.dart # Ukuran dan spacing (S, M, L, XL, XXL)
│   │   ├── radius.dart    # Border radius (S, M, L, XL, XXL)
│   │   └── fonts.dart     # Font families dan text styles
│   └── theme/
│       └── app_theme.dart # Tema utama aplikasi
│
├── data/                  # Data layer
│   ├── models/           # Model data
│   │   ├── base_model.dart
│   │   ├── user_model.dart
│   │   └── game_model.dart
│   ├── services/         # External services
│   │   └── supabase_service.dart # Service untuk Supabase
│   └── repositories/     # Data repositories
│       ├── user_repository.dart
│       └── game_repository.dart
│
├── view/                 # UI layer
│   ├── screens/         # Halaman-halaman aplikasi
│   │   └── home_screen.dart
│   └── widgets/         # Reusable widgets
│       ├── game_card.dart
│       └── custom_button.dart
│
├── view_model/          # Business logic layer
│   ├── user_view_model.dart
│   └── game_view_model.dart
│
├── routes/              # Navigation
│   └── app_routes.dart
│
└── main.dart           # Entry point aplikasi
```

## 🎨 Design System

### Warna (colors.dart)
- **Primary**: Soft Purple (#6B73FF) - Warna utama yang lembut
- **Secondary**: Pink Ceria (#FF6B9D) - Warna pendukung yang hangat
- **Accent Colors**: Yellow, Green, Orange, Turquoise, Red - Untuk variasi
- **Background**: Light backgrounds untuk kenyamanan mata
- **Text**: Kontras yang baik untuk readability

### Dimensi (dimensions.dart)
- **Padding/Margin**: XS(4), S(8), M(16), L(24), XL(32), XXL(48)
- **Button Heights**: S(36), M(44), L(52), XL(60)
- **Icon Sizes**: XS(16), S(20), M(24), L(32), XL(40), XXL(48)
- **Game Card**: 160x180px untuk konsistensi

### Radius (radius.dart)
- **Basic**: XS(4), S(8), M(12), L(16), XL(20), XXL(24)
- **Special**: Button(12), Card(16), Dialog(20), Game Card(20)
- **Round**: 50 untuk elemen circular

### Typography (fonts.dart)
- **Primary Font**: Poppins (ramah anak)
- **Game Font**: Comic Neue (untuk elemen game)
- **Sizes**: XS(10) hingga H1(32) dengan line heights optimal

## 🚀 Setup & Installation

### Prerequisites
- Flutter SDK (3.7.0+)
- Dart SDK
- Android Studio / VS Code
- Supabase Account

### Installation

1. **Clone repository**
   ```bash
   git clone <repository-url>
   cd child_games
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Supabase**
   - Buat project di [Supabase](https://supabase.com)
   - Copy URL dan anon key
   - Update `main.dart` dengan kredensial Supabase Anda

4. **Run aplikasi**
   ```bash
   flutter run
   ```

## 🗄️ Database Schema (Supabase)

### Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  display_name TEXT,
  avatar_url TEXT,
  level INTEGER DEFAULT 1,
  total_score INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Games Table
```sql
CREATE TABLE games (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  category TEXT NOT NULL,
  min_age INTEGER,
  max_age INTEGER,
  difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Game Sessions Table
```sql
CREATE TABLE game_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  game_id UUID REFERENCES games(id),
  score INTEGER,
  completed_at TIMESTAMP DEFAULT NOW()
);
```

## 🔧 Development Guidelines

### Adding New Screens
1. Buat file di `lib/view/screens/`
2. Tambahkan route di `app_routes.dart`
3. Implementasikan dengan konsisten menggunakan design system

### Adding New Widgets
1. Buat file di `lib/view/widgets/`
2. Gunakan konstanta dari `core/constants/`
3. Pastikan responsive dan accessible

### State Management
Project ini sudah disiapkan untuk state management dengan:
- ViewModel pattern di folder `view_model/`
- Repository pattern di folder `data/repositories/`
- Service layer di folder `data/services/`

### Styling Guidelines
- Selalu gunakan konstanta dari `core/constants/`
- Konsisten dengan design system
- Prioritaskan accessibility
- Test di berbagai ukuran layar

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🤝 Contributing

1. Fork repository
2. Buat feature branch
3. Commit changes
4. Push ke branch
5. Buat Pull Request

## 📄 License

This project is licensed under the MIT License.

## 🎮 Game Categories

- **Matematika**: Belajar angka, penjumlahan, pengurangan
- **Bahasa**: Mengenal huruf, kata, membaca
- **Puzzle**: Bentuk, warna, pola
- **Kreativitas**: Menggambar, mewarnai, musik

## 📞 Support

Jika ada pertanyaan atau masalah, silakan buat issue di repository ini.
