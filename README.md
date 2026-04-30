# ♟️ ChessPro

Stockfish satranç motoru ile güçlendirilmiş, Flutter tabanlı masaüstü satranç uygulaması. Adaptif yapay zeka, ELO puan sistemi, hamle analizi ve premium kullanıcı arayüzü sunar.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Stockfish](https://img.shields.io/badge/Stockfish-333333?style=for-the-badge&logo=c%2B%2B&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Windows-blue?style=for-the-badge&logo=windows&logoColor=white)

---

## 📋 İçindekiler

- [Özellikler](#-özellikler)
- [Ekran Görüntüleri](#-ekran-görüntüleri)
- [Kurulum](#-kurulum)
- [Stockfish Entegrasyonu](#-stockfish-entegrasyonu)
- [Proje Yapısı](#-proje-yapısı)
- [Teknolojiler](#%EF%B8%8F-teknolojiler)
- [Lisans](#-lisans)

---

## ✨ Özellikler

| Özellik | Açıklama |
|---------|----------|
| 🤖 **Adaptif Yapay Zeka** | Stockfish motoru, oyuncunun ELO puanına göre seviye ve derinlik ayarlar. Düşük seviyelerde insansı hatalar yapar, yüksek seviyelerde acımasız oynar. |
| 📊 **ELO Puan Sistemi** | Her maç sonunda gerçek satranç uygulamalarındaki gibi ELO puanı hesaplanır. Kazanç, kayıp ve beraberlik durumlarına göre puan güncellenir. |
| 🎯 **İpucu Sistemi** | Oyun sırasında en güçlü Stockfish seviyesiyle analiz yaparak en iyi hamleyi tahta üzerinde gösterir. |
| ↩️ **Geri Alma** | Yaptığınız hamleyi (ve yapay zekanın cevabını) tek tuşla geri alabilirsiniz. |
| ♟️ **Terfi Seçimi** | Piyon son sıraya ulaştığında Vezir, Kale, Fil veya At seçimi yapabilirsiniz. Taşlar oynadığınız renge göre doğru gösterilir. |
| ⚫⚪ **Taraf Seçimi** | Beyaz veya Siyah tarafı seçerek oynayabilirsiniz. Siyah seçildiğinde tahta otomatik döner. |
| 📜 **Maç Geçmişi** | Oynanan tüm maçlar kaydedilir. Sonuç, hamle sayısı ve ELO değişimi listelenir. |
| 🔄 **Maç Tekrarı** | Geçmiş maçları hamle hamle tekrar izleyebilirsiniz. |
| 💾 **Devam Et** | Yarım kalan maça kaldığınız yerden devam edebilirsiniz. FEN pozisyonu, hamle geçmişi ve taraf bilgisi korunur. |
| 🔊 **Ses Efektleri** | Hamle, taş alma ve şah durumları için ayrı ses efektleri. |
| 🎨 **Premium Arayüz** | Koyu tema, altın vurgular, SVG tabanlı taşlar, yasal hamle göstergeleri ve animasyonlu geçişler. |
| ⚙️ **Ayarlar** | Yapay zeka zorluğunu manuel veya otomatik (adaptif) olarak ayarlayabilirsiniz. |

---

## 📸 Ekran Görüntüleri

> Ekran görüntüleri yakında eklenecektir.

---

## 🚀 Kurulum

### Gereksinimler

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.11 veya üstü)
- [Git](https://git-scm.com/downloads)
- Windows 10/11 (Geliştirici Modu etkinleştirilmiş olmalı)
- Visual Studio 2022 (C++ masaüstü geliştirme iş yükü)

### Adım Adım Kurulum

```bash
# 1. Repoyu klonlayın
git clone https://github.com/Burakss06/chess_pro.git
cd chess_pro

# 2. Flutter bağımlılıklarını yükleyin
flutter pub get

# 3. Stockfish motorunu indirin (aşağıdaki bölüme bakın)

# 4. Uygulamayı çalıştırın
flutter run -d windows
```

---

## 🐟 Stockfish Entegrasyonu

ChessPro, yapay zeka rakip olarak **Stockfish** satranç motorunu kullanır. GitHub'ın dosya boyutu sınırı nedeniyle `stockfish.exe` dosyası repoya dahil edilmemiştir. Uygulamayı çalıştırmadan önce aşağıdaki adımları takip edin:

### Stockfish İndirme ve Yerleştirme

1. [Stockfish Resmi Sitesi](https://stockfishchess.org/download/) adresine gidin.
2. **Windows** için en son sürümü indirin (`.zip` dosyası).
3. İndirdiğiniz `.zip` dosyasını açın.
4. İçindeki `stockfish-windows-x86-64-avx2.exe` (veya benzeri isimli) dosyayı **`stockfish.exe`** olarak yeniden adlandırın.
5. Bu dosyayı projenin **`assets/engine/`** klasörüne kopyalayın.

Son hali şöyle olmalı:
```
chess_pro/
├── assets/
│   ├── engine/
│   │   └── stockfish.exe    ← Buraya koyun
│   ├── pieces/
│   └── sounds/
├── lib/
└── ...
```

> **Not:** Stockfish, [GPLv3 lisansı](https://www.gnu.org/licenses/gpl-3.0.html) altında dağıtılan açık kaynaklı bir satranç motorudur.

### Motor Nasıl Çalışıyor?

Uygulama, Stockfish motoruyla **UCI (Universal Chess Interface)** protokolü üzerinden iletişim kurar:

1. `StockfishProcess` sınıfı, motoru `Process.start()` ile başlatır.
2. Komutlar `stdin` üzerinden gönderilir (ör. `position fen ...`, `go depth ...`).
3. Yanıtlar `stdout` üzerinden okunur ve `StreamController` ile BLoC katmanına iletilir.
4. Motor, oyuncunun ELO puanına göre `setoption name Skill Level value X` komutuyla ayarlanır.

---

## 📁 Proje Yapısı

```
lib/
├── main.dart                          # Uygulama giriş noktası
├── bloc/
│   └── chess_bloc.dart                # Oyun durumu yönetimi (BLoC Pattern)
├── logic/
│   ├── stockfish_process.dart         # Stockfish motor iletişimi (UCI)
│   ├── settings_repository.dart       # Ayarlar ve veri kalıcılığı
│   ├── audio_manager.dart             # Ses efektleri yönetimi
│   └── performance_manager.dart       # ELO hesaplama ve performans takibi
└── ui/
    ├── theme.dart                     # Renk paleti ve tema tanımları
    ├── screens/
    │   ├── menu_screen.dart           # Ana menü ekranı
    │   ├── game_screen.dart           # Oyun ekranı (tahta + kontroller)
    │   ├── settings_screen.dart       # Ayarlar ekranı
    │   ├── history_screen.dart        # Maç geçmişi ekranı
    │   └── replay_screen.dart         # Maç tekrarı ekranı
    └── widgets/
        ├── evaluation_bar.dart        # Pozisyon değerlendirme çubuğu
        └── move_notation_panel.dart   # Hamle notasyonu paneli
```

---

## 🛠️ Teknolojiler

| Kategori | Teknoloji |
|----------|-----------|
| **Framework** | Flutter (Dart) |
| **Durum Yönetimi** | BLoC Pattern (`flutter_bloc`) |
| **Satranç Mantığı** | `dartchess` — Hamle doğrulama, FEN üretimi, mat/pat tespiti |
| **Motor** | Stockfish — UCI protokolü ile `dart:io` Process üzerinden |
| **Ses** | `audioplayers` — Hamle, taş alma ve şah sesleri |
| **SVG Render** | `flutter_svg` — Vektörel satranç taşları |
| **Veri Kalıcılığı** | `shared_preferences` — ELO, ayarlar ve devam verisi |
| **Tipografi** | `google_fonts` — Modern font ailesi |

---

## 📝 Lisans

Bu proje [MIT Lisansı](LICENSE) altında açık kaynak olarak sunulmaktadır.

Stockfish motoru [GPLv3 Lisansı](https://www.gnu.org/licenses/gpl-3.0.html) altında dağıtılmaktadır. Stockfish'in kaynak koduna [github.com/official-stockfish/Stockfish](https://github.com/official-stockfish/Stockfish) adresinden ulaşabilirsiniz.

---

<div align="center">

**Geliştirici:** [Burakss06](https://github.com/Burakss06)

*Tutku ve yapay zeka destekli pair programming ile geliştirilmiştir.* ♟️

</div>
