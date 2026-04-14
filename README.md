# Momentum

A simple and flexible interval timer app for workouts.

## Features

- **Customizable Workouts** - Create workouts with steps and sets
- **Nested Sets** - Organize exercises with repeating sets
- **Sound Effects** - Audio cues for countdown, step start, and skip
- **Preparation Timer** - Get ready with a pre-workout countdown
- **Remove Last Rest** - Skip unnecessary rest between sets
- **Import/Export** - Share workouts as JSON files
- **Dark/Light Theme** - Choose your preferred look
- **Reorderable Items** - Easily rearrange workout steps

## Installation

Download the latest release from GitHub Releases:

**[Momentum Releases](https://https://github.com/Moarbue/momentum/momentum/releases)**

## Building

### Prerequisites

- Flutter SDK (3.x or later)
- Dart SDK

### Build Commands

```bash
# Install dependencies
flutter pub get

# Build Android APK
flutter build apk --release

# Build iOS (requires macOS)
flutter build ios --release
```

### Running Development Build

```bash
flutter run
```

## Usage

1. Create a new workout or use Quick Start
2. Add steps (exercises/rest periods) or sets (groups of repetitions)
3. Name each step, set duration in seconds, and choose colors
4. Save and run your workout
5. Use play/pause, skip, and reset controls during your workout

## Tech Stack

- Flutter
- Provider (state management)
- Shared Preferences (settings persistence)
- File Picker (import/export)

## License

MIT License