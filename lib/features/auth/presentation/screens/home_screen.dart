import 'package:auth_flow_app/features/auth/presentation/bloc/session/session_bloc.dart';
import 'package:auth_flow_app/features/auth/presentation/bloc/session/session_event.dart';
import 'package:auth_flow_app/features/auth/presentation/bloc/session/session_state.dart';
import 'package:auth_flow_app/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<SessionBloc>().add(const SignOutEvent());
            },
          ),
        ],
      ),
      body: BlocConsumer<SessionBloc, SessionState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return const LoginPage();
                },
              ),
            );
            Navigator.of(context).pushReplacementNamed('/login');
          } else if (state is SessionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is SessionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is Authenticated) {
            print('🏠 Home rebuilt: photoUrl = ${state.user.photoUrl}');
            final user = state.user;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: user.photoUrl != null
                          ? NetworkImage(
                              '${user.photoUrl}?t=${DateTime.now().millisecondsSinceEpoch}',
                            )
                          : null,
                      child: user.photoUrl == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      user.displayName ?? 'User',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(user.email, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(
                        user.isEmailVerified ? 'Email Verified' : 'Email Not Verified',
                      ),
                      backgroundColor: user.isEmailVerified
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/profile');
                      },
                      icon: const Icon(Icons.person),
                      label: const Text('Edit Profile'),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        context.read<SessionBloc>().add(const SignOutEvent());
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('Please login to continue'));
        },
      ),
    );
  }
}
