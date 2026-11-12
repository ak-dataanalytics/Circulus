# CIRCULUS

**Tagline:** *Beyond Ranks. Beyond Boundaries.*  
**Product Category:** Exclusive Professional Social Networking Platform for Verified Government Officers (Level 7+) and Authorized Faculty.

---

## FIRST-TIME SETUP: FROM ZERO TO RUNNING APPLICATION

Follow this sequential checklist to get the entire CIRCULUS platform running on your development machine:

- [ ] **Step 1: Install Core Software**
  - Python 3.13+ (`python --version`): [python.org](https://www.python.org/)
  - Flutter 3.20+ (`flutter --version`): [docs.flutter.dev](https://docs.flutter.dev/get-started/install/windows)
  - Android Studio & Android SDK Platform 34: [developer.android.com](https://developer.android.com/studio)
  - Node.js LTS 20+ (`node --version`): [nodejs.org](https://nodejs.org/)
- [ ] **Step 2: Set Up Supabase Project**
  - Create free account on [supabase.com](https://supabase.com).
  - Create new project named `circulus` (select region `ap-south-1` Mumbai).
  - Copy Project URL, Anon Key, Service Role Key, and PostgreSQL connection string.
- [ ] **Step 3: Run Database Migrations**
  - Open Supabase **SQL Editor**.
  - Execute `database/migrations/001_initial_schema.sql` (Creates all 36 tables).
  - Execute `database/migrations/002_rls_policies.sql` (Applies Row Level Security).
  - Execute `database/migrations/003_functions_triggers.sql` (Applies podium triggers).
  - Execute `database/migrations/004_indexes.sql` (Applies performance indexes).
  - Execute `database/seed/001_seed_data.sql` and `002_seed_games.sql` (Loads test data).
- [ ] **Step 4: Configure Environment Variables**
  - Copy `.env.example` to `.env` in the project root and fill in your Supabase credentials.
- [ ] **Step 5: Start Backend API**
  - Open PowerShell:
    ```powershell
    cd backend
    python -m pip install -r requirements.txt
    python -m pytest tests/
    python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
    ```
  - Verify API docs at `http://localhost:8000/docs`.
- [ ] **Step 6: Start React Admin Dashboard**
  - Open a second terminal:
    ```powershell
    cd admin
    npm install
    npm run dev
    ```
  - Access portal at `http://localhost:3000`.
- [ ] **Step 7: Build & Launch Flutter Android Application**
  - Open a third terminal:
    ```powershell
    cd mobile
    flutter pub get
    flutter run
    ```
  - Or generate an APK for your Android phone:
    ```powershell
    flutter build apk --debug
    ```
  - Install on connected phone:
    ```powershell
    adb install -r build/app/outputs/flutter-apk/app-debug.apk
    ```

---

## 1. Project Overview
CIRCULUS is a private, invitation-only professional networking ecosystem designed specifically for verified civil service officers at Level 7 and above, university and academy faculty members, and authorized institutional administrators. It provides a secure, permanent platform bridging former students and professors while fostering peer collaboration across departmental boundaries.

## 2. Product Vision
Faculty teach thousands of officers throughout their careers. While students retain clear memories of their professors, individual faculty members cannot maintain direct contact with every former trainee. CIRCULUS establishes a permanent institutional directory linking officers to their respective academies, batches, and professors, combined with intellectual challenges and peer circles.

## 3. Complete Feature List
- **Invitation-Only Gate**: Single-use, expiring invitation keys with cryptographic verification.
- **Two-Tier Verification**: Account creation requires institutional administrator review and approval.
- **Persistent Directory**: Search by name, cadre, batch, training academy, and current posting.
- **Social Feed**: Text and image posts, threaded discussions, and daily knowledge drops.
- **Professional Circles**: Public-to-members and private communities for policy, digital governance, and administrative law.
- **Executive Webinars & Events**: Seminar scheduling, RSVP attendance, and digital meeting links.
- **Secure Messaging**: 1-to-1 personal chats and group channels with document and image attachments.
- **Brain Arena**: Real interactive games (9x9 Sudoku with backtracking solver, Governance & GK timed quizzes, 4x4 Executive Memory Matrix).
- **Points & Weekly Podium**: Automatic weekly point calculations sealing Gold, Silver, and Bronze winners on permanent member profiles every Sunday at 23:59:59 (Asia/Kolkata).
- **Administration Dashboard**: Responsive React console for approving officer registrations, managing single-use codes, and monitoring audit logs.

## 4. Technology Stack
- **Mobile Client**: Flutter 3.20+, Dart 3.2+, Material Design 3, GoRouter, Riverpod, Dio.
- **Backend API**: Python 3.13, FastAPI, Pydantic v2, SQLAlchemy 2.0 Async, asyncpg.
- **Database & Auth**: PostgreSQL 15 on Supabase, Supabase Auth JWT (`HS256`), Supabase Storage.
- **Admin Dashboard**: React 18, TypeScript, Vite, Tailwind CSS, Lucide icons.
- **Automated Testing**: Pytest, Pytest-Asyncio, Flutter Test framework.

## 5. System Architecture
See detailed architectural flowchart in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## 6. Project Folder Structure
```
CIRCULUS/
├── mobile/                   # Flutter cross-platform mobile application
│   ├── android/              # Native Android configuration (Manifest, Gradle, Kotlin)
│   ├── lib/
│   │   ├── core/             # Theme, services, widgets, router, constants
│   │   └── features/         # Auth, Feed, Directory, Games, Chat, Profile
│   └── test/                 # Flutter unit & widget tests
├── backend/                  # Python FastAPI backend
│   ├── app/
│   │   ├── api/v1/           # Modular REST API endpoints
│   │   ├── core/             # Database session, JWT security, configuration
│   │   ├── models/           # SQLAlchemy ORM models (36 tables)
│   │   ├── schemas/          # Pydantic v2 schemas
│   │   └── services/         # Game engine, points engine, common services
│   └── tests/                # Automated pytest suites (game engine, security)
├── admin/                    # React TypeScript Admin Dashboard
│   ├── src/                  # Components, pages, hooks, services
│   └── package.json          # Node dependencies
├── database/                 # Database migrations and seed data
│   ├── migrations/           # 001_initial_schema to 004_indexes
│   └── seed/                 # 001_seed_data and 002_seed_games
├── docs/                     # Full technical manuals
│   ├── ARCHITECTURE.md
│   ├── DATABASE_SCHEMA.md
│   ├── API_DOCUMENTATION.md
│   ├── TESTING_GUIDE.md
│   └── ANDROID_INSTALLATION.md
├── scripts/                  # Automated PowerShell setup scripts
├── .env.example              # Environment variables template
├── README.md                 # Complete documentation
└── DEVELOPMENT_STATUS.md     # Feature verification status
```

## 7. Prerequisites
- Windows 10/11 (x64)
- 8 GB RAM minimum (16 GB recommended)
- 15 GB free disk space

## 8. Software Installation Requirements
Download and install:
1. Python 3.13: [python.org/downloads](https://www.python.org/downloads/) (Check "Add python.exe to PATH")
2. Flutter SDK: [docs.flutter.dev/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows)
3. Node.js LTS: [nodejs.org](https://nodejs.org/)
4. Android Studio: [developer.android.com/studio](https://developer.android.com/studio)

## 9. Flutter Setup on Windows
1. Extract Flutter SDK to `C:\src\flutter`.
2. Add `C:\src\flutter\bin` to your User `PATH` environment variable.
3. Open PowerShell and run:
   ```powershell
   flutter doctor
   ```
4. Accept Android licenses:
   ```powershell
   flutter doctor --android-licenses
   ```

## 10. Android Studio and Android SDK Setup
1. Launch Android Studio.
2. Open **Tools > SDK Manager**.
3. Under **SDK Platforms**, install **Android 14.0 (API 34)**.
4. Under **SDK Tools**, check:
   - Android SDK Build-Tools 34
   - Android SDK Command-line Tools (latest)
   - Android Emulator
   - Android SDK Platform-Tools

## 11. Python Environment Setup
Verify Python installation:
```powershell
python --version
python -m pip --version
```

## 12. Node.js Setup
Verify Node.js and npm:
```powershell
node --version
npm --version
```

## 13. Supabase Account Creation
1. Visit [supabase.com](https://supabase.com) and click **Sign Up**.
2. Authenticate using your GitHub account or email.

## 14. Supabase Project Creation
1. Click **New Project**.
2. Enter Name: `circulus-prod`.
3. Enter strong Database Password (store securely).
4. Select Region: `ap-south-1` (Mumbai, India).
5. Choose Free Pricing Plan and click **Create new project**.

## 15. Database Configuration
1. In the Supabase Dashboard, go to **Project Settings > Database**.
2. Note your Connection String (URI format under Connection pooling / direct connection).

## 16. Database Migrations
1. In the Supabase Dashboard, click **SQL Editor**.
2. Open `database/migrations/001_initial_schema.sql`, copy all text, paste into the editor, and click **Run**.
3. Repeat sequentially for:
   - `002_rls_policies.sql`
   - `003_functions_triggers.sql`
   - `004_indexes.sql`

## 17. Seed Data Setup
In the Supabase SQL Editor:
1. Paste and run `database/seed/001_seed_data.sql`.
2. Paste and run `database/seed/002_seed_games.sql`.

## 18. Authentication Configuration
1. Go to **Authentication > Providers** in Supabase.
2. Ensure **Email** provider is enabled.
3. In **Authentication > URL Configuration**, add `http://localhost:3000` (Admin) and `circulus://callback` (Mobile).

## 19. Storage Bucket Configuration
1. Go to **Storage > New Bucket**.
2. Create bucket named `avatars` (Public).
3. Create bucket named `post_media` (Public).
4. Create bucket named `documents` (Restricted).

## 20. Realtime Configuration
1. Go to **Database > Publications**.
2. Ensure table `messages` is included in `supabase_realtime` publication.

## 21. Environment Variable Setup
Copy `.env.example` to `.env`:
```powershell
Copy-Item .env.example .env
```
Fill in your Supabase Project URL, Anon Key, and Service Role Key.

## 22. Backend Installation
```powershell
cd backend
python -m pip install -r requirements.txt
```

## 23. Backend Startup Commands
```powershell
cd backend
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

## 24. Flutter Installation Commands
```powershell
cd mobile
flutter pub get
```

## 25. Flutter Startup Commands
```powershell
cd mobile
flutter run
```

## 26. React Admin Dashboard Setup
```powershell
cd admin
npm install
npm run dev
```

## 27. Admin Account Creation
Default seeded administrator:
- Email: `admin@circulus.app`
- Role: `superadmin`

## 28. Test User Credentials
- Faculty Member: `dr.sharma@circulus.app` (Prof. Rajesh Sharma)
- Verified Officer 1: `ananya.verma@circulus.app` (Ananya Verma, Deputy Secretary)
- Verified Officer 2: `vikram.singh@circulus.app` (Vikram Singh, Joint Director)

## 29. Invitation Creation Procedure
1. Open Admin Dashboard at `http://localhost:3000/invitations`.
2. Enter officer's email address and select Role.
3. Click **Generate Key**.
4. Share the generated code (e.g. `CIRCULUS2026`).

## 30. Complete Feature Testing Guide
See [docs/TESTING_GUIDE.md](docs/TESTING_GUIDE.md).

## 31. Running Automated Tests
```powershell
cd backend
python -m pytest tests/
```

## 32. Generating Android APK
```powershell
cd mobile
flutter build apk --debug
```
Output: `mobile/build/app/outputs/flutter-apk/app-debug.apk`

## 33. Installing APK on an Android Phone
```powershell
adb install -r mobile/build/app/outputs/flutter-apk/app-debug.apk
```

## 34. Configuring Physical-Device Connectivity
See [docs/ANDROID_INSTALLATION.md](docs/ANDROID_INSTALLATION.md).

## 35. Troubleshooting Common Errors
- **Connection Refused in Android**: Replace `localhost` with your computer's Wi-Fi IPv4 address (`ipconfig`).
- **401 Unauthorized**: Ensure bearer token is attached in the request header.
- **Port 8000 already in use**: Kill existing process using `netstat -ano | findstr 8000` and `taskkill /F /PID <pid>`.

## 36. Database Backup and Restoration
Run `pg_dump`:
```bash
pg_dump -U postgres -h db.your-id.supabase.co -d postgres > backup.sql
```

## 37. Security Considerations
- Zero trust on client game scores: Sudoku mathematical validity and time thresholds are enforced server-side.
- Row Level Security (RLS) is applied on all 36 PostgreSQL tables.
- No production secrets are committed in source control.

## 38. Free-Tier Limitations
- Supabase Free Tier allows up to 500 MB database storage, 50,000 monthly active users, and 1 GB file storage.

## 39. Deployment Instructions
- **Backend**: Containerize with Docker; deploy on Google Cloud Run or Railway.
- **Admin**: Build with `npm run build`; host on Cloudflare Pages or Vercel.
- **Mobile**: Build production release bundle using `flutter build appbundle`.

## 40. Future Development Roadmap
- Biometric verification via official digital locker APIs.
- Encrypted audio/video conferencing for Faculty Mentorship sessions.
- Multi-language localized UI for regional administrative academies.
