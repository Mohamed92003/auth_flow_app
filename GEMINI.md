# Gemini Context: Auth Flow App

This project is a comprehensive authentication system built with **Flutter** and **Supabase**, implementing a robust **Clean Architecture** with **BLoC** for state management.

## Project Overview

- **Purpose**: A starter template for multi-method authentication (Email, Social, Phone, Magic Link) and profile management.
- **Backend**: Supabase (Auth, Storage, Edge Functions).
- **State Management**: `flutter_bloc` with specialized BLoCs for each auth feature.
- **Dependency Injection**: `get_it` (Service Locator pattern).
- **Error Handling**: `dartz` (Either pattern) for functional error handling, returning custom `Failure` objects from repositories.
- **Design Pattern**: Domain-Driven Design (DDD) with clear separation between Data, Domain, and Presentation layers.

## Architecture Layers

### 1. Core (`lib/core/`)
- **DI**: Dependency registration in `injection_container.dart`.
- **Error**: Custom `Exception` and `Failure` classes.
- **Network**: Abstract and concrete implementations of Supabase clients (`AuthClient`, `StorageClient`).

### 2. Features (`lib/features/auth/`)
- **Domain**: Pure business logic (Entities, Repository interfaces).
- **Data**: Implementation details (Models with JSON serialization, DataSources, Repository implementations).
- **Presentation**: UI logic and components (BLoCs, Screens, Widgets).

## Key Technologies & Dependencies

- **Flutter SDK**: ^3.9.2
- **Supabase Flutter**: ^2.12.0 (Authentication and Storage)
- **State Management**: `flutter_bloc` (^9.1.1), `equatable` (^2.0.8)
- **Functional Programming**: `dartz` (^0.10.1)
- **Environment**: `flutter_dotenv` (^6.0.0)
- **UI Components**: `pinput` (for OTP), `image_picker` (for profile photos)

## Development Conventions

- **Linting**: Uses `flutter_lints` with custom rules in `analysis_options.yaml` (prefers single quotes, final fields/locals, and const constructors).
- **Naming**: BLoC events and states follow a consistent naming convention (e.g., `EmailAuthEvent`, `EmailAuthState`).
- **Imports**: Mixes package and relative imports (Package imports preferred for DI/Core).
- **Assets**: Images are located in `assets/images/`, and environment variables are in `.env`.

## Building and Running

### Prerequisites
- Flutter SDK installed.
- A `.env` file at the root containing:
  ```env
  SUPABASE_URL=your_supabase_url
  SUPABASE_ANON_KEY=your_supabase_anon_key
  ```

### Commands
- **Install Dependencies**: `flutter pub get`
- **Run the App**: `flutter run`
- **Build APK**: `flutter build apk`
- **Run Tests**: `flutter test`
- **Format Code**: `dart format .`
- **Lint Code**: `flutter analyze`

## Important Implementation Notes
- **Profile Deletion**: Handled via a Supabase Edge Function named `delete-account`.
- **User Metadata**: `displayName` and `photoUrl` are stored in Supabase user metadata.
- **Session Management**: `SessionBloc` listens to `authStateChanges` to provide global authentication state across the app.
