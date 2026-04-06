<p align="center">
  <img src="assets/image/logo.png" width="150" alt="PennyWise Logo">
</p>

# 🪙 PennyWise

**Elevate Your Financial Intelligence.**

PennyWise is a premium personal finance management application built with Flutter. It combines real-time banking integration via Plaid with advanced spending analytics and automated goal tracking, providing a sleek and intuitive experience for taking control of your financial life.

---

## ✨ Key Features

### 🏦 Banking Integration (Plaid)
- **Live Data Fetching**: Securely connect to financial institutions via **Plaid** to fetch balances and transactions.
- **Automated Categorization**: Transactions are automatically sorted into primary categories for simplified tracking.
- **Centralized Wallet View**: View all your linked account balances and historical data in one unified dashboard.

### 📊 Financial Insights
- **Spending Analytics**: Interactive visualized spending breakdowns using the **FL Chart** library.
- **Trend Tracking**: Automated week-over-week spending comparisons and trend indicators.
- **Top Spend Detection**: Identify your highest spending category and most frequent merchants at a glance.
- **Compact UI**: Elegantly formatted financial figures optimized for readability.

### 🔥 Goals & Gamification
- **No-Spend Challenge**: Build and track a "hot streak" by avoiding expense logging, visualized with dynamic animations.
- **Budget Management**: Set and monitor monthly budget goals for specific categories with real-time progress bars.

### 🎨 Premium Experience
- **Modern Aesthetics**: A curated dark/light theme system with smooth micro-animations powered by **Animate Do**.
- **Secure Onboarding**: Quick and reliable authentication using **Supabase** and **Google Sign-In**.

---

## 🛠️ Tech Stack

| Category | Technology |
| :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) (Dart) |
| **State Management** | [Riverpod](https://riverpod.dev) |
| **Backend / Auth** | [Supabase](https://supabase.com) |
| **Financial API** | [Plaid](https://plaid.com) |
| **Charts** | [FL Chart](https://pub.dev/packages/fl_chart) |
| **Animations** | [Animate Do](https://pub.dev/packages/animate_do) |
| **Local Storage** | [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage) |

---

## 🏗️ Architecture

PennyWise follows a **Feature-First Clean Architecture** approach, ensuring the codebase is scalable, testable, and maintainable.

- **`core/`**: Shared utilities, theme definitions, and global providers.
- **`data/`**: Implementation of repositories, DTOs, and external API integrations (Plaid/Supabase).
- **`domain/`**: Pure business logic, entity definitions, and repository interfaces.
- **`presentations/`**: UI layer consisting of screens, reusable widgets, and state controllers.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.9.2)
- Plaid Developer Account (for API keys)
- Supabase Project (for backend and auth)

### Installation
1. **Clone the repository:**
   ```bash
   git clone https://github.com/Alok-kumar2024/pennywise-finance-app.git
   cd pennywise-finance-app
   ```

2. **Configure environment variables:**
   Create a `.env` file in the root directory based on `.env.example`:
   ```env
   PLAID_CLIENT_ID=your_id
   PLAID_SECRET=your_secret
   ```

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run the application:**
   ```bash
   flutter run
   ```

---

## 📂 Folder Structure

```text
lib/
├── main.dart             # App entry point
├── app.dart              # Root widget & Theme config
└── src/
    ├── core/             # Utils, Constants, Styling
    ├── data/             # Models & Repository implementations
    ├── domain/           # Entities & Abstract interfaces
    └── presentations/    # Screens & Widgets (UI)
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Built with ❤️ for Financial Freedom.
</p>
