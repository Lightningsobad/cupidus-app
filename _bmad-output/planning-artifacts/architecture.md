---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
workflowType: 'architecture'
project_name: 'cupid'
user_name: 'Alan'
date: '2026-02-14'
status: 'complete'
lastStep: 8
completedAt: '2026-02-14'
---

# Architecture Decision Document

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## Project Context Analysis

### Requirements Overview

**Functional Requirements:**
- **Core:** Real-time Chat (Typing Ghost), Couple Connection (Pairing, Love Contract).
- **Engagement:** Vibe Check, Love Pet, Emoji Storm.
- **Utility:** Synced Alarm, Dream Jar, Calendar.
- **Architectural Driver:** Tính năng "Typing Ghost" yêu cầu WebSocket streaming cực nhanh (< 200ms) và xử lý state phức tạp.

**Non-Functional Requirements:**
- **Security:** Mã hóa 3 lớp (Local AES-256, E2E, TLS 1.3). Dữ liệu nhạy cảm (Vow) không rời device.
- **Scale:** Support 20k concurrent WebSocket connections (10k cặp đôi online cùng lúc).
- **Reliability:** Offline-first (Chat & Love Pet hoạt động không mạng). Zero data loss for Level 2 data.

**Scale & Complexity:**
- Primary domain: Mobile-First (iOS Native) + Cloud Backend.
- Complexity level: Medium-High (Real-time + E2E Encryption).
- Estimated architectural components: Mobile App, WebSocket Gateway, API Server, Push Service, Background Jobs.

### Technical Constraints & Dependencies

- **Client:** iOS Native (Swift, SwiftUI) — Apple Frameworks (FaceID, Combine).
- **Cloud:** Cloud Provider agnostic initially (GCP/AWS/Firebase), likely Firebase heavy.
- **Third-party:** Firebase Auth, Firebase Cloud Messaging (FCM).

### Cross-Cutting Concerns Identified

1. **Real-time Sync:** Synchronization of user states (Online/Typing/Mood) across devices.
2. **Encryption Key Management:** Secure E2E key exchange and storage without compromising UX.
3. **Offline Data Sync:** Conflict resolution strategy (Last-Write-Wins or CRDTs).

## Starter Template Evaluation

### Primary Technology Domain
**Full-Stack Mobile:** iOS Native (SwiftUI) Client + Node.js Backend.

### Selected Starters

**1. Mobile Client: Clean SwiftUI Project**
- **Starter:** None (Start from scratch with Xcode 'App' template).
- **Rationale:** Custom "Dual Type" UI and unique "Typing Ghost" interactions require a bespoke architecture (MVVM-Coordinator recommended) rather than a rigid boilerplate.
- **Key Decisions:**
  - Swift 6 + SwiftUI + Combine.
  - Dependency Manager: Swift Package Manager (SPM).
  - Architecture: MVVM-C (Model-View-ViewModel-Coordinator) for navigation flow control.

**2. Backend API: NestJS (Node.js)**
- **Starter:** `nestjs/nest-cli`
- **Rationale:** Structured, scalable Node.js framework. Great TypeScript support. Easy integration with Socket.io for Real-time features.
- **Initialization Command:**
  ```bash
  npm i -g @nestjs/cli
  nest new cupid-backend
  ```
- **Key Modules:**
  - `@nestjs/websockets` (Socket.io) for Typing Ghost.
  - `@nestjs/typeorm` or `Prisma` for Database.
  - `firebase-admin` for Auth & FCM.

### Architectural Decisions Provided by Starter (NestJS)
- **Language:** TypeScript (Strict mode).
- **Module System:** Dependency Injection container built-in.
- **Testing:** Jest pre-configured.
- **Validation:** `class-validator` + DTOs.

## Core Architectural Decisions

### Decision Priority Analysis

**Critical Decisions (Block Implementation):**
1.  **Database Strategy:** PostgreSQL 18 (Primary) + Redis 7 (Cache/PubSub).
2.  **Infrastructure:** Helper/MVP Setup on Standard VPS with Docker Compose.
3.  **Real-time Protocol:** WebSocket (Socket.io via NestJS Gateway).
4.  **E2E Encryption:** Libsodium (X25519 Key Exchange + XSalsa20 Encryption) for MVP simplicity.

### Data Architecture

- **Primary Database:** PostgreSQL 18 (Latest stable).
  - *Rationale:* Robust relational support for complex user graph constraints (Couple linking, request status).
  - *Migration Tool:* TypeORM Migrations (standard with NestJS).
- **Cache & Pub/Sub:** Redis 7.
  - *Rationale:* Essential for WebSocket scalability (Pub/Sub adapter) and high-performance caching of ephemeral states (Online status).

### Authentication & Security

- **Authentication:** Firebase Auth.
  - *Rationale:* Best-in-class security, handles Phone Auth complexity, easy iOS integration.
- **Data Encryption (Level 2):** Libsodium (Sodium-Native for Node, Sodium for Swift).
  - *Rationale:* Simple, high-performance, audit-proven crypto primitives. Easier to implement correctly than full Signal Protocol for MVP.

### Infrastructure & Deployment

- **Hosting Strategy:** Single VPS (Linux) running Docker.
  - *Rationale:* Cost-effective for MVP. Easy to migrate to Cloud Run later since everything is Dockerized.
- **Containerization:** Docker Compose for orchestration (App API + DB + Redis).
- **CI/CD:** GitHub Actions (Build Docker Image -> SSH Deploy to VPS).


## Implementation Patterns & Consistency Rules

### Naming Patterns

- **Database (PostgreSQL):** `snake_case` for all tables (`chat_messages`) and columns (`created_at`). Primary Keys: `id` (UUIDv7 recommended). Foreign Keys: `singular_table_id` (e.g., `user_id`).
- **API (JSON):** `camelCase` for all request/response bodies (`userId`, `isSent`).
- **URL Path:** `kebab-case` for resources (e.g., `/api/v1/chat-messages`).
- **Code (TS/Swift):** `camelCase` for variables/functions, `PascalCase` for Classes/Structs/Components. constant `UPPER_SNAKE_CASE`.

### Structural Patterns

- **NestJS (Modular Monolith):** Organized by **Domain Modules**.
  - `src/modules/chat/` (Module, Controller, Service, Gateway, Entities, DTOs).
  - `src/common/` (Shared Guards, Pipes, Interceptors, Utils).
- **SwiftUI (Feature-Based):** Organized by **Features**.
  - `App/Features/Chat/` (ChatView, ChatViewModel, ChatComponents).
  - `App/Core/` (NetworkManager, Storage, Extensions).
  - `App/DesignSystem/` (Shared UI Components).

### Communication Patterns

- **API Response Wrapper:** Standard format for all successful responses:
  ```json
  {
    "data": { ... },
    "meta": { "page": 1, "limit": 20 }
  }
  ```
- **Error Handling:** Standard format:
  ```json
  {
    "statusCode": 404,
    "message": "User not found",
    "errorCode": "USER_NOT_FOUND"
  }
  ```

### Process Patterns

- **Validation:** Strict DTO validation (NestJS `class-validator`) and Decodable strict mode (Swift). No loose types.
- **Magic Strings:** Forbidden. All configuration/constants must be extracted to Enums or Config Service.

## Project Structure & Boundaries

### Complete Project Directory Structure

**Root Configuration:** `package.json` (Monorepo setup if applicable), `.gitignore`, `README.md`.

**Source Code Organization (`source-code/`):**

- **`source-code/backend/`** (NestJS Modular Monolith)
  ```
  src/
  ├── app.module.ts
  ├── main.ts
  ├── config/             # Environment & Configuration
  ├── common/             # Shared Guards, Decorators, Filters
  ├── modules/            # Feature Modules
  │   ├── auth/           # Authentication Logic
  │   ├── chat/           # WebSocket Gateway & Messages
  │   ├── users/          # User Management
  │   └── ...
  ├── services/           # Shared Business Logic
  └── test/               # E2E & Integration Tests
  ```

- **`source-code/ios/`** (SwiftUI Feature-Based)
  ```
  CupidApp/
  ├── App/                # Entry Point, DI Container, AppCoordinator
  ├── Core/               # Shared Utilities (Network, Storage, DesignSystem)
  ├── Features/           # Feature Modules
  │   ├── Auth/           # Login Screens & Logic
  │   ├── Chat/           # Messaging UI & ViewModel
  │   ├── Onboarding/     # Love Contract Flow
  │   └── Dashboard/      # Main Tab Navigation
  └── Resources/          # Assets.xcassets, Localizations
  ```

- **`source-code/web/`** (Placeholder for Landing Page/Admin Panel)
- **`source-code/android/`** (Placeholder for Future Android Phase)

### Architectural Boundaries

- **API Boundary:** Strict DTO validation at Controller level. REST + WebSocket endpoints defined in `backend/src/modules/*/controllers`.
- **Component Boundary (iOS):** Features interact via Coordinator pattern or shared Services (in `Core/`). No direct dependency between Feature Views.
- **Data Boundary:** Backend manages PostgreSQL/Redis. iOS manages Local Storage (SwiftData/Realm) for offline capability.

### Requirements to Structure Mapping

- **Epic: Chat (Typing Ghost)** -> `backend/src/modules/chat` + `ios/Features/Chat` + `ios/Core/Security` (E2EE).
- **Epic: Auth (Phone)** -> `backend/src/modules/auth` + `ios/Features/Auth` + `backend/src/common/guards/auth.guard.ts`.
- **Epic: Offline Sync** -> `backend/src/modules/sync` (if separate) or integrated in `chat` + `ios/Core/Storage`.


## Architecture Validation Results

### Coherence Validation ✅
- **Tech Stack Compatibility:** NestJS (Node.js) + PostgreSQL + Redis work seamlessly on Docker/VPS infrastructure. No conflict with SwiftUI client.
- **Pattern Consistency:** MVVM-C (iOS) aligned with Feature-based modular structure. NestJS Modular Monolith aligned with Domain-driven design.
- **Security Alignment:** Libsodium integration feasible on both Swift (Sodium) and Node (sodium-native).

### Requirements Coverage Validation ✅
- **Real-time Chat:** Supported by WebSocket Gateway + Redis Pub/Sub adapter.
- **Offline Capability:** Supported by iOS Local Storage + Sync Logic.
- **Data Privacy:** Supported by defined E2E Encryption boundaries for sensitive data.

### Implementation Readiness ✅
- **Structure:** Complete directory tree defined for both platforms.
- **Patterns:** Naming, Communication, and Error Handling patterns documented.
- **Next Step:** Setup DevOps pipeline (GitHub Actions -> VPS) and generate API Specs.

### Architecture Completeness Checklist
- [x] Project context analyzed
- [x] Critical decisions documented (Postgres, Redis, NestJS, SwiftUI)
- [x] Implementation patterns defined (Naming, Structure)
- [x] Project structure mapped to `source-code/`
- [x] Validation completed

**Overall Status:** READY FOR IMPLEMENTATION.
