---
stepsCompleted: [1, 2, 3, 4]
inputDocuments:
  - _bmad-output/planning-artifacts/prd.md
  - _bmad-output/planning-artifacts/architecture.md
  - _bmad-output/planning-artifacts/ux-design-specification.md
project_name: 'cupid'
user_name: 'Alan'
date: '2026-02-14'
status: 'complete'
lastStep: 4
completedAt: '2026-02-14'
---

# Cupid - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for Cupid, decomposing the requirements from the PRD, UX Design, and Architecture requirements into implementable stories.

## Requirements Inventory

### Functional Requirements

**Account & Identity**
- FR1: User can tạo tài khoản mới bằng email hoặc social login (Google/Apple)
- FR2: User can đăng nhập vào tài khoản hiện có
- FR3: User can thiết lập hồ sơ cá nhân (tên, ảnh đại diện, ngày sinh, cung hoàng đạo)
- FR4: User can đặt ngôn ngữ ưa thích (Tiếng Việt / Tiếng Anh)
- FR5: User can khôi phục mật khẩu qua email

**Couple Pairing**
- FR6: User can tạo và ký Love Contract với các điều khoản hài hước có sẵn
- FR7: User can tùy chỉnh thêm điều khoản vào Love Contract
- FR8: User can mời đối phương ghép đôi thông qua link chia sẻ
- FR9: User can xác nhận ghép đôi bằng Fingerprint Vow (biometric xác nhận đồng thời)
- FR10: Cặp đôi can chọn kiểu quan hệ (yêu xa, cùng thành phố, mới yêu, yêu lâu...)

**Communication**
- FR11: User can gửi và nhận tin nhắn text trong Priority Channel
- FR12: User can gửi ảnh và emoji trong chat
- FR13: User can bật/tắt Typing Ghost (yêu cầu đồng thuận cả 2 bên)
- FR14: User can xem real-time keystroke của đối phương khi Typing Ghost bật (bao gồm phần đã xóa)
- FR15: Hệ thống can hiển thị bộ đếm "Đã seen X phút" khi tin nhắn chưa được trả lời
- FR16: User can kích hoạt Emoji Storm trên màn hình đối phương khi vượt ngưỡng thời gian chưa trả lời

**Daily Engagement**
- FR17: Cặp đôi can đặt Synced Alarm với thời gian chung, cả hai phải xác nhận để tắt
- FR18: User can hoàn thành Vibe Check hàng ngày (chọn trạng thái cảm xúc)
- FR19: User can xem Vibe Check history của cặp đôi
- FR20: Cặp đôi can nuôi Love Pet ảo chung, Love Pet phản ánh mức độ tương tác
- FR21: Love Pet can thay đổi trạng thái (vui/buồn/ốm) dựa trên tần suất tương tác
- FR22: User can xem cảnh báo Zodiac Red Flag dựa trên cung hoàng đạo của cặp đôi

**Financial Management**
- FR23: Cặp đôi can tạo Dream Jar với tên, mục tiêu số tiền (VND) và deadline
- FR24: User can ghi chép đóng góp vào Dream Jar (thủ công)
- FR25: User can theo dõi tiến độ Dream Jar (% hoàn thành)
- FR26: User can ghi chép chi tiêu chung trong Expense Manager
- FR27: User can xem báo cáo chi tiêu theo tuần/tháng

**Memory & Media**
- FR28: User can chụp/chọn ảnh và lưu vào Private Gallery (mã hóa cục bộ, Level 1)
- FR29: User can xem Private Gallery chỉ trên thiết bị của mình
- FR30: Hệ thống can tự động ghi lại các mốc quan trọng trên Love Timeline
- FR31: User can thêm mốc thủ công vào Love Timeline

**Anti-Ghosting & Engagement Mechanics**
- FR32: Cặp đôi can cấu hình ngưỡng thời gian Anti-Ghosting (5/10/15 phút)
- FR33: Cặp đôi can bật/tắt từng cơ chế Anti-Ghosting (đếm ngược, Emoji Storm)
- FR34: User can chọn emoji/sticker để sử dụng trong Emoji Storm

**Data & Privacy**
- FR35: Hệ thống can phân loại và lưu trữ dữ liệu theo 3 cấp độ (Device-Only / Backend Encrypted / Backend Raw)
- FR36: User can xuất dữ liệu cá nhân (data export)
- FR37: Hệ thống can mã hóa end-to-end tất cả dữ liệu Level 2
- FR38: Hệ thống can gửi push notifications theo 3 mức ưu tiên (Critical / Engagement / Informational)
- FR39: User can quản lý cài đặt thông báo (bật/tắt từng loại)

**Admin Configuration**
- FR40: Admin can cấu hình cấp độ lưu trữ cho từng loại dữ liệu
- FR41: Admin can cấu hình giới hạn push notifications/ngày/user
- FR42: Admin can bật/tắt quyền truy cập thiết bị theo nhóm tính năng
- FR43: Admin can xem metrics cơ bản (số cặp đôi, DAU)

### NonFunctional Requirements

**Performance**
- NFR1: Typing Ghost keystroke hiển thị trên thiết bị đối phương trong < 200ms
- NFR2: Tin nhắn chat gửi/nhận trong < 500ms (điều kiện mạng bình thường)
- NFR3: App khởi động cold start < 3 giây trên iPhone 11 trở lên
- NFR4: Emoji Storm animation render tại 60fps, không gây lag hệ thống
- NFR5: Private Gallery mở ảnh đã mã hóa trong < 1 giây
- NFR6: API response time trung bình < 300ms cho các thao tác CRUD

**Security**
- NFR7: Dữ liệu Level 1 mã hóa AES-256 trên thiết bị, không bao giờ rời device
- NFR8: Dữ liệu Level 2 mã hóa end-to-end, server không thể đọc nội dung
- NFR9: Dữ liệu Level 3 truyền tải qua TLS 1.3
- NFR10: Token authentication (JWT) hết hạn sau 24 giờ, refresh token 30 ngày
- NFR11: Biometric data (Fingerprint Vow) xử lý hoàn toàn cục bộ qua OS API, không gửi ra ngoài
- NFR12: Tuân thủ PDPA (Luật Bảo vệ Dữ liệu Cá nhân Việt Nam)
- NFR13: Data export hoàn thành trong < 5 phút cho tài khoản dưới 1GB dữ liệu

**Scalability**
- NFR14: Backend hỗ trợ 20,000 concurrent WebSocket connections (10,000 cặp đôi online đồng thời)
- NFR15: Hệ thống scale được lên 100,000 cặp đôi mà không cần thay đổi kiến trúc
- NFR16: FCM push xử lý burst tối thiểu 50,000 notifications/phút (Synced Alarm đồng loạt)
- NFR17: Database query time < 100ms cho p95 dưới 100K users

**Reliability**
- NFR18: Uptime ≥ 99.5% (downtime tối đa ~3.6 giờ/tháng)
- NFR19: Synced Alarm không bao giờ miss khi cả hai online (critical path)
- NFR20: Zero data loss cho Level 2 data khi server restart
- NFR21: Graceful degradation khi backend lỗi — chat cục bộ vẫn hoạt động với dữ liệu cached

**Integration**
- NFR22: Firebase Cloud Messaging tích hợp đúng chuẩn APNs cho iOS
- NFR23: Social login (Google Sign-In, Sign in with Apple) tuân thủ Apple App Review Guidelines
- NFR24: iOS Biometric API (Face ID / Touch ID) sử dụng LAContext framework chuẩn

### Additional Requirements

**From Architecture:**
- **Starter Template:** Clean SwiftUI Project (Feature-based MVVM-C) + NestJS Modular Monolith.
- **Infrastructure:** Docker Compose on VPS (Postgres 18, Redis 7).
- **Security:** Libsodium for E2E Encryption (X25519/XSalsa20).
- **Real-time:** Socket.io Gateway with Redis Adapter.
- **API Spec:** Must generate Swagger/OpenAPI documentation.
- **DevOps:** GitHub Actions for CI/CD deployment to VPS.

**From UX Design:**
- **Visual:** "Dual Mode" UI (Dark/Light auto-adaptive).
- **Interaction:** Dual-Confirmation for sensitive actions (Pairing, Alarm).
- **Typing Ghost:** Ghost text visual state (faded, strikethrough).
- **Consent Flow:** Explicit mutual consent UI for Typing Ghost.
- **Animation:** Lottie integration for Love Pet and Emoji Storm.
- **Accessibility:** Dynamic Type and VoiceOver support foundation.

### FR Coverage Map

FR1: Epic 1 - Account Creation
FR2: Epic 1 - Login
FR3: Epic 1 - Profile Setup
FR4: Epic 1 - Language Selection
FR5: Epic 1 - Password Recovery
FR6: Epic 1 - Love Contract Signing
FR7: Epic 1 - Contract Customization
FR8: Epic 1 - Invite Partner
FR9: Epic 1 - Fingerprint Vow
FR10: Epic 1 - Couple Type Selection

FR11: Epic 2 - Text Chat
FR12: Epic 2 - Media Chat
FR13: Epic 2 - Typing Ghost Toggle
FR14: Epic 2 - Real-time Keystrokes

FR15: Epic 3 - Seen Counter
FR16: Epic 3 - Emoji Storm Trigger
FR17: Epic 3 - Synced Alarm
FR18: Epic 3 - Vibe Check Input
FR19: Epic 3 - Vibe Check History
FR22: Epic 3 - Zodiac Red Flag
FR32: Epic 3 - Anti-Ghosting Config
FR33: Epic 3 - Anti-Ghosting Toggle
FR34: Epic 3 - Emoji Storm Selection

FR20: Epic 4 - Love Pet Interaction
FR21: Epic 4 - Love Pet Evolution
FR28: Epic 4 - Private Gallery Upload
FR29: Epic 4 - Private Gallery View
FR30: Epic 4 - Love Timeline Auto
FR31: Epic 4 - Love Timeline Manual

FR23: Epic 5 - Dream Jar Creation
FR24: Epic 5 - Dream Jar Contribution
FR25: Epic 5 - Dream Jar Progress
FR26: Epic 5 - Expense Logging
FR27: Epic 5 - Expense Reports

FR35: Epic 6 - Data Classification
FR36: Epic 6 - Data Export
FR37: Epic 6 - E2E Encryption
FR38: Epic 6 - Push Notification Priority
FR39: Epic 6 - Notification Settings
FR40: Epic 6 - Admin Data Config
FR41: Epic 6 - Admin Push Config
FR42: Epic 6 - Admin Device Access
FR43: Epic 6 - Admin Metrics

## Epic List

### Epic 1: Core Connection Foundation
**Goal:** Enable users to create accounts, establish the digital relationship via Love Contract, and pair securely.
**User Value:** Provides the necessary identity and connection framework for all couple interactions.
**FRs Covered:** FR1-10

### Epic 2: Radical Transparency Communication
**Goal:** Enable real-time communication with the unique "Typing Ghost" capability to see deleted thoughts.
**User Value:** Delivers the core "Toxic but Fun" differentiator and deepens emotional connection through transparency.
**FRs Covered:** FR11-14

### Epic 3: Daily Engagement & Habits
**Goal:** Foster daily interaction through synchronized habits (Alarm, Vibe Check) and playful accountability (Anti-Ghosting).
**User Value:** Builds a daily routine of connection and reduces communication friction.
**FRs Covered:** FR15-19, FR22, FR32-34

### Epic 4: Digital Intimacy & Memories
**Goal:** Create a shared space for emotional investment (Love Pet) and secure memory storage.
**User Value:** Transforms the app into a digital home for the relationship.
**FRs Covered:** FR20-21, FR28-31

### Epic 5: Shared Future (Finance)
**Goal:** Provide tools for shared financial goal setting (Dream Jar) and basic expense tracking.
**User Value:** Helps couples plan for a shared future and manage financial transparency.
**FRs Covered:** FR23-27

### Epic 6: Administration & Privacy Control
**Goal:** Ensure data privacy through granular controls and provide administration capabilities.
**User Value:** Builds trust through transparency about data usage and control.
**FRs Covered:** FR35-43

## Epic 1: Core Connection Foundation

**Goal:** Enable users to create accounts, establish the digital relationship via Love Contract, and pair securely.

### Story 1.1: Authentication System

As a User,
I want to register/login via Email or Social,
So that I can secure my account and access my relationship space.

**Acceptance Criteria:**

**Given** the user is on the welcome screen
**When** they choose "Sign in with Google" or "Sign in with Apple"
**Then** the app should authenticate with the provider and create a new account if one doesn't exist
**And** store the JWT token securely in the Keychain

**Given** the user chooses Email/Password
**When** they enter valid credentials and tap Register
**Then** the system should create an account and send a verification email

**Given** the user forgets their password
**When** they tap "Forgot Password"
**Then** they should receive a reset link via email

### Story 1.2: User Profile Setup

As a User,
I want to set up my profile (Name, Avatar, Zodiac),
So that my partner recognizes me and we get personalized insights.

**Acceptance Criteria:**

**Given** the user has just registered
**When** they enter their Date of Birth
**Then** the system should automatically calculate and display their Zodiac sign

**Given** the user is on the profile screen
**When** they tap to upload an avatar
**Then** they can select a photo from the gallery or take a new one
**And** crop it to a circle

**Given** the user prefers English
**When** they select "English" in language settings
**Then** the app interface should switch to English immediately

### Story 1.3: Love Contract Flow

As a User,
I want to review and sign the Love Contract,
So that we establish our relationship rules in a fun way.

**Acceptance Criteria:**

**Given** the user is in the onboarding flow
**When** they reach the Love Contract step
**Then** they should see a predefined list of humorous clauses (e.g., "No going to bed angry")

**Given** the user wants to customize
**When** they tap "Edit Clauses"
**Then** they can add a new custom rule or remove an existing one

**Given** the user is ready to commit
**When** they sign (tap and hold) the contract
**Then** the contract should be marked as "Signed by User" and waiting for Partner

### Story 1.4: Partner Invitations & Linking

As a User,
I want to invite my partner via a link,
So that we can be paired in the app.

**Acceptance Criteria:**

**Given** the user has signed the contract
**When** they tap "Invite Partner"
**Then** the system should generate a unique dynamic link (e.g., cupid.app/pair/xyz)
**And** open the native share sheet to send it via messaging apps

**Given** the partner clicks the invite link
**When** they open the app
**Then** they should be taken directly to the Pairing Confirmation screen linked to the inviter

**Given** the couple is pairing
**When** they select "Couple Type" (Long Distance / Same City)
**Then** the app should configure initial default settings based on that type

### Story 1.5: Fingerprint Vow (Pairing Confirmation)

As a User,
I want to confirm pairing via biometrics,
So that the commitment feels official and secure.

**Acceptance Criteria:**

**Given** both users have signed the contract and are on the pairing screen
**When** they place their finger on the fingerprint icon (biometric prompt)
**Then** the system should validate the biometric via Local Authentication
**And** trigger a "Boom" success animation when successful
**And** unlock the main Dashboard

## Epic 2: Radical Transparency Communication

**Goal:** Enable real-time communication with the unique "Typing Ghost" capability to see deleted thoughts.

### Story 2.1: Chat Interface & History

As a User,
I want to view my chat history and interface,
So that I can see past conversations and start new ones.

**Acceptance Criteria:**

**Given** the user is on the dashboard
**When** they tap the Chat tab
**Then** they should see the chat interface with their partner
**And** load the last 20 messages from local cache

**Given** there is no history
**When** the chat opens
**Then** show a friendly empty state "Start the conversation!"

### Story 2.2: Sending Messages (Text/Media)

As a User,
I want to send text and images,
So that I can express myself to my partner.

**Acceptance Criteria:**

**Given** the user types a message
**When** they tap Send
**Then** the message should appear immediately in the chat list (optimistic UI)
**And** be sent to the server via WebSocket

**Given** the user selects an image
**When** they send it
**Then** it should upload to storage and appear in the chat as a preview

### Story 2.3: Typing Ghost Mechanics (Real-time Stream)

As a User,
I want to see what my partner is typing in real-time within the ghost bubble,
So that I can feel connected to their thoughts even before they send.

**Acceptance Criteria:**

**Given** Typing Ghost is enabled by both parties
**When** the partner types a character
**Then** that character should appear on the user's screen in the "Ghost Bubble" with <200ms latency

**Given** the partner deletes text
**When** they backspace
**Then** the deleted text should remain visible but become faded and strikethrough (Ghost Text)

**Given** the partner sends the message
**When** the message is sent
**Then** the Ghost Bubble should disappear and be replaced by the final message

### Story 2.4: Typing Ghost Controls & Consent

As a User,
I want to toggle Typing Ghost and control consent,
So that I feel comfortable with the level of transparency.

**Acceptance Criteria:**

**Given** the user wants to enable Typing Ghost
**When** they toggle the feature
**Then** a request should be sent to the partner
**And** the feature activates ONLY if the partner also approves/toggles it ON

**Given** either user toggles it OFF
**When** the switch is flipped
**Then** real-time streaming should stop immediately for BOTH users

## Epic 3: Daily Engagement & Habits

**Goal:** Foster daily interaction through synchronized habits (Alarm, Vibe Check) and playful accountability (Anti-Ghosting).

### Story 3.1: Synced Alarm Clock

As a Couple,
We want to wake up at the same time,
So that we start the day together even if apart.

**Acceptance Criteria:**

**Given** one partner sets an alarm time
**When** they save it
**Then** the other partner receives a request to confirm the time

**Given** the alarm time is reached
**When** it rings
**Then** it should ring on BOTH devices simultaneously (using Push + Local Notification)

**Given** the alarm is ringing
**When** one partner slides to stop
**Then** it keeps ringing until the OTHER partner also slides to stop (or timeout after 5 mins)

### Story 3.2: Daily Vibe Check

As a User,
I want to update my mood quickly,
So that my partner knows how I feel without me having to text.

**Acceptance Criteria:**

**Given** it is a new day
**When** the user opens the app triggers a "Vibe Check" notification
**Then** they see a mood picker (Happy, Sad, Angry, Horny, Tired)

**Given** the user selects a mood
**When** they confirm
**Then** the partner receives a notification "Bae is feeling [Mood]"
**And** the mood is logged in the history graph

### Story 3.3: Anti-Ghosting Configuration

As a Couple,
We want to set rules for response time,
So that we avoid silent treatment and maintain communication standards.

**Acceptance Criteria:**

**Given** the couple is in settings
**When** they select "Anti-Ghosting Protocol"
**Then** they can set a "Ghost Timeout" (e.g., 10 mins after 'Seen')
**And** choose a "Penalty" (Emoji Storm, Noise, None)

**Given** one partner changes the config
**When** they save
**Then** the other partner must approve the change

### Story 3.4: Anti-Ghosting Triggers (Emoji Storm)

As a User,
I want to trigger an Emoji Storm when my partner ghosts me,
So that I get their attention in a playful, slightly toxic way.

**Acceptance Criteria:**

**Given** the "Ghost Timeout" has passed since the last message was 'Seen'
**When** the timer expires
**Then** the "Storm" button becomes active for the sender

**Given** the sender taps "Storm"
**When** the action is sent
**Then** the partner's screen should be covered in falling emojis (e.g., 👻 or 🔪) for 5 seconds
**And** play a sound effect override (if permission granted)

## Epic 4: Digital Intimacy & Memories

**Goal:** Create a shared space for emotional investment (Love Pet) and secure memory storage.

### Story 4.1: Love Pet Adoption

As a Couple,
We want to adopt a virtual pet,
So that we have a shared responsibility that grows with our relationship.

**Acceptance Criteria:**

**Given** the couple has been paired for 24 hours
**When** they open the Love Pet tab
**Then** they see an "Adoption Center" with options (Cat, Dog, Bunny)

**Given** they select a pet
**When** they name it and confirm
**Then** the pet appears on the dashboard of BOTH users

### Story 4.2: Love Pet Evolution & Status

As a User,
I want the pet to react to our relationship status,
So that I can visualize our connection health.

**Acceptance Criteria:**

**Given** the couple interacts frequently (chat, vibe check)
**When** they open the app
**Then** the pet should be "Happy" and perform a dance animation

**Given** the couple ignores each other for > 24 hours
**When** they open the app
**Then** the pet should differ "Sad" or "Sick" appearance

**Given** they reach a milestone (e.g., 1000 interactions)
**When** it happens
**Then** the pet should "Level Up" visually (grow bigger, new accessories)

### Story 4.3: Private Gallery (Encrypted)

As a User,
I want to store intimate photos securely,
So that only I can see them on my device.

**Acceptance Criteria:**

**Given** the user is in Private Gallery
**When** they add a photo
**Then** the app should encrypt it with AES-256 using a local key stored in the Secure Element
**And** show a "Locked" indicator

**Given** the user wants to view the photo
**When** they tap it
**Then** the app must prompt for Biometric Authentication (FaceID/TouchID) before decrypting and displaying

**Given** the user tries to take a screenshot
**When** the photo is open
**Then** the app should detect it (iOS `userInfo`) and show a "Naughty!" overlay or warning (if feasible)

### Story 4.4: Love Timeline

As a User,
I want to see our relationship milestones,
So that we can look back on our journey.

**Acceptance Criteria:**

**Given** a significant event occurs (Pairing, 1 Month Anniversary)
**When** the date arrives
**Then** the system should automatically add a card to the Timeline

**Given** the user wants to add a manual memory
**When** they tap "+ Memory"
**Then** they can add a Title, Date, and Photo to the timeline

## Epic 5: Shared Future (Finance)

**Goal:** Provide tools for shared financial goal setting (Dream Jar) and basic expense tracking.

### Story 5.1: Dream Jar Management

As a Couple,
We want to set a savings goal,
So that we can save for a trip or item together.

**Acceptance Criteria:**

**Given** the couple is on the Finance tab
**When** they tap "New Dream Jar"
**Then** they can enter a Name, Target Amount, and Deadline

**Given** the jar is created
**When** they view it
**Then** it should show 0% progress initially

### Story 5.2: Contributing to Dream Jar & Expenses

As a User,
I want to log a contribution or an expense,
So that we track our progress towards our goals.

**Acceptance Criteria:**

**Given** the user wants to contribute to a Dream Jar
**When** they tap "Add Funds"
**Then** they can enter an amount manually
**And** the progress bar updates immediately

**Given** the user incurs a shared expense
**When** they log it in Expense Manager
**Then** they can select a Category (Food, Date, Travel) and Amount
**And** it is added to the monthly total

## Epic 6: Administration & Privacy Control

**Goal:** Ensure data privacy through granular controls and provide administration capabilities.

### Story 6.1: Data Privacy & Export

As a User,
I want to understand data levels and export my data,
So that I trust the app with my personal information.

**Acceptance Criteria:**

**Given** the user is in Privacy Settings
**When** they view "My Data"
**Then** the app should explain the 3 Data Levels (Device, Encrypted, Raw) visually

**Given** the user requests a data export
**When** they tap "Export All Data"
**Then** the backend should generate a ZIP file of their data (complying with PDPA)
**And** email it to their registered address within 24 hours

### Story 6.2: Admin Configuration Panel

As an Admin,
I want to configure system limits,
So that I can manage load and ensure safety.

**Acceptance Criteria:**

**Given** the admin is logged into the Admin Panel
**When** they toggle "Emoji Storm Global Enable" to OFF
**Then** the feature should be disabled for all users immediately

**Given** the admin wants to limit spam
**When** they set "Max Push per Day" to 20
**Then** the system should cap push notifications for any user exceeding that limit
