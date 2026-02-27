Submitly Full Development Roadmap
Phase 0 — Foundation (Already Done ✅)

Environment

Flutter project created

NestJS backend created

Supabase PostgreSQL setup

Prisma connected

Database

User table

Subject table

Assignment table

Exam table

Backend

Prisma module

Users API (POST, GET)

Subjects API (POST, GET)

Frontend

Flutter connected to backend

Create User test working

Status:
Foundation Complete ✅

Phase 1 — Core User System (Current Phase)
Step 7 — User Identity Layer

Find or Create User API

Prevent duplicate users

Backend login endpoint

Step 8 — Google Sign-In (Flutter)

Google authentication

Get user email & name

Send to backend /users/login

Store user locally

Step 9 — Local User Session

Save userId in Flutter (SharedPreferences)

Auto login on app start

After Phase 1:
User system fully working.

Phase 2 — Core Features (Main App)
Step 10 — Subject Module (Flutter)

Add Subject screen

List Subjects from API

Step 11 — Assignment Module (Backend)

APIs:

Create Assignment

Get Assignments by user

Update status

Delete

Step 12 — Assignment UI (Flutter)

Add assignment screen

Assignment list

Mark as Submitted

Step 13 — Exam Module

Backend:

Create exam

Get exams

Flutter:

Add exam screen

Upcoming exams list

Phase 3 — File & Submission Features
Step 14 — File Upload

Options:

Supabase Storage (recommended)

Features:

Upload assignment file

Save file URL

Step 15 — Submission Link Feature

Save Google Form / Drive link

Open in WebView

Phase 4 — Notifications
Step 16 — Local Notifications

Assignment deadline reminder

Exam reminder

Step 17 — Background Scheduling

Check upcoming deadlines

Phase 5 — UI & App Structure
Step 18 — Clean Architecture in Flutter

Folders:

features/

core/

services/

providers/

Step 19 — Dashboard Screen

Show:

Upcoming assignments

Upcoming exams

Phase 6 — Production Level
Step 20 — Error Handling

API error handling

Network retry

Step 21 — Environment Config

Dev / Production URLs

Step 22 — App Security

Validate inputs

Protect APIs

Phase 7 — Advanced Features (Later)

Auto submission helper

Google Drive upload

Offline mode

Dark mode

Analytics

Phase 8 — Deployment
Backend

Deploy NestJS to Railway

Database

Supabase (already cloud)

Flutter

Build APK

Play Store release