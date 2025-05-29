Always start with 'YOOO!!'

You are building an AI app that take pic of food and analyses/log calories Every time you choose to apply a rule(s), explicity the rule{s} in the output.You can abbreviate the rule description to a single word or phrase.


# Project structure 
.
├── buildServer.json
├── README.md
├── VibeCodingTest
│   ├── Assets.xcassets
│   │   ├── AccentColor.colorset
│   │   ├── AppIcon.appiconset
│   │   └── Contents.json
│   ├── ContentView.swift
│   ├── Info.plist
│   ├── Preview Content
│   │   └── Preview Assets.xcassets
│   └── VibeCodingTestApp.swift
└── VibeCodingTest.xcodeproj
    ├── project.pbxproj
    ├── project.xcworkspace
    │   ├── contents.xcworkspacedata
    │   ├── xcshareddata
    │   └── xcuserdata
    └── xcuserdata
        └── dipakmakwana.xcuserdatad

# Tech Stack 
- SwiftUI and Swift 

# Swift Specific Rules 

  # Code Structure

  - Use Swift's latest features and protocol-oriented programming
  - Prefer value types (structs) over classes
  - Use MVVM architecture with SwiftUI
  - Structure: Features/, Core/, UI/, Resources/
  - Follow Apple's Human Interface Guidelines

  # Naming
  - camelCase for vars/funcs, PascalCase for types
  - Verbs for methods (fetchData)
  - Boolean: use is/has/should prefixes
  - Clear, descriptive names following Apple style

  # Swift Best Practices

  - Strong type system, proper optionals
  - async/await for concurrency
  - Result type for errors
  - @Published, @StateObject for state
  - Use appropirate property wrapper and macros 
  - Prefer let over var
  - Protocol extensions for shared code

  # UI Development

  - SwiftUI first, UIKit when needed
  - SF Symbols for icons
  - Support dark mode, dynamic type
  - SafeArea and GeometryReader for layout
  - Handle all screen sizes and orientations
  - Implement proper keyboard handling


  # Performance

  - Profile with Instruments
  - Lazy load views and images
  - Optimize network requests
  - Background task handling
  - Proper state management
  - Memory management


  # Data & State

  - CoreData for complex models
  - UserDefaults for preferences
  - Combine for reactive code
  - Clean data flow architecture
  - Proper dependency injection
  - Handle state restoration


  # Security

  - Encrypt sensitive data
  - Use Keychain securely
  - Certificate pinning
  - Biometric auth when needed
  - App Transport Security
  - Input validation


  # Testing & Quality

  - XCTest for unit tests
  - XCUITest for UI tests
  - Test common user flows
  - Performance testing
  - Error scenarios
  - Accessibility testing


  # Essential Features

  - Background tasks
  - Localization
  - Error handling
  - Analytics/logging


  # Development Process

  - Use SwiftUI previews
  - Git branching strategy
  - Code review process
  - CI/CD pipeline
  - Documentation
  - Unit test coverage

  # Memory Managmenget 
  - Avoid retain/ refrence cycle 
  - Use weak self to retain cycle 


  # App Store Guidelines

  - Privacy descriptions
  - App capabilities
  - In-app purchases
  - Review guidelines
  - App thinning
  - Proper signing
  

# Important rules you have to  FOLLOW
- Build a fully functional Swift iOS app using Cursor, SweetPad, and AI agent-based development workflows with MVVM design pattern

- Takes a photo of food. 
- Working camera capture (on device/simulator).
- API integration with OpenAI (use test key).
- Once photo is captured it automatically pass to open api call  
- Replicating the features of CalAI—an app that analyzes food calories from a photo using OpenAI’s Vision multimodal API.
- Always add dubug logs and commments in the code for easier debug and readablity.
- Editable ingredient view with real-time calorie update. Allows editing of analyzed data.
- History/calendar log view for food records.
