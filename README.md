# ✅ Todo App (Flutter)

A simple and elegant Todo application built with **Flutter**. It allows you to manage your tasks, mark them as complete, restore them, and toggle between light and dark themes. All data is stored locally using **SharedPreferences**, ensuring your tasks persist across sessions.

🚀 **Live Demo**: [View App on GitHub Pages](https://nabin68.github.io/Todo_app_web/)

---

## 📱 Features

- 📝 Add, complete, delete, and restore tasks
- 🌙 Toggle between dark and light mode
- 📂 Persistent task storage with `SharedPreferences`
- 🗂️ View **Pending** and **Completed** tasks separately
- 📆 Friendly date formatting: *“Today”, “Yesterday”, or exact dates*

---

## 🛠️ Installation & Run Locally

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Dart (included with Flutter)
- A modern code editor like VSCode or Android Studio

### Steps

```bash
# Clone the repository
git clone https://github.com/Nabin68/Todo_app_web.git
cd Todo_app_web

# Get dependencies
flutter pub get

# Run the app (in debug mode)
flutter run

# To build for web
flutter build web --base-href="/Todo_app_web/"

# Then push the contents of /build/web to the gh-pages branch:
git add build/web -f
git commit -m "Deploy web build"
git subtree push --prefix build/web origin gh-pages
