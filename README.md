# 🎮 PlayHub - Native iOS Arcade & Mini-Games Hub

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg?style=flat&logo=swift)
![iOS](https://img.shields.io/badge/iOS-16.0%2B-blue.svg?style=flat&logo=apple)
![Framework](https://img.shields.io/badge/UI-SwiftUI-purple.svg?style=flat&logo=swift)
![Architecture](https://img.shields.io/badge/Architecture-MVVM-green.svg?style=flat)
![License](https://img.shields.io/badge/License-MIT-brightgreen.svg)

**PlayHub** is a feature-rich, high-performance native iOS arcade application built with **SwiftUI**. It offers dynamic arcade mini-games, multi-player profile management, interactive location-based game session mapping, performance analytics with Swift Charts, automated daily challenges, and custom themes (Light & Dark modes).

---

## 🌟 Key Features

### 🕹️ Arcade Game Modes
* **🎯 Tap Frenzy**: Fast-paced reflex reaction game featuring shrinking target buttons, dynamic target teleportation, bonus popups (`+3`), high-score multipliers, and countdown pressure.
* **⚡ Light It Up**: Simon Says memory sequence game featuring randomized tile patterns, glowing neon visual feedback, step-by-step sequence validation, and progressive difficulty scaling.
* **💡 Quiz Rush**: Trivia showdown game with dynamic timer pressure, multiple categories, immediate score feedback, and profile score recording.

### 🏆 Daily Challenges & Streaks
* **Automated Daily Challenges**: Different game modes assigned every day to keep gameplay fresh.
* **Streak Tracking System**: Dynamic streak counters (`StreakBannerView`) with custom flame badges that reward consecutive daily play.
* **Local Notifications**: Scheduled daily reminders built with `UserNotifications` to remind players at their preferred challenge time.

### 📊 Performance Stats & Multi-Player Leaderboards
* **Multi-Player Analytics**: Score aggregation across all registered player profiles on the device.
* **Personal Bests**: Quick-access cards tracking high scores for each game mode.
* **Visual Progress Charts**: Interactive bar charts built using **Swift Charts** to visualize game history and score trends over time.
* **Filterable History**: Filter game session logs by specific game modes or player profiles.

### 🗺️ Interactive Game Session Map
* **Location-Based Session Pins**: Built with **MapKit**, displaying pin annotations for game sessions across all local profiles.
* **Personal Best Badges**: High-score sessions highlighted with gold crown indicators (`PB 👑`).
* **Interactive Session Detail Cards**: Tap any pin to view player avatar, name, game mode, date/time, and score.

### 🎨 Theme Support & Custom UI
* **Dynamic Theme Engine**: Smooth switching between **Dark Mode**, **Light Mode**, and **System Default**.
* **Adaptive Glassmorphism**: High-contrast, adaptive UI components, custom card borders, and smooth glowing radial gradients for both light and dark aesthetics.
* **Custom Tab Bar & Navigation**: Floating custom tab bar with seamless view transition animations.
* **Animated Splash Screen**: Custom glowing halo ring loader introducing PlayHub on launch.

### 👤 Profile & Account Management
* **Multi-User Account System**: Secure local authentication, account creation, and login.
* **Profile Customization**: Customizable player display names and 16+ vibrant emoji avatars.
* **User Data Isolation**: Independent session histories and score storage for every account on the device.

### 🔊 Audio & Haptic Feedback
* **Sound Effects**: Audio chimes and tap clicks via `AVFoundation`.
* **Haptics**: Tactile vibration feedback via `UIImpactFeedbackGenerator` during gameplay interactions.
* **Toggle Controls**: Enable or disable audio and haptics anytime from Settings.

---

## 🛠️ Tech Stack & Frameworks

| Layer / Feature | Technology |
| :--- | :--- |
| **Language** | Swift 5.9 |
| **User Interface** | SwiftUI |
| **Architecture** | MVVM (Model-View-ViewModel) |
| **Charts & Analytics** | Swift Charts |
| **Mapping & Location** | MapKit, CoreLocation |
| **Notifications** | UserNotifications Framework |
| **Audio & Haptics** | AVFoundation, UIKit (UIImpactFeedbackGenerator) |
| **Persistence** | `UserDefaults` + JSON Serialization |

---

## 📂 Project Architecture

```text
IOS-Dev/
├── Models/              # Data models (GameSession, User, PlayerGameSession)
├── ViewModels/          # Business logic & state management (TapFrenzyViewModel, LightItUpViewModel, etc.)
├── Views/               # SwiftUI Screen Views
├── Services/            # Core managers (AuthManager, GameSessionManager, SoundManager, HapticManager, LocationManager)
├── Assets.xcassets/     # High-res 1024x1024 3D App Icon & color assets
└── IOS_DevApp.swift     # App entry point
