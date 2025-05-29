# Food Calories Analyzer

An iOS app that analyzes food calories from photos using OpenAI's Vision API. The app features a modern SwiftUI interface, real-time food analysis, and a calendar-based history view.

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%2016.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## Features

- 📸 Take photos of food using device camera
- 🔍 Real-time food analysis using OpenAI Vision API
- 📊 Detailed nutritional information:
  - Total calories
  - Protein content
  - Carbohydrates
  - Fat content
- 📝 Edit analyzed ingredients and data
- 📅 Calendar-based history view
- 🌓 Dark mode support
- 🖼️ Optimized image processing

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- OpenAI API Key
- macOS Sonoma 14.0+ (for development)

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/VibeCodingTest.git
cd VibeCodingTest
```

### 2. OpenAI API Key Setup

You need to add your OpenAI API key to use the food analysis features. There are two ways to do this:

#### Option A: Using Info.plist
1. Open `VibeCodingTest/Info.plist`
2. Find the key `OPENAI_API_KEY`
3. Replace the value with your OpenAI API key

#### Option B: Using Xcode Build Settings
1. Open the project in Xcode
2. Select the target 'VibeCodingTest'
3. Go to 'Build Settings'
4. Find 'User-Defined' settings
5. Add a new setting called `OPENAI_API_KEY`
6. Set its value to your OpenAI API key

### 3. Install Dependencies

This project uses Swift Package Manager for dependencies. Xcode will automatically resolve dependencies when you open the project.

### 4. Build and Run

1. Open `VibeCodingTest.xcodeproj` in Xcode
2. Select your target device/simulator
3. Press `Cmd + R` or click the Play button to build and run

## Project Structure

```
VibeCodingTest/
├── Core/
│   ├── Models/
│   │   ├── OpenAIModels.swift
│   │   └── ...
│   ├── Services/
│   │   ├── OpenAIService.swift
│   │   └── FoodHistoryManager.swift
│   └── Views/
│       └── ToastView.swift
├── Features/
│   ├── Camera/
│   │   ├── CameraView.swift
│   │   └── CameraViewModel.swift
│   ├── Analysis/
│   │   ├── FoodAnalysisView.swift
│   │   └── FoodAnalysisViewModel.swift
│   └── History/
│       ├── HistoryView.swift
│       └── HistoryViewModel.swift
└── Resources/
    └── Info.plist
```

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Views**: SwiftUI views for UI components
- **ViewModels**: Business logic and state management
- **Models**: Data structures and types
- **Services**: API integration and data persistence

## Key Components

### Camera Module
- Uses `AVFoundation` for camera capture
- Real-time camera preview
- Support for front/back camera switching
- Permission handling

### Analysis Module
- OpenAI Vision API integration
- Image optimization before upload
- JSON response parsing
- Error handling

### History Module
- Calendar-based record viewing
- Local data persistence
- CRUD operations for food records
- Grouped by date

## Performance Optimizations

- Image compression before API upload
- Efficient data caching
- Background thread processing
- Memory management
- Lazy loading of views

## Troubleshooting

### Common Issues

1. **API Key Error**
   - Verify your OpenAI API key is correctly set in Info.plist
   - Check for any whitespace in the API key

2. **Camera Permission**
   - Ensure camera permission is granted in device settings
   - Check Info.plist for proper permission descriptions

3. **Build Errors**
   - Clean build folder (Cmd + Shift + K)
   - Clean build cache (Cmd + Option + Shift + K)
   - Re-install dependencies

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Acknowledgments

- OpenAI for Vision API
- Apple SwiftUI Documentation
- SwiftUI Community
