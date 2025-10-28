# BDIX FTP Tester v2.0 🚀

<div align="center">

![BDIX FTP Tester](https://img.shields.io/badge/BDIX-FTP%20Tester-6366f1?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-3.2.3-02569B?style=for-the-badge&logo=flutter)
![Material 3](https://img.shields.io/badge/Material-Design%203-757575?style=for-the-badge&logo=material-design)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**A modern, professional BDIX FTP server testing tool with stunning Material Design 3 UI**

[Features](#features) • [Installation](#installation) • [Usage](#usage) • [What's New](#whats-new-in-v20)

</div>

---

## ✨ What's New in v2.0

### 🎨 Modern UI/UX Redesign
- **Material Design 3** implementation with dynamic color schemes
- **Glassmorphism** effects and smooth animations
- **Professional landing page** with animated elements
- **Dark mode** support with beautiful gradients
- **Responsive cards** with expandable details
- **Interactive statistics** dashboard

### ⚡ Performance Improvements
- **Multithreaded testing** - Test 50 servers concurrently (up from 20)
- **Optimized network requests** using Dio with connection pooling
- **Async/Await patterns** for better performance
- **Smart chunking** for efficient batch processing
- **2.5x faster** server testing compared to v1.0

### 🔒 New Features
- **SOCKS5 Proxy Support** - Test servers through custom proxy
- **Proxy authentication** with username/password
- **Download speed calculation** for each server
- **Advanced sorting** - Sort by URL or speed
- **Copy URL to clipboard** functionality
- **Server status indicators** with real-time updates
- **Progress tracking** with percentage display
- **Success rate statistics**

### 🗑️ Improvements
- **Removed response time display** from main cards (cleaner UI)
- **Enhanced error handling** with user-friendly messages
- **Improved URL parsing** and display
- **Better state management** with Riverpod
- **Optimized animations** for smoother experience

---

## 🎯 Features

### Core Functionality
- ✅ **Live Server Testing** - Test hundreds of BDIX FTP servers in seconds
- ✅ **Real-time Updates** - Stream-based testing with live progress
- ✅ **Smart Detection** - Automatically detects online servers
- ✅ **Multi-platform** - Windows, macOS, Linux support

### UI/UX Features
- 🎨 **Material Design 3** - Modern, professional interface
- 🌓 **Dark/Light Themes** - Smooth theme switching
- 📊 **Statistics Dashboard** - Real-time testing stats
- 🎭 **Smooth Animations** - Delightful user experience
- 📱 **Responsive Design** - Works on all screen sizes

### Advanced Features
- 🔐 **SOCKS5 Proxy** - Route tests through custom proxy
- 🔑 **Proxy Authentication** - Username/password support
- 📈 **Download Speed** - Measure server response speed
- 🔍 **Smart Sorting** - Sort by URL, speed, or status
- 📋 **Quick Actions** - Copy URLs, open in browser
- 💾 **Persistent Settings** - Saves proxy configuration

---

## 🚀 Installation

### Prerequisites
- Flutter SDK 3.2.3 or higher
- Dart SDK 3.0 or higher
- Windows/macOS/Linux development environment

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/FakeErrorX/BDIX-FTP-TESTER.git
   cd BDIX-FTP-TESTER
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   # For Windows
   flutter run -d windows
   
   # For macOS
   flutter run -d macos
   
   # For Linux
   flutter run -d linux
   ```

4. **Build release version**
   ```bash
   # Windows
   flutter build windows --release
   
   # macOS
   flutter build macos --release
   
   # Linux
   flutter build linux --release
   ```

---

## 📖 Usage

### Basic Testing
1. **Launch the application**
2. **Click "Start Testing"** on the landing page
3. **Wait for results** - The app will test all servers automatically
4. **Browse working servers** - Click on any server card to see details

### Using Proxy
1. **Click the globe icon** in the app bar
2. **Enable proxy** using the toggle switch
3. **Enter proxy details**:
   - Host: Your SOCKS5 proxy IP or hostname
   - Port: Proxy port (default: 1080)
   - Username/Password: If authentication required
4. **Save settings** and start testing

### Server Actions
- **Expand card** - Click any server card to see full URL
- **Open in browser** - Click "Open" button
- **Copy URL** - Click "Copy" button to clipboard

### Sorting Results
- Click the **sort icon** in the app bar
- Choose **Sort by URL** or **Sort by Speed**
- Results update immediately

---

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── ftp_link.dart        # FTP server model
│   └── proxy_config.dart    # Proxy configuration model
├── providers/               # State management
│   ├── ftp_provider.dart   # FTP testing logic
│   ├── proxy_provider.dart # Proxy configuration
│   └── theme_provider.dart # Theme management
├── screens/                 # UI screens
│   └── home_screen.dart    # Main application screen
├── services/                # Business logic
│   ├── ftp_service.dart    # FTP testing service
│   └── window_service.dart # Window management
├── utils/                   # Utilities
│   ├── app_theme.dart      # Theme configuration
│   └── ftp_links.dart      # Server list
└── widgets/                 # Reusable widgets
    ├── proxy_dialog.dart   # Proxy settings dialog
    ├── server_card.dart    # Server card widget
    └── stats_card.dart     # Statistics card widget
```

### Key Technologies
- **Flutter** - Cross-platform UI framework
- **Riverpod** - State management
- **Dio** - HTTP client with proxy support
- **Material 3** - Modern design system
- **Flutter Animate** - Smooth animations
- **SharedPreferences** - Local storage
- **Font Awesome** - Professional icons

---

## 🔧 Configuration

### Adding Custom Servers
Edit `lib/utils/ftp_links.dart`:
```dart
static const List<String> links = [
  "http://your-server.com",
  "http://another-server.com:8080",
  // Add more servers...
];
```

### Customizing Theme
Edit `lib/utils/app_theme.dart`:
```dart
static const primary = Color(0xFF6366f1);    // Change primary color
static const secondary = Color(0xFF8b5cf6);  // Change secondary color
static const success = Color(0xFF10b981);    // Change success color
```

### Adjusting Performance
Edit `lib/services/ftp_service.dart`:
```dart
static const int _timeout = 5000;           // Request timeout (ms)
static const int _concurrentTests = 50;     // Concurrent tests
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👨‍💻 Author

**ErrorX**
- GitHub: [@FakeErrorX](https://github.com/FakeErrorX)

---

## 🙏 Acknowledgments

- Material Design 3 guidelines
- Flutter community for amazing packages
- BDIX community for server lists

---

## 📊 Performance Metrics

| Metric | v1.0 | v2.0 | Improvement |
|--------|------|------|-------------|
| Concurrent Tests | 20 | 50 | 2.5x faster |
| UI Framework | Material 2 | Material 3 | Modern design |
| Animations | Basic | Advanced | Smoother UX |
| Features | 5 | 12+ | 2.4x more |
| Code Quality | Good | Excellent | Better architecture |

---

## 🔮 Roadmap

- [ ] Add server response time charts
- [ ] Export results to CSV/JSON
- [ ] Server availability history
- [ ] Custom server groups
- [ ] Scheduled testing
- [ ] Desktop notifications
- [ ] Multi-language support
- [ ] Command-line interface

---

<div align="center">

**Made with ❤️ and Flutter**

⭐ Star this repo if you find it helpful!

</div>
