import 'dart:convert';
import 'dart:io';

import 'package:auth_flow_app/core/di/injection_container.dart';
import 'package:auth_flow_app/features/auth/presentation/bloc/profile/profile_bloc.dart';
import 'package:auth_flow_app/features/auth/presentation/bloc/profile/profile_event.dart';
import 'package:auth_flow_app/features/auth/presentation/bloc/profile/profile_state.dart';
import 'package:auth_flow_app/features/auth/presentation/bloc/session/session_bloc.dart';
import 'package:auth_flow_app/features/auth/presentation/bloc/session/session_event.dart';
import 'package:auth_flow_app/features/auth/presentation/bloc/session/session_state.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProfileBloc>(),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final TextEditingController _nameController;
  final ImagePicker _imagePicker = ImagePicker();
  String? _currentPhotoUrl;
  bool _isLoading = false;
  int _photoVersion = 0;
  Map<String, String> _uploadedHashToUrl = {};

  String get _prefsKey {
    final sessionState = context.read<SessionBloc>().state;
    final userId = sessionState is Authenticated ? sessionState.user.id : 'guest';
    return 'uploaded_photo_hashes_$userId'; // ✅ per user
  }

  String? _lastPickedHash;

  @override
  void initState() {
    super.initState();
    final sessionState = context.read<SessionBloc>().state;
    if (sessionState is Authenticated) {
      _nameController = TextEditingController(text: sessionState.user.displayName);
      _currentPhotoUrl = sessionState.user.photoUrl;
    } else {
      _nameController = TextEditingController();
    }
    _loadUploadedHashes();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadUploadedHashes() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored != null) {
      final decoded = jsonDecode(stored) as Map<String, dynamic>;
      _uploadedHashToUrl = decoded.map((k, v) => MapEntry(k, v as String));

      // ✅ Restore latest uploaded URL if exists
      final lastUploadedUrl = _uploadedHashToUrl.values
          .where((url) => url.isNotEmpty)
          .lastOrNull;

      if (lastUploadedUrl != null && mounted) {
        setState(() {
          _currentPhotoUrl = lastUploadedUrl;
          _photoVersion++;
        });
      }
    }
  }

  Future<void> _saveUploadedHashes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_uploadedHashToUrl));
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _imagePicker.pickImage(source: source);
    if (image == null || !mounted) return;

    final bytes = await File(image.path).readAsBytes();
    final newHash = md5.convert(bytes).toString();

    // Already uploaded before → just update UI with stored URL
    if (_uploadedHashToUrl.containsKey(newHash)) {
      setState(() {
        _currentPhotoUrl = _uploadedHashToUrl[newHash];
        _photoVersion++;
      });
      return;
    }

    context.read<ProfileBloc>().add(UploadProfilePictureEvent(filePath: image.path));

    // Temporarily store hash with empty url, will be updated on success
    _uploadedHashToUrl[newHash] = '';
    _lastPickedHash = newHash;
    await _saveUploadedHashes();
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<ProfileBloc>().add(const DeleteAccountEvent());
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = context.read<SessionBloc>().state;
    final email = sessionState is Authenticated ? sessionState.user.email : '';

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) async {
        if (state is ProfileLoading) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);
        }

        if (state is ProfilePictureUploaded) {
          if (_lastPickedHash != null) {
            _uploadedHashToUrl[_lastPickedHash!] = state.photoUrl;
            _lastPickedHash = null;
            await _saveUploadedHashes();
          }
          setState(() {
            _currentPhotoUrl = state.photoUrl;
            _photoVersion++;
          });
          context.read<ProfileBloc>().add(UpdateProfileEvent(photoUrl: state.photoUrl));
        } else if (state is ProfileUpdated) {
          print('✅ ProfileUpdated: photoUrl = ${state.user.photoUrl}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          context.read<SessionBloc>().add(UpdateCurrentUserEvent(state.user));
        } else if (state is AccountDeleted) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(_prefsKey);
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _currentPhotoUrl != null
                        ? NetworkImage('$_currentPhotoUrl?t=$_photoVersion')
                        : null,
                    child: _currentPhotoUrl == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _isLoading ? null : _showImageSourceSheet,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                readOnly: true,
                controller: TextEditingController(text: email),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          context.read<ProfileBloc>().add(
                            UpdateProfileEvent(displayName: _nameController.text.trim()),
                          );
                        },
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _showDeleteConfirmation,
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete Account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}