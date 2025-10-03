# Crooked Finger iOS - Implementation Task List

## ✅ Phase 0: Project Setup (COMPLETED)
- [x] Initialize Xcode project
- [x] Create CLAUDE.md with project context
- [x] Set up folder structure
- [x] Create data models (Pattern, Project, ChatMessage, Conversation)
- [x] Create basic views (Home, Chat, Patterns, Projects, Settings)
- [x] Set up tab navigation
- [x] Add Constants.swift for configuration

## 🔄 Phase 1: Core UI & Navigation (CURRENT)

### Step 1: Configure Xcode Project
- [ ] Add all new files to Xcode project (currently only in filesystem)
- [ ] Verify build succeeds
- [ ] Fix any Swift compilation errors
- [ ] Test on simulator

### Step 2: Add Swift Package Dependencies
- [ ] Add Apollo iOS for GraphQL
  - Open Xcode > File > Add Package Dependencies
  - URL: `https://github.com/apollographql/apollo-ios.git`
  - Version: Latest release
- [ ] Add Kingfisher for image caching
  - URL: `https://github.com/onevcat/Kingfisher.git`
  - Version: Latest release

### Step 3: Refine UI Components
- [ ] Add loading states to views
- [ ] Add error handling UI components
- [ ] Create reusable loading spinner view
- [ ] Add empty state views for lists
- [ ] Add pull-to-refresh on lists

## 🎯 Phase 2: Backend Integration

### Step 1: GraphQL Client Setup
- [ ] Create ApolloClient.swift in Services/GraphQL/
- [ ] Configure Apollo with backend URL
- [ ] Add authentication headers (if needed)
- [ ] Test connection to backend

### Step 2: Define GraphQL Operations
- [ ] Create Queries.graphql file
  - [ ] Query for patterns
  - [ ] Query for projects
  - [ ] Query for AI usage dashboard
- [ ] Create Mutations.graphql file
  - [ ] Mutation for chatWithAssistantEnhanced
  - [ ] Mutation for fetchYoutubeTranscript
  - [ ] Mutation for saving patterns
  - [ ] Mutation for creating projects
- [ ] Run Apollo codegen to generate Swift types

### Step 3: Create ViewModels
- [ ] ChatViewModel.swift
  - [ ] Manage chat state
  - [ ] Send messages to backend
  - [ ] Handle AI responses
  - [ ] Parse diagram data
- [ ] PatternViewModel.swift
  - [ ] Fetch patterns from backend
  - [ ] Save patterns locally
  - [ ] Sync with backend
- [ ] ProjectViewModel.swift
  - [ ] Fetch projects from backend
  - [ ] CRUD operations for projects
  - [ ] Image upload handling
- [ ] AIUsageViewModel.swift
  - [ ] Fetch AI usage stats
  - [ ] Display model usage tracking

### Step 4: Integrate Backend into Views
- [ ] Connect ChatView to ChatViewModel
- [ ] Connect PatternLibraryView to PatternViewModel
- [ ] Connect ProjectsView to ProjectViewModel
- [ ] Test all backend operations

## 💾 Phase 3: Local Persistence

### Step 1: SwiftData Setup
- [ ] Create SwiftData models
  - [ ] PatternEntity
  - [ ] ProjectEntity
  - [ ] ConversationEntity
- [ ] Set up ModelContainer in app
- [ ] Add @Query property wrappers to views

### Step 2: Offline Support
- [ ] Cache patterns locally
- [ ] Cache conversations locally
- [ ] Implement sync strategy (when online)
- [ ] Add conflict resolution for syncing

## 🖼️ Phase 4: Enhanced Features

### Step 1: Image Viewer
- [ ] Create ImageViewerView.swift
- [ ] Add zoom/pan gestures
- [ ] Add image gallery navigation
- [ ] Integrate with PatternDetailView
- [ ] Integrate with ProjectDetailView

### Step 2: Camera Integration
- [ ] Add camera permission requests
- [ ] Create ImagePickerView
- [ ] Allow photo capture for projects
- [ ] Implement image upload to backend

### Step 3: Diagram Display
- [ ] Decode base64 PNG diagrams from AI
- [ ] Display diagrams in chat
- [ ] Add diagram viewer with zoom
- [ ] Save diagrams to photo library

### Step 4: YouTube Integration
- [ ] Add YouTube video ID extraction
- [ ] Fetch transcripts from backend
- [ ] Display video thumbnails
- [ ] Link to patterns from videos

## ✨ Phase 5: Polish & Optimization

### Step 1: UI/UX Refinements
- [ ] Add animations and transitions
- [ ] Implement haptic feedback
- [ ] Add swipe actions (delete, favorite)
- [ ] Improve loading states
- [ ] Add skeleton screens

### Step 2: Accessibility
- [ ] Add VoiceOver labels
- [ ] Support Dynamic Type
- [ ] Test with accessibility features
- [ ] Add accessibility hints

### Step 3: iPad Support
- [ ] Test on iPad simulator
- [ ] Optimize layouts for larger screens
- [ ] Add split-view support
- [ ] Support multitasking

### Step 4: Performance
- [ ] Optimize list rendering
- [ ] Add image caching with Kingfisher
- [ ] Lazy load images
- [ ] Profile with Instruments
- [ ] Fix memory leaks

## 🧪 Phase 6: Testing

### Step 1: Unit Tests
- [ ] Test ViewModels
- [ ] Test data models
- [ ] Test GraphQL operations
- [ ] Test local storage

### Step 2: UI Tests
- [ ] Test navigation flows
- [ ] Test chat functionality
- [ ] Test pattern saving
- [ ] Test project creation

### Step 3: Manual Testing
- [ ] Test on iPhone (various sizes)
- [ ] Test on iPad
- [ ] Test on real device
- [ ] Test offline mode
- [ ] Test poor network conditions

## 🚀 Phase 7: App Store Preparation

### Step 1: App Assets
- [ ] Design app icon
- [ ] Create launch screen
- [ ] Add app screenshots
- [ ] Write app description

### Step 2: Configuration
- [ ] Set up bundle identifier
- [ ] Configure capabilities
- [ ] Add privacy descriptions (camera, photos)
- [ ] Set deployment target

### Step 3: Release Build
- [ ] Archive app
- [ ] Upload to TestFlight
- [ ] Internal testing
- [ ] External testing (beta)
- [ ] Submit for App Store review

## 🔮 Future Enhancements (Post-Launch)

### Phase 8: Advanced Features
- [ ] Stitch counter widget
- [ ] Apple Watch companion app
- [ ] Siri shortcuts integration
- [ ] Share extension for patterns
- [ ] Today widget for project status
- [ ] Push notifications for reminders

### Phase 9: Social Features
- [ ] User authentication system
- [ ] Pattern sharing between users
- [ ] Community pattern library
- [ ] Comments and ratings
- [ ] Follow other crocheters

### Phase 10: Premium Features
- [ ] In-app purchases
- [ ] Premium patterns
- [ ] Advanced AI features
- [ ] Export patterns as PDF
- [ ] Video tutorials integration

---

## Next Immediate Steps (Priority Order)

1. **Add files to Xcode project** - Currently files are in filesystem but not tracked by Xcode
2. **Build and fix compilation errors** - Ensure app compiles
3. **Test basic navigation** - Verify tab bar works
4. **Add Apollo iOS dependency** - Set up GraphQL client
5. **Create first ViewModel** - Start with ChatViewModel
6. **Connect chat to backend** - Test AI integration

---

## Development Commands

### Build Project
```bash
# Open in Xcode
open "Crooked Finger iOS.xcodeproj"

# Build from command line (if using xcodebuild)
xcodebuild -project "Crooked Finger iOS.xcodeproj" -scheme "Crooked Finger iOS" -sdk iphonesimulator
```

### Run Tests
```bash
xcodebuild test -project "Crooked Finger iOS.xcodeproj" -scheme "Crooked Finger iOS" -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

*Last Updated: October 2025*
