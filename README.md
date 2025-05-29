# Food Calories Analyzer

An iOS app that analyzes food calories from photos using OpenAI's Vision API.

## Features

- Take photos of food using the device camera
- Analyze food ingredients and calories using OpenAI Vision API
- Edit analyzed data (ingredients, calories, nutritional info)
- View food history with calendar integration
- Beautiful SwiftUI interface with dark mode support

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- OpenAI API Key

## Setup

1. Clone the repository
2. Open `VibeCodingTest.xcodeproj` in Xcode
3. Add your OpenAI API key to the project:
   - In Xcode, go to your target's Build Settings
   - Find "User-Defined" settings
   - Add a new setting called `OPENAI_API_KEY`
   - Set its value to your OpenAI API key
4. Build and run the project

## Architecture

The app follows the MVVM architecture pattern and uses SwiftUI for the UI layer. Key components include:

- **Views**: SwiftUI views for camera, analysis, and history
- **ViewModels**: Business logic and state management
- **Services**: OpenAI API integration and data persistence
- **Models**: Data models for food records and analysis

## Dependencies

- SwiftUI
- AVFoundation (for camera functionality)
- OpenAI Vision API

## License

This project is available under the MIT license. See the LICENSE file for more info.
