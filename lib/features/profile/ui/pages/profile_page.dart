/// Display and edit the current user's profile.
///
/// Shows the profile data in a form and allows the user to save
/// changes. Demonstrates the full CRUD pattern with loading states,
/// error handling, and form validation.
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_starter/core/presentation/widgets/app_snackbar.dart';
import 'package:flutter_starter/features/profile/domain/entities/profile.dart';
import 'package:flutter_starter/features/profile/ui/view_models/profile_view_model.dart';
import 'package:flutter_starter/gen/strings.g.dart';

/// The profile page for viewing and editing user details.
@RoutePage()
class ProfilePage extends ConsumerStatefulWidget {
  /// Create a [ProfilePage].
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _phoneController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _populateControllers() {
    final profile = ref.read(profileViewModelProvider).valueOrNull;
    if (profile != null) {
      _nameController.text = profile.name;
      _bioController.text = profile.bio ?? '';
      _phoneController.text = profile.phoneNumber ?? '';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(profileViewModelProvider.notifier)
        .updateProfile(
          name: _nameController.text,
          bio: _bioController.text.isEmpty ? null : _bioController.text,
          phoneNumber: _phoneController.text.isEmpty
              ? null
              : _phoneController.text,
        );

    if (mounted) {
      final hasError = ref.read(profileViewModelProvider).hasError;
      if (hasError) {
        AppSnackbar.showError(context, t.profile.error.updateFailed);
      } else {
        AppSnackbar.showSuccess(context, t.core.action.save);
        setState(() => _isEditing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.profile.title),
        actions: [
          if (profileAsync.hasValue && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _populateControllers();
                setState(() => _isEditing = true);
              },
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _isEditing = false),
            ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(t.profile.error.loadFailed),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(profileViewModelProvider),
                child: Text(t.core.action.retry),
              ),
            ],
          ),
        ),
        data: (profile) {
          if (_isEditing) {
            return _buildEditForm(context);
          }
          return _buildProfileView(context, profile);
        },
      ),
    );
  }

  Widget _buildProfileView(BuildContext context, Profile profile) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      CircleAvatar(
        radius: 48,
        backgroundImage: profile.avatarUrl != null
            ? NetworkImage(profile.avatarUrl!)
            : null,
        child: profile.avatarUrl == null
            ? Text(
                profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                style: Theme.of(context).textTheme.headlineLarge,
              )
            : null,
      ),
      const SizedBox(height: 24),
      Text(
        profile.name,
        style: Theme.of(context).textTheme.headlineSmall,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 8),
      Text(
        profile.email,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
      if (profile.bio != null && profile.bio!.isNotEmpty) ...[
        const SizedBox(height: 24),
        Text(profile.bio!, textAlign: TextAlign.center),
      ],
      if (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty) ...[
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phone, size: 16),
            const SizedBox(width: 8),
            Text(profile.phoneNumber!),
          ],
        ),
      ],
    ],
  );

  Widget _buildEditForm(BuildContext context) => Form(
    key: _formKey,
    child: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _bioController,
          decoration: const InputDecoration(
            labelText: 'Bio',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 24),
        FilledButton(onPressed: _saveProfile, child: Text(t.core.action.save)),
      ],
    ),
  );
}
