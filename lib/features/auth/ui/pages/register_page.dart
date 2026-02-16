/// Registration page for creating a new user account.
///
/// Presents a centered, responsive form with name, email, and password
/// fields. On failure the error is displayed via a [SnackBar]. A link
/// at the bottom navigates back to the login page.
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_starter/core/routing/app_router.dart';
import 'package:flutter_starter/features/auth/data/providers/auth_providers.dart';
import 'package:flutter_starter/gen/strings.g.dart';

/// Page that collects account details and registers a new user.
///
/// Uses [authStateRepoProvider] to create the account and watches
/// the provider to react to loading, success, and error states.
@RoutePage()
class RegisterPage extends ConsumerStatefulWidget {
  /// Create a [RegisterPage].
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await ref
        .read(authStateRepoProvider.notifier)
        .register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        );

    if (!mounted) return;

    result.when(
      success: (_) => context.router.replaceAll([const ShellRoute()]),
      failure: (failure) => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStateRepoProvider) is AsyncLoading;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const .all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .stretch,
                children: [
                  Text(
                    t.auth.createAccount,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: .center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.auth.signUpSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: .center,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: t.auth.name,
                      prefixIcon: const Icon(Icons.person_outlined),
                    ),
                    textInputAction: .next,
                    autofillHints: const [AutofillHints.name],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return t.auth.validation.nameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: t.auth.email,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    keyboardType: .emailAddress,
                    textInputAction: .next,
                    autofillHints: const [AutofillHints.email],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return t.auth.validation.emailRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: t.auth.password,
                      prefixIcon: const Icon(Icons.lock_outlined),
                    ),
                    obscureText: true,
                    textInputAction: .done,
                    autofillHints: const [AutofillHints.newPassword],
                    onFieldSubmitted: (_) => _onRegister(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t.auth.validation.passwordRequired;
                      }
                      if (value.length < 8) {
                        return t.auth.validation.passwordTooShort;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    // ignore: avoid-passing-async-when-sync-expected
                    onPressed: isLoading ? null : _onRegister,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(t.auth.register),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => context.router.replace(const LoginRoute()),
                    child: Text(t.auth.hasAccountLogin),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
