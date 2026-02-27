# Submitly

**Submitly** is a full-stack productivity app for college students to manage assignments, subjects, and exams — and never miss a deadline.

---

## 🚀 Features (Current)

* User Management (Create & Fetch users)
* Subject Management (Add & List subjects)
* REST API with NestJS
* PostgreSQL Database (Supabase)
* Prisma ORM
* Flutter mobile app connected to backend
* End-to-end working system:

Flutter → API → Prisma → Supabase

---

## 🏗️ Tech Stack

### Frontend

* Flutter (Dart)

### Backend

* NestJS (Node.js)
* Prisma ORM

### Database

* PostgreSQL (Supabase)

### Tools

* Git & GitHub
* REST API
* Thunder Client / Postman

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

1. Go to backend folder:

```
cd backend_api/submitly-api
```

2. Install dependencies:

```
npm install
```

3. Create `.env` file:

```
DATABASE_URL=your_supabase_pooler_url
```

4. Run server:

```
npm run start:dev
```

Backend runs at:

```
http://localhost:3000
```

---

## 📱 Flutter Setup

1. Go to mobile folder:

```
cd mobile_app/submitly
```

2. Install packages:

```
flutter pub get
```

3. Update API base URL:

**Android Emulator**

```
http://10.0.2.2:3000
```

**Real Device**

```
http://YOUR_PC_IP:3000
```

4. Run app:

```
flutter run
```

---

## 🔌 API Endpoints

### Users

POST `/users`
Create user

GET `/users?email=example@test.com`
Get user by email

---

### Subjects

POST `/subjects`
Create subject

GET `/subjects?userId=USER_ID`
Get subjects for a user

---

## 🗄️ Database Schema

Tables:

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

## 📌 Current Status

✅ Backend connected to Supabase
✅ Prisma working
✅ APIs tested (POST & GET)
✅ Flutter connected to backend
✅ Data stored in cloud database

---

## 🔮 Upcoming Features

* Google Sign-In
* User session management
* Assignment module
* Exam tracker
* File upload
* Notifications
* Dashboard UI

---

## 👨‍💻 Author

**Sahidur Rahman Mondal**

---

## ⭐ Project Goal

This project is being built as an **industry-level full-stack mobile application** and portfolio project.