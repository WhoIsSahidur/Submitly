# Submitly

Submitly is a full-stack mobile application designed to help college students manage assignments, subjects, and exams efficiently.

---

## 🚀 Current Status

### Phase 0 – Foundation ✅

* Flutter mobile app
* NestJS backend
* Prisma ORM
* Supabase PostgreSQL
* GitHub version control

### Phase 1 – User System ✅

* Google Sign-In (Firebase)
* Email & profile retrieved from Google
* Backend auto user creation (`/users/login`)
* User session saved locally
* End-to-end authentication flow working

---

## 🏗️ Architecture

Flutter
⬇
NestJS API
⬇
Prisma ORM
⬇
Supabase PostgreSQL
⬇
Firebase (Google Authentication)

---

## 📁 Project Structure

```
Submitly/
│
├── mobile_app/        # Flutter application
│   └── submitly/
│
├── backend_api/       # NestJS backend
│   └── submitly-api/
│
└── README.md
```

---

## ⚙️ Backend Setup

```
cd backend_api/submitly-api
npm install
```

Create `.env`

```
DATABASE_URL=your_supabase_pooler_url
```

Run:

```
npm run start:dev
```

Server runs at:

```
http://localhost:3000
```

---

## 📱 Flutter Setup

```
cd mobile_app/submitly
flutter pub get
flutter run
```

### API Base URL

Android Emulator:

```
http://10.0.2.2:3000
```

Real Device:

```
http://YOUR_PC_IP:3000
```

---

## 🔌 API Endpoints

### Users

POST `/users/login`
Find or create user

GET `/users?email=...`
Get user by email

---

### Subjects

POST `/subjects`
Create subject

GET `/subjects?userId=...`
Get user subjects

---

## 🗄️ Database Tables

* User
* Subject
* Assignment
* Exam

Relationships:

```
User
 ├── Subjects
 ├── Assignments
 └── Exams
```

---

## 🔮 Next Phase

Phase 2 – Core Features

* Subject UI (Flutter)
* Dashboard
* Assignment module
* Exam tracker

---

## 👨‍💻 Author

Sahidur Rahman Mondal

---

## ⭐ Goal

Build an industry-level full-stack mobile application for portfolio and real-world use.