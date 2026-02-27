# Submitly

Submitly is a full-stack mobile application designed to help college students manage subjects, assignments, and exams efficiently.

This project is built as an **industry-level portfolio app** using Flutter, NestJS, Prisma, and Supabase.

---

## 🚀 Current Status

### Phase 0 – Foundation ✅

* Flutter mobile app
* NestJS backend
* Prisma ORM
* Supabase PostgreSQL
* GitHub version control
* REST API integration

---

### Phase 1 – Authentication ✅

* Firebase Google Sign-In
* User email & profile retrieved
* Backend auto user creation (`/users/login`)
* Persistent session (auto login)

---

### Phase 2 – Core MVP Features ✅

#### Navigation

* Bottom Navigation Bar
* Dashboard
* Subjects
* Assignments
* Exams (placeholder)

---

#### Subjects Module

* Create subject
* Fetch subjects by user
* Subject list
* Stored in Supabase

---

#### Assignments Module

* Create assignment
* Subject selection (dropdown)
* Due date picker
* Fetch assignments
* Mark as submitted
* Data persistence

---

#### Dashboard

* Total subjects count
* Total assignments count
* Pending assignments
* Upcoming deadlines overview

---

## 🏗️ Architecture

Flutter (Mobile)
⬇
NestJS API
⬇
Prisma ORM
⬇
Supabase PostgreSQL
⬇
Firebase Authentication

---

## 📁 Project Structure

Submitly/
├── mobile_app/        # Flutter application
├── backend_api/       # NestJS backend
└── README.md

---

## ⚙️ Backend Setup

```bash
cd backend_api/submitly-api
npm install
```

Create `.env`

```
DATABASE_URL=your_supabase_url
```

Run backend:

```bash
npm run start:dev
```

Server:

```
http://localhost:3000
```

---

## 📱 Flutter Setup

```bash
cd mobile_app/submitly
flutter pub get
flutter run
```

### API Base URL

Android Emulator:

```
http://10.0.2.2:3000
```

Physical Device:

```
http://YOUR_PC_IP:3000
```

---

## 🗄️ Database Tables

* User
* Subject
* Assignment
* Exam

Relationships:

User
├── Subjects
├── Assignments
└── Exams

---

## 🔮 Next Phase

Phase 3 – Advanced Features

* Exam module
* Deadline notifications
* File upload
* UI improvements
* Production deployment

---

## 👨‍💻 Author

**Sahidur Rahman Mondal**

---

## ⭐ Project Goal

Build a production-ready full-stack mobile application for portfolio and real-world use.