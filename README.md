# Smart Plant Watering System

A Flutter project for an IoT Smart Plant Watering System.

## Architecture

This project follows a clean, feature-based architecture to keep the codebase modular, scalable, and easy to maintain.

### Folder Structure

- `lib/core/`: Contains core application code such as constants, themes, routing, and generic utilities used across features.
- `lib/features/`: The main feature modules. Each feature is self-contained.
  - `dashboard/`: The main dashboard feature.
    - `presentation/`: Contains UI screens and state management for the dashboard.
    - `widgets/`: Contains reusable UI components specific to the dashboard.
- `lib/services/`: External services such as API clients, local storage, or Firebase wrappers. (Firebase integration goes here).
- `lib/models/`: Shared data models used across different parts of the app.

## Requirements Met

- **Flutter Material 3**: Enabled in `ThemeData` via `useMaterial3: true`.
- **Responsive Layout**: Included a basic responsive `LayoutBuilder` in the dashboard screen.
- **Clean Architecture**: Organized into features, core, services, and models.
- **Firebase Ready**: The `firebase_core` package is installed, and the app is ready for Firebase initialization (no implementation yet).

## Running the App

To run the app, ensure you have an emulator or physical device connected, then execute:

```bash
flutter run
```
