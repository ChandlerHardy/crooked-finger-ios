# Notion Pages Structure for Crooked Finger - Updated October 8, 2025

Copy and paste these sections into your Notion workspace.

---

## 📱 Page 1: Crooked Finger - Project Overview

### Status
- **Web App**: ✅ Production (https://crookedfinger.chandlerhardy.com)
- **iOS App**: 🚧 Active Development (Phase 3 Complete - 90% Feature Parity)
- **Backend API**: ✅ Production (https://backend.chandlerhardy.com)
- **Authentication**: ✅ Working (migrated from bcrypt to Argon2)

### Quick Links
- **GitHub Repos**
  - Web/Backend: https://github.com/ChandlerHardy/crooked-finger
  - iOS: https://github.com/ChandlerHardy/crooked-finger-ios
- **Production URLs**
  - Web App: https://crookedfinger.chandlerhardy.com
  - GraphQL API: https://backend.chandlerhardy.com/crooked-finger/graphql
- **Server Access**
  - OCI Server: `ssh ubuntu@150.136.38.166 -i ~/.ssh/ampere.key`
  - Backend Location: `/home/ubuntu/crooked-finger/`

### Current Sprint Focus (October 8, 2025)
1. ✅ **COMPLETE**: Multimodal AI with image analysis
2. ✅ **COMPLETE**: PDF support for pattern creation
3. ✅ **COMPLETE**: Image persistence fixes
4. 🚧 **IN PROGRESS**: Layout bug investigation
5. 📋 **NEXT**: Image reordering for thumbnails
6. 📋 **NEXT**: Port iOS features back to web

---

## 📱 Page 2: iOS Development

### Current Status
🚧 **Phase 3 Complete - Advanced Features In Progress** (October 2025)

**Major Milestone**: iOS app now has 90% feature parity with web app!

### ✅ Phase 1-3 Complete Features

**Core Features**:
- [x] SwiftUI app structure with tab navigation
- [x] Custom GraphQL client (URLSession, no Apollo)
- [x] Pattern Library (fetch, create, delete, update)
- [x] Project Management (full CRUD)
- [x] Create project from pattern
- [x] Pull-to-refresh on all lists
- [x] Error handling with copy-to-clipboard
- [x] Empty state views with custom messaging
- [x] Custom brown/tan theme matching web
- [x] Dark mode support (adaptive colors)
- [x] Haptic feedback on interactions

**Authentication** (Oct 4, 2025):
- [x] Login/Register UI with SwiftUI forms
- [x] JWT token management with UserDefaults
- [x] AuthViewModel with full auth flow
- [x] Protected navigation (LoginView ↔ TabNavigationView)
- [x] Logout functionality in Settings
- [x] Backend migrated from bcrypt to Argon2

**AI & Chat** (Oct 3-8, 2025):
- [x] AI Chat Interface with Gemini integration
- [x] Multi-model support (Pro, Flash Preview, Flash, Flash-Lite)
- [x] Chat history persistence
- [x] Project-specific conversations
- [x] **Multimodal AI with image analysis**
- [x] **Chat images with tap-to-enlarge fullscreen viewer**
- [x] **Optimized zoom/pan performance**
- [x] Markdown rendering in chat messages
- [x] Message animations with fade-in effects

**Pattern Creation**:
- [x] Manual pattern entry form
- [x] **AI Assistant tab for pattern creation**
- [x] **Image upload (camera, photo library, PDFs)**
- [x] **PDF to image conversion with PDFKit**
- [x] **AI analyzes images and auto-populates pattern fields**
- [x] **Pattern images automatically saved from AI chat**
- [x] Notation translation (AI generates instructions)
- [x] YouTube transcript extraction
- [x] Thumbnail download and storage

**Image Management**:
- [x] **MediaPickerView (camera/photo library/browse files)**
- [x] **PDF support with multi-page conversion**
- [x] **Multiple images per pattern/project**
- [x] **Mix PDFs and photos in any order**
- [x] **Image persistence bug fixed (combine existing + new)**
- [x] Image compression (JPEG, 0.8 quality, 1920px max)
- [x] Base64 encoding for GraphQL
- [x] **Comprehensive debug logging**

**UI/UX Polish**:
- [x] Card-style list items with borders
- [x] Loading states and animations
- [x] Professional image viewer (zoom/pan/swipe)
- [x] Notation/instructions toggle view
- [x] Editable pattern notation and instructions
- [x] Project status badges
- [x] Notes section for projects

### ⚠️ Known Issues

**Layout Bug** (Active Investigation - Oct 8, 2025)
- **Issue**: Instructions render under title after adding images
- **Workaround**: Restart app
- **Status**: Tried 6 different approaches, all unsuccessful
- **Details**: See CLAUDE.md "Known Issues & Debugging Notes"

### 🚧 Phase 4 - In Progress (Oct 5-20, 2025)

**Active Development**:
- [ ] Fix layout bug (PatternDetailView)
- [ ] Image reordering for thumbnail selection
- [ ] Preserve state during orientation changes

**Planned**:
- [ ] Biometric authentication (Face ID/Touch ID)
- [ ] JWT token refresh mechanism
- [ ] Keychain storage for sensitive data
- [ ] AI Usage Dashboard
- [ ] Pattern sharing (Share sheet, PDF export)

### 📋 Backlog

**Phase 5 - Offline-First** (Oct 21 - Nov 10):
- SwiftData as single source of truth
- Intelligent sync engine
- Background sync with BGTaskScheduler
- Network resilience and offline mode

**Phase 6 - Native iOS Features** (Nov 11 - Dec 5):
- Widgets (stitch counter, active project)
- Siri Shortcuts
- Apple Watch companion app
- Live Activities (Dynamic Island)
- iPad optimizations (Split View, Slide Over)

**Phase 7 - App Store Launch** (Dec 6 - Jan 15, 2026):
- Performance optimization
- Accessibility compliance
- Testing (unit, UI, integration)
- TestFlight beta
- App Store submission

---

## 🌐 Page 3: Web Development

### Current Status
✅ **Production Deployed** (https://crookedfinger.chandlerhardy.com)

### ✅ Completed Features
- [x] Next.js 15 + TypeScript + Tailwind
- [x] Apollo GraphQL client
- [x] AI Chat with multi-model Gemini system
- [x] YouTube transcript extraction
- [x] Pattern library with image galleries
- [x] Project management with image galleries
- [x] Professional matplotlib diagram generation
- [x] Professional image viewer (zoom/pan)
- [x] AI usage dashboard with real-time tracking
- [x] Authentication system (migrated to Argon2)

### 📋 Feature Parity Gap (iOS Features to Port)

**High Priority** (iOS has, Web needs):
1. **Pull-to-Refresh Gestures**
   - iOS: ✅ Complete on all list views
   - Web: ❌ Missing
   - Estimated: 1 day

2. **MediaPickerView with PDF Support**
   - iOS: ✅ Camera/Photo Library/Browse Files with PDF conversion
   - Web: ⚠️ Has file upload but no PDF handling
   - Estimated: 2 days

3. **Pattern Creation AI Assistant**
   - iOS: ✅ Dedicated AI Assistant tab with image analysis
   - Web: ⚠️ Has chat but not pattern-specific UI
   - Estimated: 2-3 days

4. **Tap-to-Enlarge Chat Images**
   - iOS: ✅ Fullscreen viewer with optimized zoom/pan
   - Web: ❌ Chat images not interactive
   - Estimated: 1-2 days

5. **Image Auto-Populate from AI**
   - iOS: ✅ Images used in AI chat automatically saved to pattern
   - Web: ❌ Manual upload only
   - Estimated: 1 day

**Medium Priority**:
6. **Haptic Feedback**
   - iOS: ✅ On send, button taps
   - Web: N/A (browser limitation)

7. **Dark Mode** (System)
   - iOS: ✅ Full adaptive color support
   - Web: ❌ Light mode only
   - Estimated: 2 days

8. **Markdown Chat Rendering**
   - iOS: ✅ AttributedString(markdown:)
   - Web: ✅ react-markdown
   - Both complete

### 🚧 Shared Feature Gaps (Both Platforms)

**Missing on Both**:
- [ ] Image reordering for thumbnail selection
- [ ] Pattern sharing (public/private, favorites)
- [ ] Advanced diagram types (amigurumi, garment)
- [ ] PWA/offline mode
- [ ] Collaborative features

---

## 🔧 Page 4: Backend/API

### Current Status
✅ **Production** (https://backend.chandlerhardy.com)

### Infrastructure
- **Server**: Oracle Cloud Infrastructure (OCI)
- **IP**: 150.136.38.166
- **Stack**: FastAPI + Strawberry GraphQL + PostgreSQL 15
- **Deployment**: Docker Compose
- **SSL**: Let's Encrypt (auto-renewed)
- **Password Hashing**: Argon2 (migrated from bcrypt Oct 4, 2025)

### ✅ Working Features
- [x] GraphQL API endpoints
- [x] Multi-model Gemini integration (4 models, 1,600 requests/day)
- [x] **Multimodal image support (types.Part.from_bytes)**
- [x] Pattern/Project CRUD with authentication
- [x] YouTube transcript extraction (RapidAPI)
- [x] Professional diagram generation (matplotlib)
- [x] AI usage tracking
- [x] CORS configuration
- [x] HTTPS with nginx reverse proxy
- [x] Conversation management (project-specific chats)

### 🚧 Recent Improvements (Oct 8, 2025)

**Multimodal AI Support**:
- Added `image_data` parameter to `chatWithAssistantEnhanced` mutation
- Proper Gemini SDK image handling with `types.Part.from_bytes()`
- Enhanced system prompts for pattern extraction
- Support for multiple images per request

**Authentication**:
- ✅ Migrated from bcrypt to Argon2 (Oct 4, 2025)
- Fixed GraphQL context_getter db session handling
- Removed FastAPI Request.user setter issue
- Fully functional login/register

### 📋 Technical Debt
- [ ] Add API versioning
- [ ] Implement proper logging (structured logs)
- [ ] Add monitoring/alerting (Prometheus + Grafana)
- [ ] Database migrations system (Alembic)
- [ ] Add API tests
- [ ] Implement caching layer (Redis)
- [ ] Rate limiting per user
- [ ] Automated database backups

---

## 📊 Page 5: Feature Parity Tracker - UPDATED Oct 8, 2025

### ✅ Full Parity (Both Platforms Complete)

| Feature | iOS | Web | Notes |
|---------|-----|-----|-------|
| Pattern Library | ✅ | ✅ | View, create, delete, update |
| Project Management | ✅ | ✅ | Full CRUD |
| AI Chat Interface | ✅ | ✅ | Multi-model Gemini |
| Chat History | ✅ | ✅ | Persistent conversations |
| Project-Specific Chat | ✅ | ✅ | Contextual AI per project |
| GraphQL Integration | ✅ | ✅ | - |
| Authentication | ✅ | ✅ | JWT with Argon2 |
| Error Handling | ✅ | ✅ | iOS has copy-to-clipboard |
| Empty States | ✅ | ✅ | - |
| Color Scheme | ✅ | ✅ | Brown/tan theme |
| Image Upload | ✅ | ✅ | Camera, library, files |
| Image Viewer | ✅ | ✅ | Zoom/pan gestures |
| Markdown Rendering | ✅ | ✅ | Chat messages |
| YouTube Extraction | ✅ | ✅ | Transcript + thumbnail |
| Notation Translation | ✅ | ✅ | AI generates instructions |

### 📱 iOS-Ahead Features (Web TODO)

| Feature | iOS Status | Web Status | Priority | Effort |
|---------|-----------|------------|----------|--------|
| **Pull-to-Refresh** | ✅ Complete | ❌ Missing | 🟠 High | 1 day |
| **PDF Support** | ✅ Complete | ❌ Missing | 🟠 High | 2 days |
| **Pattern AI Assistant Tab** | ✅ Complete | ⚠️ Partial | 🟠 High | 2-3 days |
| **Multimodal Image Analysis** | ✅ Complete | ❌ Missing | 🟠 High | 2 days |
| **Chat Image Tap-to-Enlarge** | ✅ Complete | ❌ Missing | 🟡 Medium | 1-2 days |
| **Auto-Save Pattern Images** | ✅ Complete | ❌ Missing | 🟡 Medium | 1 day |
| **Native Dark Mode** | ✅ Complete | ❌ Missing | 🟡 Medium | 2 days |
| **Haptic Feedback** | ✅ Complete | N/A | - | - |
| **Optimized Zoom Performance** | ✅ Complete | ⚠️ Good | 🟢 Low | - |

### 🌐 Web-Ahead Features (iOS TODO)

| Feature | Web Status | iOS Status | Priority | Effort |
|---------|------------|-----------|----------|--------|
| AI Usage Dashboard | ✅ Complete | ❌ Missing | 🟢 Low | 2 days |
| Diagram Generation | ✅ Complete | ❌ Missing | 🟢 Low | 3 days |

### 🚧 Both Platforms TODO

| Feature | Priority | Effort | Notes |
|---------|----------|--------|-------|
| Image Reordering | 🟠 High | 2 days | Choose thumbnail |
| Pattern Sharing | 🟡 Medium | 1 week | Public/private, import |
| Advanced Diagrams | 🟢 Low | 2 weeks | Amigurumi, garment |
| Biometric Auth (iOS) | 🟡 Medium | 2 days | Face ID/Touch ID |
| PWA/Offline (Web) | 🟡 Medium | 1 week | Service workers |
| Apple Watch (iOS) | 🟢 Low | 2 weeks | Stitch counter |
| Widgets (iOS) | 🟢 Low | 1 week | Home screen widgets |

---

## 🎯 Page 6: Project Roadmap - UPDATED

### October 2025 - iOS Feature Parity Sprint ✅ COMPLETE

**Completed**:
- ✅ Authentication system (Argon2 migration)
- ✅ AI Chat with multimodal support
- ✅ Pattern creation AI assistant
- ✅ PDF support with conversion
- ✅ Image persistence fixes
- ✅ Optimized image viewer

### November 2025 - Web Catch-Up Sprint 📋 PLANNED

**Goals**: Port iOS-exclusive features to web

**Week 1-2** (Nov 1-14):
- [ ] Pull-to-refresh on pattern/project lists
- [ ] PDF upload and conversion
- [ ] Pattern AI Assistant dedicated UI
- [ ] Multimodal image analysis integration

**Week 3-4** (Nov 15-30):
- [ ] Chat image tap-to-enlarge
- [ ] Auto-save pattern images from AI
- [ ] Dark mode support
- [ ] Image reordering (both platforms)

### December 2025 - Advanced Features Sprint

**Week 1-2** (Dec 1-14):
- [ ] Pattern sharing system (both platforms)
- [ ] Biometric auth (iOS)
- [ ] PWA support (Web)

**Week 3-4** (Dec 15-31):
- [ ] AI Usage Dashboard (iOS)
- [ ] Diagram generation (iOS)
- [ ] Performance optimization (both)

### January 2026 - App Store Prep & Launch

- [ ] TestFlight beta testing
- [ ] App Store assets (screenshots, icons, descriptions)
- [ ] Final bug fixes
- [ ] App Store submission
- [ ] Public launch 🎉

---

## 🔍 Page 7: Technical Documentation - UPDATED

### iOS Implementation Details

**GraphQL Client**
- Custom implementation using URLSession
- No Apollo codegen required
- Location: `Services/GraphQL/GraphQLClient.swift`
- Auth token from UserDefaults (TODO: migrate to Keychain)

**Pattern vs Project Architecture**
Both use same backend `CrochetProject` table, filtered by `notes`:
- **Patterns**: `notes == null` (reusable templates)
- **Projects**: `notes != null` (active work)

**Image Handling Pipeline** (Oct 8, 2025):
```
UIImage → JPEG compression (0.8 quality, 1920px max)
       → Base64 encoding
       → JSON array ["base64str1", "base64str2"]
       → GraphQL mutation
       → Backend storage
       → Retrieval as JSON array
       → Base64 decoding
       → UIImage caching in memory
```

**PDF Support**:
- `PDFDocument(data:)` instead of `PDFDocument(url:)` for security-scoped resources
- `UIGraphicsImageRenderer` for page-to-image conversion
- Each page becomes a separate image
- Works on both simulator and real device

**Multimodal AI**:
- Images sent as base64 JSON array in `imageData` parameter
- Backend converts to `types.Part.from_bytes()`
- Gemini 2.5 Pro model for image analysis
- System prompts enforce NAME:/NOTATION:/INSTRUCTIONS: format

**Important**: Use native Swift dictionaries for GraphQL variables
```swift
// ✅ CORRECT
let variables: [String: Any] = [
    "input": [
        "title": title,
        "imageData": imageService.imagesToJSON(images: images)
    ]
]

// ❌ WRONG - causes "Invalid type in JSON write"
let input = CreateProjectInput(...)
let variables = ["input": try JSONEncoder().encode(input)]
```

### Backend Architecture

**Authentication Flow** (Argon2):
```
1. User registers → Password hashed with Argon2
2. Hash stored in users table
3. User logs in → Password verified with Argon2
4. JWT token generated (expires 7 days)
5. Token sent to client
6. Client includes token in Authorization header
7. Backend validates token on each request
```

**Multi-Model AI System**:
- Gemini 2.5 Pro: 100 requests/day (complex + images)
- Gemini 2.5 Flash Preview: 250 requests/day (latest)
- Gemini 2.5 Flash: 400 requests/day (balanced)
- Gemini 2.5 Flash-Lite: 1,000 requests/day (simple)
- **Total**: 1,600 requests/day

**Image Processing**:
- Accepts base64 JSON array from clients
- Converts to `types.Part.from_bytes()` for Gemini
- Stores as JSON in PostgreSQL `text` field
- Returns as JSON array to clients

### Known Issues & Workarounds

**iOS Layout Bug** (Oct 8, 2025)
- **Issue**: Instructions render under title after adding images
- **Workaround**: Restart app
- **Status**: Active investigation, 6 approaches tried
- **Details**: See CLAUDE.md "Known Issues & Debugging Notes"

**JWT Token Storage** (TODO)
- **Current**: UserDefaults (works but not ideal)
- **Should be**: Keychain (more secure)
- **Priority**: Medium

### Deployment Procedures

**iOS** (TestFlight):
1. Update version in Xcode
2. Archive build
3. Upload to TestFlight
4. Submit for review
5. Distribute to testers

**Web** (Vercel Auto-deploy):
1. Push to `main` branch
2. Vercel auto-deploys
3. Check deployment logs
4. Verify at https://crookedfinger.chandlerhardy.com

**Backend** (Docker on OCI):
1. SSH: `ssh ubuntu@150.136.38.166 -i ~/.ssh/ampere.key`
2. Pull: `cd /home/ubuntu/crooked-finger && git pull`
3. Build: `docker-compose -f docker-compose.backend.yml build backend`
4. Deploy: `docker-compose -f docker-compose.backend.yml up -d backend`
5. Logs: `docker-compose -f docker-compose.backend.yml logs -f backend`

---

## 📋 Page 8: Task Database

Create a Notion database with these properties:

**Properties:**
- **Task** (Title)
- **Platform** (Multi-select): iOS, Web, Backend, Both
- **Status** (Select): 📋 To Do, ⚠️ In Progress, ✅ Done, 🚧 Blocked
- **Priority** (Select): 🔴 Critical, 🟠 High, 🟡 Medium, 🟢 Low
- **Effort** (Select): Hours, 1 day, 2-3 days, 1 week, 2+ weeks
- **Sprint** (Select): October, November, December, Backlog
- **Notes** (Text)

**Current High-Priority Tasks** (October 8, 2025):

| Task | Platform | Status | Priority | Effort | Sprint |
|------|----------|--------|----------|--------|--------|
| Fix layout bug (PatternDetailView) | iOS | ⚠️ In Progress | 🟠 High | 2-3 days | October |
| Add image reordering | Both | 📋 To Do | 🟠 High | 2-3 days | October |
| Port PDF support to web | Web | 📋 To Do | 🟠 High | 2 days | November |
| Port pull-to-refresh to web | Web | 📋 To Do | 🟠 High | 1 day | November |
| Port Pattern AI Assistant UI to web | Web | 📋 To Do | 🟠 High | 2-3 days | November |
| Add multimodal AI to web | Web | 📋 To Do | 🟠 High | 2 days | November |
| Migrate iOS tokens to Keychain | iOS | 📋 To Do | 🟡 Medium | 1 day | November |
| Add dark mode to web | Web | 📋 To Do | 🟡 Medium | 2 days | November |
| AI Usage Dashboard on iOS | iOS | 📋 To Do | 🟢 Low | 2 days | December |

---

## 📅 Page 9: Development Log

**Recent Major Sessions:**

### October 8, 2025 - Multimodal AI & Image Persistence
**Platform**: Both (iOS + Backend)
**Status**: ✅ Deployed

**iOS Improvements**:
- Fixed critical image persistence bug (combine existing + new images)
- Added MediaPickerView to pattern/project detail views
- Fixed PDF security-scoped resource access on device
- Optimized Base64ImageViewer with separate ZoomableImageView
- Added tap-to-enlarge for chat images
- Pattern images from AI auto-saved to gallery
- Improved title extraction with more header variations

**Backend Improvements**:
- Added `image_data` parameter to chatWithAssistantEnhanced
- Implemented types.Part.from_bytes() for Gemini SDK
- Enhanced pattern extraction prompts

**Commits**:
- iOS: `28a5bbc`, `2f4fbcc`, `5db6d1a`
- Backend: `05af74f4`

**Known Issue Discovered**:
- Layout bug in PatternDetailView (instructions under title)
- Documented in CLAUDE.md with 6 attempted fixes

### October 4, 2025 - Authentication Complete
**Platform**: Both
**Status**: ✅ Deployed

- Migrated backend from bcrypt to Argon2
- Fixed GraphQL context_getter db session
- iOS login/register/logout fully functional
- JWT token management working

**Commits**:
- Backend: Multiple commits for Argon2 migration
- iOS: Auth UI and flow implementation

### October 3, 2025 - AI Chat Integration
**Platform**: iOS
**Status**: ✅ Deployed

- Full chat interface with Gemini integration
- Multi-model support
- Markdown rendering
- Chat history and project-specific conversations

---

Copy these updated sections into Notion. The feature parity gap has narrowed significantly - iOS is now ahead in several areas and it's time to port those features back to web!
