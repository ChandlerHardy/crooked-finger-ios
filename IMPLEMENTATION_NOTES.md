# Crooked Finger iOS - Implementation Notes

## Overview
SwiftUI iOS app for the Crooked Finger crochet pattern assistant. Connects to the same GraphQL backend as the web app.

## Backend Integration Status
✅ **COMPLETE** - Patterns and Projects fully integrated with PostgreSQL backend

### What's Working
- Pattern library (fetch, create, delete)
- Project management (fetch, create, delete, update)
- Create project from pattern template
- Pull-to-refresh on all lists
- Error handling with user-friendly messages
- Empty state views

### Authentication Status
⚠️ **TEMPORARILY DISABLED** due to production backend bcrypt library bug

The full authentication system was implemented but is currently disabled:
- JWT token storage in UserDefaults
- Login/Register views
- AuthViewModel for state management
- Commented out auth headers in GraphQLClient

**To re-enable when backend is fixed:**
1. Uncomment `GraphQLClient.swift` lines 53-63 (Authorization header)
2. Update `Crooked_Finger_iOSApp.swift` to show LoginView when not authenticated
3. Backend team needs to fix bcrypt library issue

## Key Implementation Details

### GraphQL Client
**File**: `Services/GraphQL/GraphQLClient.swift`

Uses native URLSession instead of Apollo:
- Simpler setup, no codegen required
- Direct control over request/response handling
- Auth token stored and auto-attached to requests (when enabled)

### Pattern vs Project Distinction
Both use the same backend `CrochetProject` table, filtered by `notes` field:

**Patterns** (`PatternViewModel.swift`):
```swift
// Filter for templates (no notes)
let patternProjects = response.projects.filter { project in
    project.isCompleted == false &&
    (project.notes?.isEmpty ?? true || project.notes == nil)
}
```

**Projects** (`ProjectViewModel.swift`):
```swift
// Filter for active projects (has notes)
let activeProjects = response.projects.filter { project in
    project.notes != nil && !project.notes!.isEmpty
}
```

**Create Project from Pattern**:
Duplicates the pattern as a new CrochetProject with notes:
```swift
let variables: [String: Any] = [
    "input": [
        "name": projectName ?? "\(pattern.name) - My Project",
        "patternText": pattern.notation,
        "notes": "Created from pattern: \(pattern.name)" // Non-empty = project
    ]
]
```

### GraphQL Variables - Important Note
❌ **DON'T** use Codable structs with JSONEncoder for GraphQL variables
✅ **DO** use native Swift dictionaries

**Why**: JSONEncoder creates `Foundation.__NSSwiftData` which causes "Invalid type in JSON write" errors

**Correct approach**:
```swift
var input: [String: Any?] = [
    "name": name,
    "patternText": pattern,
    "difficultyLevel": difficulty?.rawValue
]
let variables: [String: Any] = ["input": input]
```

## API Configuration

**File**: `Utilities/Constants.swift`

```swift
enum APIConfig {
    static let graphqlURL = "https://backend.chandlerhardy.com/crooked-finger/graphql"
    static let localGraphqlURL = "http://localhost:8001/crooked-finger/graphql"

    #if DEBUG
    static let currentGraphqlURL = graphqlURL  // Using production
    #else
    static let currentGraphqlURL = graphqlURL
    #endif
}
```

Currently using production backend even in DEBUG mode since local backend isn't always running.

## Color Scheme

Matching web app brown/tan theme:

```swift
extension Color {
    static let primaryBrown = Color(red: 0.55, green: 0.42, blue: 0.31)
    static let lightBrown = Color(red: 0.82, green: 0.71, blue: 0.55)
    static let appBackground = Color(UIColor.systemGroupedBackground)
    static let appCard = Color(UIColor.secondarySystemGroupedBackground)
    static let appText = Color(UIColor.label)
    static let appMuted = Color(UIColor.secondaryLabel)
    static let appBorder = Color(UIColor.separator)
}
```

## Common Issues & Solutions

### 1. "Authentication required" errors
**Status**: Fixed by temporarily disabling auth on backend
**Long-term fix**: Backend team needs to resolve bcrypt library issue

### 2. "Invalid type in JSON write" error
**Cause**: Using JSONEncoder on Swift structs for GraphQL variables
**Solution**: Use native dictionaries (see GraphQL Variables section above)

### 3. Patterns not showing in list
**Check**:
- Backend `CrochetProject` entries have `notes == null`
- `isCompleted == false`
- Use "Pull to refresh" to reload from backend

## Next Steps for iOS

1. **AI Chat Interface**: Port web chat to SwiftUI
2. **YouTube Integration**: Add video transcript extraction
3. **Image Viewer**: Professional zoom/pan for pattern/project images
4. **Pattern Diagram Display**: Show matplotlib-generated charts
5. **Pattern Sharing**: Browse and import patterns from other users

## Backend Changes Made for iOS

To support iOS (and fix web too), the following backend changes were made:

**File**: `backend/app/schemas/mutations.py`
- Commented out authentication checks in `create_project`, `update_project`, `delete_project`
- Allow null `user_id` for projects when not authenticated
- TODO comments added for re-enabling auth

**File**: `backend/app/main.py`
- Removed `request.user` assignments (property has no setter in FastAPI)
- Removed debug user creation logic (caused bcrypt errors)

These changes are **temporary workarounds** until the bcrypt library is fixed.

---
*Last Updated: October 2025 - Backend Integration Complete*
