# Requirements Document

## Introduction

The Profile Screen feature provides authenticated users with a dedicated screen to view and manage their profile information. It covers four core capabilities: displaying the current user photo, uploading a new avatar via the device image picker, editing the display name, and permanently deleting the account. The feature builds on the existing `ProfileBloc`, `ProfileRepository`, and `ProfileDataSource` infrastructure already present in the codebase, and integrates with Supabase as the backend for storage and user metadata updates.

## Glossary

- **Profile_Screen**: The Flutter screen widget that presents the user's profile and exposes edit/delete actions.
- **Profile_Bloc**: The existing BLoC (`ProfileBloc`) that mediates between the UI and `ProfileRepository`.
- **Profile_Repository**: The domain-layer contract (`ProfileRepository`) for profile operations.
- **Profile_DataSource**: The data-layer implementation (`ProfileDataSourceImpl`) that calls Supabase APIs.
- **Avatar**: The circular profile photo displayed on the Profile_Screen.
- **Image_Picker**: The `image_picker` Flutter package (v1.2.1) used to select images from the device gallery or camera.
- **Supabase_Storage**: The Supabase Storage bucket used to persist uploaded avatar images.
- **Supabase_Auth**: The Supabase GoTrue authentication service used to update user metadata and delete accounts.
- **Display_Name**: The human-readable name stored in Supabase user metadata under the key `name`.
- **Photo_URL**: The publicly accessible URL of the user's avatar, stored in Supabase user metadata under `avatar_url`.
- **Session_Bloc**: The existing BLoC (`SessionBloc`) that holds the current authentication state and `UserEntity`.
- **UserEntity**: The domain entity representing the authenticated user, containing `id`, `email`, `displayName`, `photoUrl`, and related fields.

---

## Requirements

### Requirement 1: Display Profile Information

**User Story:** As an authenticated user, I want to see my current profile information on the Profile Screen, so that I can verify my display name and avatar before making changes.

#### Acceptance Criteria

1. WHEN the Profile_Screen is opened, THE Profile_Screen SHALL display the current user's Avatar using the `photoUrl` field from `UserEntity`.
2. WHEN the `photoUrl` field of `UserEntity` is null, THE Profile_Screen SHALL display a default placeholder icon in place of the Avatar.
3. WHEN the Profile_Screen is opened, THE Profile_Screen SHALL display the current user's Display_Name from the `displayName` field of `UserEntity`.
4. WHEN the `displayName` field of `UserEntity` is null, THE Profile_Screen SHALL display the user's email address as a fallback label.
5. WHEN the Profile_Screen is opened, THE Profile_Screen SHALL display the user's email address as a read-only field.

---

### Requirement 2: Upload Avatar

**User Story:** As an authenticated user, I want to upload a new profile photo from my device, so that my Avatar reflects my current identity.

#### Acceptance Criteria

1. WHEN the user taps the Avatar area or an upload button, THE Profile_Screen SHALL invoke the Image_Picker to present a source selection (gallery or camera).
2. WHEN the user selects an image from the Image_Picker, THE Profile_Bloc SHALL emit `ProfileLoading` and dispatch `UploadProfilePictureEvent` with the selected file path.
3. WHEN `UploadProfilePictureEvent` is dispatched, THE Profile_DataSource SHALL upload the image file to Supabase_Storage and return the public Photo_URL.
4. WHEN the upload succeeds, THE Profile_Bloc SHALL emit `ProfilePictureUploaded` containing the new Photo_URL.
5. WHEN `ProfilePictureUploaded` is emitted, THE Profile_Bloc SHALL automatically dispatch `UpdateProfileEvent` with the new `photoUrl` to persist it in Supabase_Auth user metadata.
6. WHEN the user dismisses the Image_Picker without selecting an image, THE Profile_Screen SHALL remain in its current state without triggering any upload.
7. IF the image upload fails, THEN THE Profile_Bloc SHALL emit `ProfileError` with a descriptive error message.
8. WHILE the upload is in progress, THE Profile_Screen SHALL display a loading indicator over the Avatar area.

---

### Requirement 3: Edit Display Name

**User Story:** As an authenticated user, I want to edit my display name, so that other users and the app reflect my preferred name.

#### Acceptance Criteria

1. WHEN the user taps the edit action for the Display_Name, THE Profile_Screen SHALL present an editable text field pre-populated with the current Display_Name.
2. WHEN the user submits a new Display_Name, THE Profile_Screen SHALL validate that the Display_Name is between 1 and 50 characters in length.
3. IF the submitted Display_Name is empty or exceeds 50 characters, THEN THE Profile_Screen SHALL display a validation error message and SHALL NOT dispatch `UpdateProfileEvent`.
4. WHEN a valid Display_Name is submitted, THE Profile_Bloc SHALL emit `ProfileLoading` and dispatch `UpdateProfileEvent` with the new `displayName`.
5. WHEN `UpdateProfileEvent` is dispatched, THE Profile_DataSource SHALL call the Supabase_Auth `updateUser` API to persist the new Display_Name in user metadata.
6. WHEN the update succeeds, THE Profile_Bloc SHALL emit `ProfileUpdated` containing the updated `UserEntity`.
7. WHEN `ProfileUpdated` is emitted, THE Profile_Screen SHALL reflect the new Display_Name without requiring a full page reload.
8. IF the update fails, THEN THE Profile_Bloc SHALL emit `ProfileError` with a descriptive error message.
9. WHILE the update is in progress, THE Profile_Screen SHALL display a loading indicator and SHALL disable the submit action.

---

### Requirement 4: Delete Account

**User Story:** As an authenticated user, I want to permanently delete my account, so that all my data is removed from the service.

#### Acceptance Criteria

1. WHEN the user taps the delete account action, THE Profile_Screen SHALL display a confirmation dialog describing the irreversible nature of the operation.
2. WHEN the user confirms deletion in the dialog, THE Profile_Bloc SHALL emit `ProfileLoading` and dispatch `DeleteAccountEvent`.
3. WHEN the user cancels the confirmation dialog, THE Profile_Screen SHALL dismiss the dialog and take no further action.
4. WHEN `DeleteAccountEvent` is dispatched, THE Profile_DataSource SHALL call the Supabase backend to permanently delete the user account and all associated data.
5. WHEN the deletion succeeds, THE Profile_Bloc SHALL emit `AccountDeleted`.
6. WHEN `AccountDeleted` is emitted, THE Profile_Screen SHALL navigate the user to the Login screen and clear the navigation stack.
7. IF the account deletion fails, THEN THE Profile_Bloc SHALL emit `ProfileError` with a descriptive error message.
8. WHILE the deletion is in progress, THE Profile_Screen SHALL display a loading indicator and SHALL disable all interactive elements.

---

### Requirement 5: Error Handling and User Feedback

**User Story:** As an authenticated user, I want to receive clear feedback when a profile operation fails, so that I understand what went wrong and can take corrective action.

#### Acceptance Criteria

1. WHEN `ProfileError` is emitted by the Profile_Bloc, THE Profile_Screen SHALL display the error message in a visible snackbar or dialog.
2. WHEN a network error occurs during any profile operation, THE Profile_DataSource SHALL throw a `ServerException` with a human-readable message.
3. IF an authentication error occurs during a profile operation, THEN THE Profile_DataSource SHALL throw an `AuthException` with a human-readable message.
4. WHEN `ProfileError` is emitted, THE Profile_Screen SHALL restore interactive elements to their enabled state so the user can retry.

---

### Requirement 6: Navigation Integration

**User Story:** As an authenticated user, I want to navigate to the Profile Screen from the Home Screen, so that I can access profile management from the main app flow.

#### Acceptance Criteria

1. THE App SHALL register a `/profile` named route that resolves to the Profile_Screen.
2. WHEN the user navigates to `/profile`, THE Profile_Screen SHALL be provided with a `ProfileBloc` instance via `BlocProvider`.
3. WHEN the user taps the back button or navigation arrow on the Profile_Screen, THE Profile_Screen SHALL navigate back to the Home Screen.
4. WHEN `AccountDeleted` is emitted, THE Profile_Screen SHALL use `pushReplacementNamed` to navigate to `/login` and remove the Profile_Screen from the navigation stack.
