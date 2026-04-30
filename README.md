# ChessPro ♟️

A premium, modern chess application built with Flutter, featuring a fully local Stockfish 18 engine integration. ChessPro provides an elegant user interface, smooth animations, and adaptive AI coaching.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Stockfish](https://img.shields.io/badge/Stockfish_18-333333?style=for-the-badge&logo=c%2B%2B&logoColor=white)

## ✨ Features
- **Local Stockfish 18 Engine**: 100% offline, deeply integrated via custom Dart process management.
- **Adaptive Difficulty**: AI dynamically adjusts its Skill Level based on your performance.
- **Premium UI**: Vector-based (SVG) chess pieces, sleek dark/gold theme, and legal move indicators.
- **Game Analysis**: Built-in move evaluation (!!, !, ?, ??) to help you improve.
- **Control Panel**: Undo your moves instantly or restart the match with a single tap.
- **Cross-Platform**: Designed for Windows desktop, ready to be expanded to mobile.

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable)
- Windows Developer Mode enabled (for native compilation)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/chess_pro.git
   cd chess_pro
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run -d windows
   ```

## 🛠️ Tech Stack & Architecture
- **Framework:** Flutter (Dart)
- **State Management:** BLoC Pattern (`flutter_bloc`)
- **Chess Logic:** `dartchess` for move validation and FEN generation
- **Engine Interaction:** Custom `StockfishProcess` communicating via standard I/O (UCI Protocol).

## 🤝 Contributing
Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](../../issues).

## 📝 License
This project is open source and available under the [MIT License](LICENSE).

---
*Built with passion and AI-assisted pair programming.*
