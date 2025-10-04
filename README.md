# bmi_app
Dự án sử dụng **Flutter 3.29.2 (stable)** • **Dart 3.7.2**.  

---

## 📂 Cấu trúc thư mục

lib/
├─ app/ # Entry point và cấu hình ứng dụng
│ ├─ widgets/ # Widget chung (AppShell, Navigation, Router)
│ ├─ app.dart # Khởi tạo MaterialApp, theme, provider
│ ├─ navigation.dart # Điều hướng app
│ └─ router.dart # Định nghĩa route chính
│
├─ core/ # Tầng lõi, dùng chung toàn hệ thống
│ ├─ auth/ # Quản lý đăng nhập, token storage
│ ├─ config/ # Cấu hình, env, constants
│ ├─ db/ # Database/local storage
│ ├─ navigation/ # Điều hướng cơ bản
│ ├─ network/ # Khởi tạo Dio client, interceptor
│ └─ theme/ # Cấu hình theme, màu sắc
│
├─ features/ # Tổ chức theo module (feature-first)
│ ├─ auth/ # Đăng nhập/đăng ký
│ ├─ blog/ # Bài viết, tin tức
│ ├─ bmi/ # Tính BMI
│ └─ chat/ # Chat với chuyên gia
│ ├─ application/ # ChatController (state, logic, gọi API)
│ ├─ data/ # Chat models (Freezed/JSON)
│ └─ presentation/ # UI chat
│ ├─ chat_page.dart # Màn hình chat
│ └─ widgets/ # Bubble, composer, text formatter
│
├─ home/ # Màn hình Home
└─ profile/ # Màn hình hồ sơ người dùng

---

## 🚀 Cách chạy
1.  **Clone repository:**
    ```bash
    git clone <your-repository-url>
    cd bmi_app
    ```

2.  **Cài đặt dependencies:**
    ```bash
    flutter pub get
    ```
    
## 📦 Build

* **Build file APK debug:**
    ```bash
    flutter build apk --debug
    ```

* **Build file APK release:**
    ```bash
    flutter build apk --release
    ```