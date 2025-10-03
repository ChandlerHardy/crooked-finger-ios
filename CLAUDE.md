# Crooked Finger iOS - Project Context

## Project Overview
Native iOS port of the Crooked Finger web application - a crochet pattern assistant with AI-powered pattern translation, diagram generation, and project management.

**Parent Web App**: `/Users/chandlerhardy/repos/crooked-finger`

## Tech Stack
- **Platform**: iOS 17+ (SwiftUI)
- **Language**: Swift 6
- **Architecture**: MVVM + SwiftUI
- **Backend**: Shared GraphQL API (FastAPI + Strawberry)
- **AI**: Google Gemini (multi-model system via backend)
- **Networking**: Apollo GraphQL Client (Swift)
- **Local Storage**: SwiftData / Core Data
- **Image Handling**: Kingfisher for caching

## Backend Integration
**Shared Backend URL**: `https://backend.chandlerhardy.com/crooked-finger/graphql`

### GraphQL Endpoints:
- **Production**: `https://backend.chandlerhardy.com/crooked-finger/graphql`
- **Local Dev**: `http://localhost:8001/crooked-finger/graphql`

### Key Backend Features:
1. **Pattern Translation** - Convert crochet notation to instructions
2. **AI Chat** - Multi-model Gemini assistant (Pro, Flash Preview, Flash, Flash-Lite)
3. **Diagram Generation** - matplotlib-based crochet charts (PNG/SVG)
4. **YouTube Transcripts** - Extract patterns from video tutorials
5. **Pattern Library** - Save, browse, manage patterns
6. **Project Management** - Track projects with images and notes

## Core iOS Features (Phase 1)
1. ✅ **Home Screen** - Dashboard with recent projects and conversations
2. ✅ **AI Chat Interface** - Chat with Gemini assistant about crochet patterns
3. ✅ **Pattern Library** - Browse, search, save patterns
4. ✅ **Project Management** - Create and track crochet projects
5. ✅ **Image Viewer** - View pattern diagrams and project photos
6. ✅ **Settings** - User preferences and app configuration

## Phase 2 Features (Future)
- Offline mode with local pattern storage
- Camera integration for progress photos
- Push notifications for project reminders
- Pattern sharing with other users
- Stitch counter widget
- Apple Watch companion app

## Project Structure
```
Crooked Finger iOS/
├── App/
│   └── Crooked_Finger_iOSApp.swift          # App entry point
├── Views/
│   ├── Home/
│   │   └── HomeView.swift                    # Dashboard
│   ├── Chat/
│   │   ├── ChatView.swift                    # AI chat interface
│   │   └── MessageRowView.swift              # Chat message cells
│   ├── Patterns/
│   │   ├── PatternLibraryView.swift          # Pattern browsing
│   │   ├── PatternDetailView.swift           # Pattern detail page
│   │   └── PatternCardView.swift             # Pattern grid item
│   ├── Projects/
│   │   ├── ProjectsView.swift                # Projects list
│   │   ├── ProjectDetailView.swift           # Project detail page
│   │   └── ProjectCardView.swift             # Project grid item
│   ├── Settings/
│   │   └── SettingsView.swift                # App settings
│   └── Components/
│       ├── Navigation/
│       │   └── TabNavigationView.swift       # Main tab navigation
│       └── Shared/
│           ├── ImageViewerView.swift         # Zoom/pan image viewer
│           └── LoadingView.swift             # Loading states
├── ViewModels/
│   ├── ChatViewModel.swift                   # Chat logic
│   ├── PatternViewModel.swift                # Pattern management
│   ├── ProjectViewModel.swift                # Project management
│   └── AIUsageViewModel.swift                # AI usage tracking
├── Models/
│   ├── Pattern.swift                         # Pattern data model
│   ├── Project.swift                         # Project data model
│   ├── ChatMessage.swift                     # Chat message model
│   └── Conversation.swift                    # Chat conversation model
├── Services/
│   ├── GraphQL/
│   │   ├── ApolloClient.swift                # GraphQL client setup
│   │   ├── Queries.graphql                   # GraphQL queries
│   │   └── Mutations.graphql                 # GraphQL mutations
│   ├── AIService.swift                       # AI assistant integration
│   ├── PatternService.swift                  # Pattern management
│   └── StorageService.swift                  # Local data persistence
├── Utilities/
│   ├── Extensions/
│   │   ├── String+Extensions.swift           # String helpers
│   │   └── View+Extensions.swift             # SwiftUI view helpers
│   └── Constants.swift                       # App constants
└── Assets.xcassets/                          # Images, colors, icons

Crooked Finger iOSTests/
└── Unit tests

Crooked Finger iOSUITests/
└── UI tests
```

## Development Guidelines
- **SwiftUI First**: Use SwiftUI for all UI components
- **MVVM Pattern**: ViewModels manage business logic, Views are declarative
- **Async/Await**: Use modern Swift concurrency for network calls
- **Type Safety**: Leverage Swift's strong typing system
- **Error Handling**: Graceful error states with user-friendly messages
- **iOS HIG**: Follow Apple's Human Interface Guidelines
- **Accessibility**: Support VoiceOver and Dynamic Type

## Key Differences from Web App
1. **Navigation**: Tab bar instead of sidebar navigation
2. **Storage**: SwiftData/Core Data for local persistence (vs localStorage)
3. **Images**: Kingfisher for caching (vs Next.js Image)
4. **State Management**: SwiftUI @State/@Observable (vs React hooks)
5. **Routing**: NavigationStack (vs Next.js routing)

## Implementation Status
### ✅ Phase 1 (MVP) - COMPLETED:
1. ✅ Project structure setup
2. ✅ GraphQL client integration (lightweight URLSession-based)
3. ✅ Basic navigation (TabView with 5 tabs)
4. ✅ Home screen with mock data
5. ✅ Chat interface with FULL backend integration
6. ✅ Pattern library (list view with mock data)
7. ✅ Project list view (with mock data)
8. ✅ Swift packages added (Apollo iOS, Kingfisher)

### 🔄 Phase 2 - IN PROGRESS:
1. ✅ ChatViewModel with backend integration
2. ✅ Pattern detail pages (UI complete, mock data)
3. ✅ Project detail pages (UI complete, mock data)
4. ✅ Settings screen (basic UI)
5. ⏳ PatternViewModel with backend integration
6. ⏳ ProjectViewModel with backend integration
7. ⏳ AI Usage dashboard integration
8. ⏳ Image viewer with zoom/pan
9. ⏳ Local data persistence (SwiftData)
10. ⏳ Pull-to-refresh and empty states

### Phase 3 - Week 3+:
1. YouTube integration (GraphQL ops ready)
2. Offline mode with sync
3. Camera integration for project photos
4. Push notifications
5. Polish and animations
6. User authentication

## Environment Configuration
Create `Config.swift` for environment variables:
```swift
enum APIConfig {
    static let graphqlURL = "https://backend.chandlerhardy.com/crooked-finger/graphql"
    static let isProduction = true
}
```

## Dependencies (Swift Package Manager)
- **Apollo iOS** - GraphQL client
- **Kingfisher** - Image caching
- **SwiftUI Introspect** (optional) - UIKit interop

## Testing Strategy
- **Unit Tests**: ViewModels, Services, Models
- **UI Tests**: Critical user flows (chat, pattern save, project creation)
- **Manual Testing**: Device testing on iPhone/iPad

## Notes
- Reuse existing GraphQL schema from web app
- Backend is already deployed and tested
- Focus on native iOS UX patterns (swipe actions, haptics, etc.)
- Consider iPad multitasking support

---
*Last Updated: October 2025 - iOS Port Initialization*
