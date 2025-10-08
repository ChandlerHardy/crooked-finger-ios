# Notion Pages Structure for Crooked Finger

Copy and paste these sections into your Notion workspace.

---

## 📱 Page 1: Crooked Finger - Project Overview

### Status
- **Web App**: ✅ Production (https://crookedfinger.chandlerhardy.com)
- **iOS App**: ⚠️ Development (Backend Integration Complete)
- **Backend API**: ✅ Production (https://backend.chandlerhardy.com)
- **Authentication**: 🚧 Blocked (bcrypt library bug)

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

### Current Sprint Focus
1. 🚧 **BLOCKED**: Fix backend bcrypt library bug
2. 📋 **NEXT**: Port AI Chat to iOS
3. 📋 **NEXT**: Implement authentication on web app

---

## 📱 Page 2: iOS Development

### Current Status
✅ **Backend Integration Complete** (October 2025)

### ✅ Completed Features
- [x] SwiftUI app structure with tab navigation
- [x] Custom GraphQL client (URLSession, no Apollo)
- [x] Pattern Library (fetch, create, delete)
- [x] Project Management (fetch, create, update, delete)
- [x] Create project from pattern
- [x] Pull-to-refresh on lists
- [x] Error handling with copy-to-clipboard
- [x] Empty state views
- [x] Brown/tan color scheme matching web
- [x] Authentication UI (login/register) - **DISABLED**

### ⚠️ Known Issues

**Authentication Disabled**
- **Why**: Backend bcrypt library bug on production server
- **Error**: "password cannot be longer than 72 bytes"
- **Impact**: Full auth system built but commented out
- **Files affected**:
  - `GraphQLClient.swift` lines 53-63 (auth header)
  - Backend `mutations.py` (auth checks)
- **Action required**: Fix bcrypt on OCI server, then uncomment auth code

### 🚧 Next Steps (Priority Order)

**High Priority**
1. **AI Chat Interface**
   - Port web chat UI to SwiftUI
   - Integrate with Gemini multi-model API
   - Add chat history persistence
   - Estimated: 2-3 days

2. **Re-enable Authentication**
   - Requires: Backend bcrypt fix
   - Uncomment auth in GraphQLClient.swift
   - Update app entry point to show LoginView
   - Test end-to-end auth flow
   - Estimated: 1 day (after backend fix)

**Medium Priority**
3. **YouTube Integration**
   - Video URL input
   - Transcript extraction via backend API
   - Save extracted patterns to library
   - Estimated: 2 days

4. **Professional Image Viewer**
   - Zoom/pan gestures
   - Pinch to zoom
   - Double-tap to reset
   - Gallery navigation
   - Estimated: 2-3 days

**Low Priority**
5. **Pattern Diagram Display**
   - Show matplotlib-generated charts
   - SVG rendering in SwiftUI
   - Estimated: 2 days

6. **Pattern Sharing**
   - Browse public patterns
   - Import patterns from other users
   - Requires: Backend pattern sharing API
   - Estimated: 3-4 days

### 📋 Technical Debt
- [ ] Add unit tests for ViewModels
- [ ] Add integration tests for GraphQL client
- [ ] Implement proper logging system
- [ ] Add analytics/crash reporting
- [ ] Optimize image caching

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

### 🚧 Next Steps (Priority Order)

**High Priority**
1. **Authentication System**
   - Requires: Backend bcrypt fix
   - Add login/register UI
   - JWT token storage
   - Protected routes
   - Estimated: 2-3 days

2. **Pattern Sharing**
   - Public pattern browsing
   - Import from other users
   - Favorites/bookmarks
   - Requires: Backend sharing API
   - Estimated: 3-4 days

**Medium Priority**
3. **Pull-to-Refresh**
   - Add to pattern/project lists
   - Match iOS UX
   - Estimated: 1 day

4. **Dark Mode Support**
   - System color scheme detection
   - Match iOS native dark mode
   - Estimated: 2 days

**Low Priority**
5. **Advanced Diagram Types**
   - Amigurumi diagrams
   - Garment pattern charts
   - Complex stitch patterns
   - Estimated: 5-7 days

### 📋 Technical Debt
- [ ] Add proper TypeScript types for all GraphQL operations
- [ ] Implement error boundary components
- [ ] Add E2E tests (Playwright)
- [ ] Optimize bundle size
- [ ] Add PWA support for offline mode

---

## 🔧 Page 4: Backend/API

### Current Status
✅ **Production** (https://backend.chandlerhardy.com)

### Infrastructure
- **Server**: Oracle Cloud Infrastructure (OCI)
- **IP**: 150.136.38.166
- **Stack**: FastAPI + Strawberry GraphQL + PostgreSQL
- **Deployment**: Docker Compose
- **SSL**: Let's Encrypt (auto-renewed)

### ✅ Working Features
- [x] GraphQL API endpoints
- [x] Multi-model Gemini integration (4 models, 1,600 requests/day)
- [x] Pattern/Project CRUD (authentication disabled)
- [x] YouTube transcript extraction
- [x] Professional diagram generation (matplotlib)
- [x] AI usage tracking
- [x] CORS configuration
- [x] HTTPS with nginx reverse proxy

### 🚧 Critical Issues

**1. bcrypt Library Bug** 🔴 BLOCKING
- **Symptom**: "password cannot be longer than 72 bytes"
- **Impact**: Cannot hash OR verify passwords
- **Affected**: Both login and registration
- **Tested**: Even simple passwords like "debug" fail
- **Current Workaround**:
  - Auth checks commented out in `mutations.py`
  - Allow null `user_id` in database
  - All marked with TODO comments
- **Action Required**:
  1. SSH to OCI server
  2. Update bcrypt/passlib libraries
  3. Test with simple password
  4. Re-enable auth checks in code
  5. Deploy updates
- **Priority**: 🔴 CRITICAL

### 🚧 Next Steps

**High Priority**
1. **Fix bcrypt Library**
   - Update Python dependencies
   - Test password hashing/verification
   - Re-enable auth checks
   - Deploy to production
   - Estimated: 1 day

2. **Implement Pattern Sharing API**
   - Public/private pattern flags
   - Pattern discovery endpoints
   - Import pattern mutation
   - Estimated: 2-3 days

**Medium Priority**
3. **Add Rate Limiting**
   - Prevent API abuse
   - Per-user quotas
   - Estimated: 1-2 days

4. **Database Backups**
   - Automated daily backups
   - Backup retention policy
   - Restore testing
   - Estimated: 1 day

**Low Priority**
5. **API Documentation**
   - GraphQL schema documentation
   - Example queries/mutations
   - Authentication guide
   - Estimated: 2 days

### 📋 Technical Debt
- [ ] Add API versioning
- [ ] Implement proper logging (structured logs)
- [ ] Add monitoring/alerting (Prometheus + Grafana?)
- [ ] Database migrations system
- [ ] Add API tests
- [ ] Implement caching layer (Redis)

---

## 📊 Page 5: Feature Parity Tracker

### ✅ Implemented on Both Platforms

| Feature | iOS | Web | Notes |
|---------|-----|-----|-------|
| Pattern Library | ✅ | ✅ | View, create, delete |
| Project Management | ✅ | ✅ | Full CRUD |
| GraphQL Integration | ✅ | ✅ | - |
| Error Handling | ✅ | ✅ | iOS has copy-to-clipboard |
| Empty States | ✅ | ✅ | - |
| Color Scheme | ✅ | ✅ | Brown/tan theme |

### 🌐 Web-Only Features (TODO for iOS)

| Feature | Status | Priority | Estimated Effort |
|---------|--------|----------|------------------|
| AI Chat Interface | 📋 Planned | High | 2-3 days |
| YouTube Transcript Extraction | 📋 Planned | Medium | 2 days |
| Pattern Diagram Display | 📋 Planned | Low | 2 days |
| Professional Image Viewer | 📋 Planned | Medium | 2-3 days |
| AI Usage Dashboard | 📋 Planned | Low | 1-2 days |
| Pattern Sharing | 📋 Planned | Medium | 3-4 days |

### 📱 iOS-Only Features (TODO for Web)

| Feature | Status | Priority | Estimated Effort |
|---------|--------|----------|------------------|
| Pull-to-Refresh | 📋 Planned | Medium | 1 day |
| Native Dark Mode | 📋 Planned | Medium | 2 days |
| SwiftUI Navigation | ✅ Complete | - | - |

### 🚧 Blocked Features (Both Platforms)

| Feature | Blocker | Action Required |
|---------|---------|-----------------|
| User Authentication | bcrypt library bug | Fix backend bcrypt |
| User-Specific Data | Authentication | Fix auth first |
| Pattern Sharing | Authentication + API | Fix auth, build API |

---

## 🎯 Page 6: Project Roadmap

### Current Sprint: Backend Integration (October 2025)
✅ **COMPLETE**

**Completed**:
- iOS Pattern/Project integration
- Backend API without auth requirement
- Documentation updates

### Next Sprint: Authentication & Chat

**Phase 1: Fix Authentication** 🔴 CRITICAL
- [ ] Fix bcrypt library on OCI server
- [ ] Re-enable auth checks in backend
- [ ] Re-enable auth in iOS app
- [ ] Implement auth UI on web app
- [ ] End-to-end testing
- **Estimated**: 3-4 days
- **Blocking**: All user-specific features

**Phase 2: iOS AI Chat** (After auth fixed)
- [ ] Port chat interface to SwiftUI
- [ ] Integrate Gemini API
- [ ] Chat history persistence
- [ ] Testing with all 4 models
- **Estimated**: 3-4 days
- **Depends on**: Authentication (optional but recommended)

### Future Sprints

**Sprint: Media Features**
- [ ] iOS YouTube integration
- [ ] iOS image viewer (zoom/pan)
- [ ] Web pull-to-refresh
- [ ] Web dark mode
- **Estimated**: 1-2 weeks

**Sprint: Pattern Sharing**
- [ ] Backend sharing API
- [ ] Public pattern browsing
- [ ] Import/export patterns
- [ ] Favorites system
- **Estimated**: 2 weeks

**Sprint: Advanced Diagrams**
- [ ] Amigurumi chart generation
- [ ] Garment pattern charts
- [ ] Complex stitch patterns
- [ ] Interactive diagram editor
- **Estimated**: 3-4 weeks

---

## 🔍 Page 7: Technical Documentation

### iOS Implementation Details

**GraphQL Client**
- Custom implementation using URLSession
- No Apollo codegen required
- Location: `Services/GraphQL/GraphQLClient.swift`
- Auth token auto-attached when available

**Pattern vs Project Architecture**
Both use same backend `CrochetProject` table, filtered by `notes`:
- **Patterns**: `notes == null` (templates)
- **Projects**: `notes != null` (active work)

**Important**: Use native Swift dictionaries for GraphQL variables
```swift
// ✅ CORRECT
var input: [String: Any?] = ["name": name, "patternText": pattern]
let variables: [String: Any] = ["input": input]

// ❌ WRONG - causes "Invalid type in JSON write"
let input = CreateProjectInput(name: name, pattern: pattern)
let variables = ["input": try JSONEncoder().encode(input)]
```

### Backend Architecture

**Multi-Model AI System**
- Gemini 2.5 Pro: 100 requests/day (complex queries)
- Gemini 2.5 Flash Preview: 250 requests/day (latest features)
- Gemini 2.5 Flash: 400 requests/day (balanced)
- Gemini 2.5 Flash-Lite: 1,000 requests/day (simple queries)
- **Total**: 1,600 requests/day

**Diagram Generation**
- Primary: matplotlib (professional charts)
- Secondary: SVG generators (granny squares)
- Output: Base64 PNG + SVG

### Common Issues & Solutions

**iOS: "Authentication required" error**
- **Status**: Expected - auth is disabled
- **Solution**: Wait for backend bcrypt fix

**iOS: "Invalid type in JSON write"**
- **Cause**: Using JSONEncoder on structs for variables
- **Solution**: Use native dictionaries (see above)

**Web: CORS errors**
- **Cause**: Origin not in CORS_ORIGINS
- **Solution**: Update `.env` on OCI server, restart backend

**Backend: bcrypt errors**
- **Status**: Known bug on production
- **Solution**: Update bcrypt library (see roadmap)

### Deployment Procedures

**iOS** (Not yet released)
1. Update version in Xcode
2. Archive build
3. Upload to TestFlight
4. Submit for review

**Web** (Auto-deploy)
1. Push to `main` branch
2. Vercel auto-deploys
3. Check deployment logs

**Backend**
1. SSH to OCI: `ssh ubuntu@150.136.38.166 -i ~/.ssh/ampere.key`
2. Update code: `cd /home/ubuntu/crooked-finger && git pull`
3. Rebuild: `docker-compose -f docker-compose.backend.yml build backend`
4. Deploy: `docker-compose -f docker-compose.backend.yml up -d backend`
5. Check logs: `docker-compose -f docker-compose.backend.yml logs -f backend`

---

## 📋 Page 8: Task Database

Create a Notion database with these properties:

**Properties:**
- **Task** (Title): Task name
- **Platform** (Multi-select): iOS, Web, Backend, Both
- **Status** (Select): 📋 To Do, ⚠️ In Progress, ✅ Done, 🚧 Blocked
- **Priority** (Select): 🔴 Critical, 🟠 High, 🟡 Medium, 🟢 Low
- **Effort** (Select): 1 day, 2-3 days, 1 week, 2+ weeks
- **Blocker** (Text): What's blocking this task
- **Sprint** (Select): Current, Next, Future
- **Assignee** (Person): Who's working on it
- **Notes** (Text): Additional details

**Example Entries:**

| Task | Platform | Status | Priority | Effort | Blocker |
|------|----------|--------|----------|--------|---------|
| Fix bcrypt library | Backend | 📋 To Do | 🔴 Critical | 1 day | - |
| Re-enable iOS auth | iOS | 🚧 Blocked | 🟠 High | 1 day | bcrypt fix |
| Add web auth UI | Web | 🚧 Blocked | 🟠 High | 2-3 days | bcrypt fix |
| Port AI chat to iOS | iOS | 📋 To Do | 🟠 High | 2-3 days | - |
| YouTube on iOS | iOS | 📋 To Do | 🟡 Medium | 2 days | - |
| Image viewer iOS | iOS | 📋 To Do | 🟡 Medium | 2-3 days | - |
| Pattern sharing API | Backend | 📋 To Do | 🟡 Medium | 2-3 days | Auth fix |
| Web dark mode | Web | 📋 To Do | 🟡 Medium | 2 days | - |
| Web pull-to-refresh | Web | 📋 To Do | 🟡 Medium | 1 day | - |

---

## 📅 Page 9: Development Log

Create a Notion database to track daily development sessions:

**Properties:**
- **Date** (Date): Session date
- **Platform** (Multi-select): iOS, Web, Backend, Both
- **Summary** (Title): Brief description
- **Details** (Text): Full session notes
- **Commits** (Text): Commit hashes
- **Status** (Select): ✅ Deployed, 🚧 In Progress, 📋 Documented

**Recent Entries:**

### October 7, 2025 - UI Polish & Backend Improvements
**Platform**: Both
**Status**: ✅ Deployed
**Commits**:
- Backend: `d535ab54`, `f101a15d`
- iOS: `8d6cbab`, `8658f0f`

**Backend Improvements:**
- Fixed YouTube pattern parsing with improved regex (lookahead patterns)
- Fixed instruction duplication bug
- Fixed title overflow issue (entire pattern in NAME field)
- Added conversation_id filtering to chatMessages query
- Added AIModelConfig database model for persisting AI settings

**iOS Improvements:**
- Added notation/instructions toggle for patterns
- Reduced spacing in project detail view
- Optimized image gallery padding
- Updated CLAUDE.md with recent improvements

---

Copy these sections into Notion and customize as needed!
