# Implementation Plan: Profile Screen (UI Only)

## Overview

Build the Profile Screen UI. The BLoC, repository, data source, and DI registrations are **not touched** in this plan. The only backend wiring needed is registering the `/profile` route in `main.dart` and ensuring `ProfileDataSource` is registered in the DI container so the existing `ProfileBloc` resolves correctly at runtime.

---

## Tasks

- [x] 1. Register `ProfileDataSource` in the DI container
  - Open `lib/core/di/injection_container.dart`
  - Add imports for `ProfileDataSource` and `ProfileDataSourceImpl` if not already present
  - Add `sl.registerLazySingleton<ProfileDataSource>(() => ProfileDataSourceImpl(sl()));` before the existing `ProfileRepository` registration
  - This is required so `ProfileBloc` resolves at runtime when the `/profile` route is opened
  - _Requirements: 6.2_

- [x] 2. Register the `/profile` route in `main.dart`
  - Open `lib/main.dart`
  - Add import for `profile_screen.dart` (the file created in task 3)
  - Add `'/profile': (context) => const ProfilePage(),` to the `routes` map
  - _Requirements: 6.1_

- [x] 3. Create `profile_screen.dart`
  - Create `lib/features/auth/presentation/screens/profile_screen.dart`

  - [x] 3.1 Extract `validateDisplayName` pure function at file scope
    - Signature: `String? validateDisplayName(String input)`
    - Trim the input; return `'Display name cannot be empty'` if trimmed is empty
    - Return `'Display name must be 50 characters or fewer'` if `trimmed.length > 50`
    - Return `null` for valid input (1–50 chars after trimming)
    - _Requirements: 3.2, 3.3_

  - [x] 3.2 Implement `ProfilePage` — stateless `BlocProvider` wrapper
    - `ProfilePage extends StatelessWidget`
    - Wraps `ProfileView` in `BlocProvider<ProfileBloc>(create: (_) => sl<ProfileBloc>())`
    - _Requirements: 6.2_

  - [x] 3.3 Implement `ProfileView` — avatar section
    - `ProfileView extends StatefulWidget`
    - Declare state: `bool _isEditingName = false`, `late TextEditingController _nameController`, `String? _nameError`
    - In `initState`, read the current `UserEntity` from `context.read<SessionBloc>().state` (cast to `Authenticated`) and initialise `_nameController` with `user.displayName ?? ''`
    - Render a `Stack` containing:
      - `CircleAvatar(radius: 50)` — show `NetworkImage(photoUrl)` when `photoUrl` is non-null, otherwise `Icon(Icons.person, size: 50)` as `child`
      - A camera `IconButton` positioned at the bottom-right of the avatar
      - A `CircularProgressIndicator` overlay (centered, semi-transparent) shown only when the BLoC state is `ProfileLoading`
    - On camera icon tap: call `ImagePicker().pickImage(source: ImageSource.gallery)`; if `XFile` is returned, dispatch `UploadProfilePictureEvent(filePath: xFile.path)` on `ProfileBloc`
    - _Requirements: 1.1, 1.2, 2.1, 2.2, 2.8_

  - [x] 3.4 Implement `ProfileView` — display name and email section
    - Below the avatar, render the display name row:
      - When `_isEditingName` is `false`: show a `Text` widget with `user.displayName ?? user.email` and an edit `IconButton`
      - When `_isEditingName` is `true`: show a `TextField` pre-populated from `_nameController`, `maxLength: 50`, with an error text from `_nameError`, a save `IconButton`, and a cancel `IconButton`
    - Below the name row, render the email as a read-only `Text` widget (use `Theme.of(context).textTheme.bodyMedium` with a muted colour)
    - _Requirements: 1.3, 1.4, 1.5, 3.1_

  - [x] 3.5 Implement `ProfileView` — display name save logic
    - On save icon tap: call `validateDisplayName(_nameController.text)`
    - If validation returns a non-null error: set `setState(() => _nameError = error)` and return without dispatching
    - If valid: dispatch `UpdateProfileEvent(displayName: _nameController.text.trim())`, set `_isEditingName = false`, clear `_nameError`
    - Disable the save icon when the BLoC state is `ProfileLoading`
    - On `ProfileUpdated` state: update `_nameController.text` with `state.user.displayName ?? ''` and exit edit mode
    - _Requirements: 3.2, 3.3, 3.4, 3.7, 3.9_

  - [x] 3.6 Implement `ProfileView` — delete account button and confirmation dialog
    - Render a "Delete Account" `TextButton` styled in red at the bottom of the screen
    - On tap: show an `AlertDialog` with title "Delete Account", content describing the irreversible nature, and two actions: "Cancel" (dismisses dialog) and "Delete" (dispatches `DeleteAccountEvent()`)
    - Disable the button when the BLoC state is `ProfileLoading`
    - _Requirements: 4.1, 4.2, 4.3, 4.8_

  - [x] 3.7 Implement `ProfileView` — `BlocConsumer` wiring
    - Wrap the entire body in `BlocConsumer<ProfileBloc, ProfileState>`
    - `listener`:
      - On `AccountDeleted`: call `Navigator.of(context).pushReplacementNamed('/login')`
      - On `ProfileError`: show `ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red))`
    - `builder`: pass the current `state` down to the avatar overlay, save button disabled check, and delete button disabled check
    - _Requirements: 4.5, 4.6, 5.1, 5.4, 6.4_

- [x] 4. Verify the app compiles and runs
  - Run `flutter analyze` and fix any reported issues
  - Navigate to the Profile Screen from the Home Screen and confirm the UI renders correctly
  - _Requirements: 6.1, 6.2, 6.3_

- [ ] 5. Write property-based test for `validateDisplayName`
  - Create `test/features/auth/presentation/screens/profile_validation_property_test.dart`
  - [ ]* 5.1 Write property test — Property 1: display name validation accepts exactly the valid length range
    - Import `validateDisplayName` from `profile_screen.dart`
    - Use `fast_check` with `fc.string()` and `numRuns: 100`
    - For each generated `input`: compute `trimmed = input.trim()`; assert `validateDisplayName(input)` is `null` iff `1 ≤ trimmed.length ≤ 50`
    - **Property 1: Display name validation accepts exactly the valid length range**
    - **Validates: Requirements 3.2, 3.3**
