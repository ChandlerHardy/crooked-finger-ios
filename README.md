# Crooked Finger iOS

Native iOS app for **Crooked Finger** - a crochet pattern assistant with AI-powered pattern translation, diagram generation, and project management.

## Features

- 🤖 **AI Chat Assistant** - Powered by Google Gemini multi-model system
- 📚 **Pattern Library** - Save, browse, and manage crochet patterns
- 📁 **Project Management** - Track crochet projects with notes and status
- 🎨 **Diagram Generation** - Professional matplotlib-based crochet charts
- 📺 **YouTube Integration** - Extract patterns from tutorial videos
- 🌓 **Dark Mode** - Beautiful warm theme in light and dark modes

## Tech Stack

- **Platform**: iOS 17+
- **Language**: Swift 6
- **UI Framework**: SwiftUI
- **Architecture**: MVVM + @Observable
- **Backend**: Shared GraphQL API (FastAPI + Strawberry)
- **AI**: Google Gemini (via backend)
- **Networking**: Custom GraphQL client (URLSession-based)
- **Dependencies**: Apollo iOS, Kingfisher

## Backend

This app connects to the same backend as the web app:
- **Production**: `https://backend.chandlerhardy.com/crooked-finger/graphql`
- **Local Dev**: `http://localhost:8001/crooked-finger/graphql`

See the main [Crooked Finger repo](https://github.com/ChandlerHardy/crooked-finger) for backend setup.

## Getting Started

### Prerequisites

- macOS 14+ (Sonoma or later)
- Xcode 15+
- iOS 17+ SDK

### Installation

1. Clone the repository:
```bash
git clone https://github.com/ChandlerHardy/crooked-finger-ios.git
cd crooked-finger-ios
```

2. Open in Xcode:
```bash
open "Crooked Finger iOS.xcodeproj"
```

3. The Swift Package dependencies (Apollo iOS, Kingfisher) should resolve automatically. If not:
   - Go to **File → Packages → Resolve Package Versions**

4. Select a simulator (iPhone 15, 16, 17, etc.)

5. Build and run (⌘R)

### Configuration

The app uses the production backend by default. To use a local backend:

1. Open `Crooked Finger iOS/Utilities/Constants.swift`
2. Change `currentGraphqlURL` to point to `localGraphqlURL` in the `APIConfig` enum

```swift
#if DEBUG
static let currentGraphqlURL = localGraphqlURL  // Use local backend
#else
static let currentGraphqlURL = graphqlURL       // Use production
#endif
```

## Project Structure

```
Crooked Finger iOS/
├── App/                    # App entry point
├── Models/                 # Data models
│   ├── Pattern.swift
│   ├── Project.swift
│   ├── ChatMessage.swift
│   └── Conversation.swift
├── Views/                  # SwiftUI views
│   ├── Home/
│   ├── Chat/
│   ├── Patterns/
│   ├── Projects/
│   ├── Settings/
│   └── Components/
├── ViewModels/            # Business logic
│   └── ChatViewModel.swift
├── Services/              # API & services
│   └── GraphQL/
├── Utilities/             # Helpers & extensions
│   ├── Theme.swift
│   ├── Constants.swift
│   └── Extensions/
└── Assets.xcassets/       # Images & colors
```

## Theme

The app uses a warm, earthy color palette inspired by crochet:

**Light Mode:**
- Background: `#fdfcfb` (warm cream)
- Primary: `#A47764` (warm brown)
- Text: `#3c2e26` (dark brown)

**Dark Mode:**
- Background: `#1a1a1a` (warm dark gray)
- Primary: `#A47764` (warm brown)
- Text: `#f5f1ed` (cream)

## Development Status

### ✅ Completed (Phases 1-2)
- ✅ Project structure and navigation
- ✅ Custom theme matching web app
- ✅ Chat with full backend integration
- ✅ Pattern & project browsing (mock data)
- ✅ Dark mode support
- ✅ Empty states and loading views
- ✅ Haptic feedback
- ✅ Markdown rendering in chat
- ✅ Pull-to-refresh

### 🔄 In Progress (Phase 3)
- ⏳ Pattern & Project ViewModels with backend
- ⏳ Local data persistence (SwiftData)
- ⏳ Image viewer with zoom/pan
- ⏳ AI usage dashboard

### 📋 Planned (Phase 4+)
- Offline mode
- Camera integration
- Push notifications
- User authentication
- Pattern sharing

See [CLAUDE.md](CLAUDE.md) and [IMPLEMENTATION.md](IMPLEMENTATION.md) for detailed roadmap.

## Testing

### Run in Simulator
1. Select any iPhone simulator in Xcode
2. Press ⌘R to build and run

### Toggle Dark Mode
- In Simulator: **Features → Appearance → Dark**
- Keyboard shortcut: **⌘⇧A**

### Test AI Chat
1. Go to the Chat tab
2. Ask questions like:
   - "What does sc2tog mean?"
   - "Show me a granny square pattern"
   - "How do I make a magic ring?"

The chat connects to the real Gemini AI backend!

## Contributing

This is a personal project, but feel free to open issues or PRs if you find bugs or have suggestions.

## License

MIT

## Related Projects

- [Crooked Finger Web App](https://github.com/ChandlerHardy/crooked-finger) - Next.js web version
- [Production Site](https://crookedfinger.chandlerhardy.com)

---

Built with ❤️ and Swift
