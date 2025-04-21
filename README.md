# 🚀 Todo Kanban Management App

Frontend: Flutter  
Backend: Go (Golang)

## 📁 Project Structure
- frontend/ : Flutter App (Kanban Board UI)
- backend/ : Golang API server

## 🛠 How to Setup (Frontend Flutter)

1. Install Flutter SDK
2. cd frontend/
3. Run: `flutter pub get`
4. Run app: `flutter run -d chrome`

## 🛠 How to Setup (Backend Golang)

1. Install Go (1.20+)
2. cd backend/
3. Run: `go mod tidy`
4. Run server: `go run main.go`

## 🔥 Current Features

- View tasks by status (To Do, Doing, Done)
- Drag and drop task to update status
- Drag task to delete
- Add new task

## 📣 Notes for New Developer
- Selalu pull dulu sebelum push
- Pakai branch per fitur (`feature/xxx`)
- Gunakan commit message yang jelas: `feat: add delete feature`, `fix: drag bug`
- Kalau nambah package Flutter ➔ jangan lupa push update `pubspec.yaml`

## 📋 To Do Next
- Task Detail Page
- SnackBar notifications
- Reorder tasks in column