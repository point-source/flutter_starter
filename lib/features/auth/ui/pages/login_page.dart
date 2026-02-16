/// Login page for email/password authentication.
///
/// Presents a centered, responsive form with email and password fields
/// and a submit button. On failure the error is displayed via a
/// [SnackBar]. A link at the bottom navigates to the registration page.
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_starter/core/env/app_environment.dart';
import 'package:flutter_starter/core/routing/app_router.dart';
import 'package:flutter_starter/features/auth/data/providers/auth_providers.dart';
import 'package:flutter_starter/gen/strings.g.dart';

/// Page that collects credentials and authenticates the user.
///
/// Uses [authStateRepoProvider] to perform the sign-in and watches
/// the provider to react to loading, success, and error states.
@RoutePage()
class LoginPage extends ConsumerStatefulWidget {
  /// Create a [LoginPage].
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    switch (AppEnvironment.authBypass) {
      case 'prefill':
        _emailController.text = AppEnvironment.devEmail;
        _passwordController.text = AppEnvironment.devPassword;
      case 'mock':
        _emailController.text = 'dev@example.com';
        _passwordController.text = 'password';
      default:
        break;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await ref
        .read(authStateRepoProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);

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
                    t.auth.welcomeBack,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: .center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.auth.signInSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: .center,
                  ),
                  const SizedBox(height: 32),
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
                    autofillHints: const [AutofillHints.password],
                    onFieldSubmitted: (_) => _onLogin(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t.auth.validation.passwordRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    // ignore: avoid-passing-async-when-sync-expected
                    onPressed: isLoading ? null : _onLogin,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(t.auth.login),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => context.router.replace(const RegisterRoute()),
                    child: Text(t.auth.noAccountRegister),
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
