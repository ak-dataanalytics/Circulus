# CIRCULUS System Architecture

## 1. Overview
CIRCULUS is an exclusive, invitation-only professional networking platform for Level 7+ Government Officers, Faculty, and Administrators.

```mermaid
graph TD
    subgraph Client Tier
        Flutter[Flutter Mobile App Android/iOS]
        ReactAdmin[React TypeScript Admin Dashboard]
    end

    subgraph API Tier
        FastAPI[Python FastAPI Backend Gateway]
        AuthRouter[/api/v1/auth]
        UserRouter[/api/v1/users]
        PostRouter[/api/v1/posts]
        GameRouter[/api/v1/games]
        LeaderboardRouter[/api/v1/leaderboard]
        ChatRouter[/api/v1/chat]
    end

    subgraph Persistence & Realtime Tier
        SupabasePostgres[(Supabase PostgreSQL 15)]
        SupabaseAuth[Supabase Auth JWT]
        SupabaseStorage[Supabase Object Storage]
        SupabaseRealtime[Supabase Realtime Messaging]
    end

    Flutter --> FastAPI
    ReactAdmin --> FastAPI
    FastAPI --> SupabasePostgres
    FastAPI --> SupabaseAuth
    Flutter -.-> SupabaseStorage
    Flutter -.-> SupabaseRealtime
```

## 2. Core Subsystems

### 2.1 Backend (Python FastAPI)
- **Framework**: FastAPI (Async)
- **Validation**: Pydantic v2
- **ORM**: SQLAlchemy 2.0 with `asyncpg`
- **Security**: JWT verification matching Supabase `HS256`, PBKDF2/bcrypt hashing, RBAC dependencies (`require_admin`, `require_moderator`).

### 2.2 Mobile Client (Flutter)
- **State Management**: Riverpod (`flutter_riverpod`)
- **Navigation**: GoRouter with declarative shell routes
- **Design System**: Material 3 with CIRCULUS Navy & Gold (`#101A2B`, `#D4AF62`)
- **Networking**: Dio with secure token persistence via `flutter_secure_storage`.

### 2.3 Administration (React TypeScript)
- **Framework**: Vite + React 18 + TypeScript + Tailwind CSS
- **Features**: Real-time KPI dashboards, verification queues, single-use invitation code generation, content moderation, security audit logs.

### 2.4 Brain Arena (Intellectual Engine)
- **Sudoku Engine**: Pure mathematical 9x9 grid generator with backtracking validator.
- **Anti-Cheat Validation**: Server-side verification for minimum duration thresholds, sub-grid digit conflict checks, and anti-replay session controls.
- **Points & Weekly Podium**: Automatic weekly aggregation sealing Gold/Silver/Bronze winners every Sunday at 23:59:59 (Asia/Kolkata).
