# BIS Sahayak 🇮🇳

**BIS Sahayak** is an AI-powered cross-platform mobile assistant designed to simplify Indian Standards (IS), Bureau of Indian Standards (BIS) certification procedures, gold hallmarking verification, and product compliance for citizens, jewellers, manufacturers, and MSMEs.

---

## 🌟 Key Features

### 🤖 AI-Powered RAG Chat Assistant
- **Interactive Conversational AI**: Instant answers for queries regarding Indian Standards, ISI mark registration, hallmarking, and MSME compliance.
- **Clause Citations & Source Attributions**: Built-in markdown rendering with tappable inline citation links (`bis://`) and external source link attribution chips.
- **Persistent Conversations**: Creates and syncs chat history with the backend server.

### 🔍 Gold Jewellery HUID Verification
- **6-Digit HUID Verification**: Real-time verification of Hallmark Unique Identification (HUID) codes stamped on gold jewellery against official BIS records.
- **Detailed Hallmarking Insights**: Displays jeweller name, registration number, Assaying and Hallmarking Centre (AHC), purity/fineness, article type, gross weight, and hallmarking date.

### 📜 BIS License & ISI Mark Verification
- **CM/L License Verification**: Check validity of Manufacturer License Numbers (CM/L).
- **Certification Details**: Displays manufacturer name, factory address, brand, product name, applicable Indian Standard (IS), and license validity date.

### 🧭 Standards Discovery & Product Finder
- **Search-as-you-type**: Debounced search across titles, product categories, and IS codes.
- **Category Filtering**: Filter by Mandatory, Voluntary, and Draft standards.
- **AI Simplified View**: Toggle between AI-simplified plain language summaries and original standard text.

### 📋 Interactive Compliance Journeys
- **Step-by-step Roadmaps**: Visual compliance workflows for product categories (e.g., LED Lighting, Electricals).
- **Progress Checklists**: Progress tracking for lab testing, sample submission, factory audit, and license grant.

### 🔐 Secure Authentication & Session Management
- **Registration with OTP Verification**: Email verification flow with OTP codes sent via email.
- **Encrypted Storage**: Secure JWT access token storage using `FlutterSecureStorage`.
- **Automatic Token Refresh**: Dio interceptor queuing with cookie session management (`CookieJar` & `dio_cookie_manager`).

---

## 🏗️ Architecture & Project Structure

The project follows a **Clean Layered Architecture** with Riverpod state management:

```
lib/
├── config/                  # API endpoints & environment constants
│   └── api_config.dart
├── network/                 # Network client, interceptors & secure storage
│   ├── auth_interceptor.dart
│   ├── api_exception.dart
│   └── token_storage.dart
├── models/                  # Data transfer objects & models
│   ├── app_user.dart
│   ├── chat_message.dart
│   ├── chat_reply.dart
│   ├── conversation.dart
│   ├── verification_models.dart
│   ├── standard.dart
│   ├── standard_detail.dart
│   └── compliance_journey.dart
├── repositories/            # Data source abstraction layer
│   ├── auth_repository.dart
│   ├── chat_repository.dart
│   ├── conversation_repository.dart
│   ├── verification_repository.dart
│   └── standards_repository.dart
├── providers/               # Riverpod state management providers
│   ├── auth_provider.dart
│   ├── chat_provider.dart
│   ├── conversation_provider.dart
│   ├── verification_provider.dart
│   ├── standards_provider.dart
│   ├── repository_providers.dart
│   └── network_providers.dart
├── routes/                  # App routing with GoRouter
│   └── app_router.dart
├── theme/                   # Material 3 design system theme
│   └── app_theme.dart
├── widgets/                 # Reusable UI components
│   ├── async_view.dart
│   ├── chat_bubble.dart
│   ├── citation_chip.dart
│   ├── main_scaffold.dart
│   ├── standard_result_card.dart
│   ├── status_badge.dart
│   └── expandable_section_card.dart
└── screens/                 # Main screen views
    ├── splash/
    ├── auth/
    ├── home/
    ├── assistant/
    ├── explore/
    ├── verify/
    ├── saved/
    ├── profile/
    ├── standard_details/
    └── compliance_journey/
```

---

## 🛠️ Tech Stack & Dependencies

- **Framework**: [Flutter](https://flutter.dev) (Dart 3)
- **State Management**: [Flutter Riverpod 2.x](https://riverpod.dev)
- **Navigation**: [GoRouter 14.x](https://pub.dev/packages/go_router)
- **HTTP Client**: [Dio](https://pub.dev/packages/dio)
- **Security & Cookies**: `flutter_secure_storage`, `cookie_jar`, `dio_cookie_manager`
- **Formatting & UI**: `flutter_markdown`, `url_launcher`, `intl`, `uuid`

---

## 🌐 API Endpoint Specifications

**Backend Base URL**: `https://backend-fkpu.onrender.com/api`

| Module | Endpoint | Method | Description |
| :--- | :--- | :--- | :--- |
| **Auth** | `/auth/register` | `POST` | User registration |
| **Auth** | `/auth/verify-email` | `GET` | Email OTP verification |
| **Auth** | `/auth/login` | `POST` | User login (returns `accessToken`) |
| **Auth** | `/auth/get-me` | `GET` | Retrieve logged-in user profile |
| **Auth** | `/auth/refresh-token`| `POST` | Refresh access token via session cookie |
| **Auth** | `/auth/logout` | `POST` | Logout current session |
| **Auth** | `/auth/logout-all` | `POST` | Logout all active sessions |
| **Verify** | `/verify/huid` | `POST` | Gold Jewellery HUID Verification |
| **Verify** | `/verify/license` | `POST` | BIS Manufacturer License Verification |
| **Chat** | `/chat` | `POST` | AI RAG Chat Query & Citations |
| **Conversations**| `/conversations` | `GET`/`POST` | Retrieve / Create conversations |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.3.0 or higher)
- Android Studio / VS Code with Flutter extension
- Android Emulator (API 21+) or physical device

### Installation & Run

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-org/bis_sahayak.git
   cd bis_sahayak
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run Static Analysis**:
   ```bash
   flutter analyze
   ```

4. **Run the Application**:
   ```bash
   flutter run
   ```

5. **Build Android Debug APK**:
   ```bash
   flutter build apk --debug
   ```

---

## 📄 License

This project is developed for SIH (Smart India Hackathon) - Problem Statement SIH 26107.
