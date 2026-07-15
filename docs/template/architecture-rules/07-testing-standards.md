# Architecture Rule 07: Testing Standards

## Overview

Tests use **mocktail** for mocking, mirror the `lib/` directory structure, and follow a consistent arrange/act/assert pattern. Tests are organized by layer: repository tests, ViewModel tests, and widget tests.

## Test Directory Structure

```
test/
  core/
    error/
      result_test.dart
    error/
      result_documentation_test.dart
  features/
    auth/
      data/
        providers/
          auth_providers_test.dart    # Tests for AuthStateRepo notifier
        repositories/
          auth_repository_test.dart
    profile/
      data/
        repositories/
          profile_repository_test.dart
      ui/
        view_models/
          profile_view_model_test.dart
    settings/
      data/
        providers/
          theme_preference_test.dart
          locale_preference_test.dart
  helpers/
    test_utils.dart       # ProviderContainer setup helpers
    mocks.dart            # Shared mock classes
    fakes.dart            # Fake data factories
```

## Test Helpers

### Creating a ProviderContainer

```dart
// test/helpers/test_utils.dart
ProviderContainer createContainer({
  List<Override> overrides = const [],
}) {
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  return container;
}
```

### Shared Mocks

```dart
// test/helpers/mocks.dart
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}
class MockProfileRepository extends Mock implements IProfileRepository {}
class MockAuthClient extends Mock implements ProjectAuthClient {}
class MockTokenStorage extends Mock implements ITokenStorage {}
```

### Fake Data

```dart
// test/helpers/fakes.dart
class FakeUser {
  static User create({
    String id = 'user-1',
    String email = 'test@example.com',
    String name = 'Test User',
    String? avatarUrl,
  }) => User(id: id, email: email, name: name, avatarUrl: avatarUrl);
}
```

## Repository Tests

Test that repositories correctly map service responses to `Result` values:

```dart
void main() {
  late MockAuthClient mockClient;
  late MockTokenStorage mockTokenStorage;
  late AuthRepository repository;

  setUp(() {
    mockClient = MockAuthClient();
    mockTokenStorage = MockTokenStorage();
    repository = AuthRepository(mockClient, mockTokenStorage);
  });

  group('login', () {
    test('returns Success with User on successful login', () async {
      // Arrange
      when(() => mockClient.login(any(), any()))
          .thenAnswer((_) async => ProjectAuthRecord(/* ... */));
      when(() => mockTokenStorage.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          )).thenAnswer((_) async {});

      // Act
      final result = await repository.login('test@example.com', 'password');

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.getOrNull()?.email, equals('test@example.com'));
      verify(() => mockTokenStorage.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          )).called(1);
    });

    test('returns Err with InvalidCredentials on 401', () async {
      // Arrange
      when(() => mockClient.login(any(), any()))
          .thenThrow(const ProjectInvalidCredentials());

      // Act
      final result = await repository.login('test@example.com', 'wrong');

      // Assert
      expect(result.isFailure, isTrue);
      result.when(
        success: (_) => fail('Expected failure'),
        failure: (f) => expect(f, isA<InvalidCredentials>()),
      );
    });
  });
}
```

## Notifier / ViewModel Tests

Test notifiers (from `data/providers/` or `ui/view_models/`) using `ProviderContainer` with mock overrides. Override the repository provider from `data/providers/`:

```dart
void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  test('login sets state to authenticated on success', () async {
    // Arrange
    final user = FakeUser.create();
    when(() => mockRepository.login(any(), any()))
        .thenAnswer((_) async => Success(user));
    when(() => mockRepository.getCurrentUser())
        .thenAnswer((_) async => const Success(null));

    final container = createContainer(
      overrides: [authRepositoryProvider.overrideWithValue(mockRepository)],
    );

    // Act
    final notifier = container.read(authStateRepoProvider.notifier);
    await notifier.login('test@example.com', 'password');

    // Assert
    final state = container.read(authStateRepoProvider);
    expect(state.value?.isAuthenticated, isTrue);
    expect(state.value?.user?.email, equals('test@example.com'));
  });
}
```

## Widget Tests

Test widgets by wrapping in `ProviderScope` with mock overrides:

```dart
testWidgets('shows error message on login failure', (tester) async {
  // Arrange
  final mockRepository = MockAuthRepository();
  when(() => mockRepository.getCurrentUser())
      .thenAnswer((_) async => const Success(null));

  // Act
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: const MaterialApp(home: LoginPage()),
    ),
  );

  // Assert
  expect(find.byType(LoginPage), findsOneWidget);
});
```

## Coverage Targets

| Layer | Target | Rationale |
|-------|--------|-----------|
| Repositories | High | Core business logic mapping |
| ViewModels | High | State management logic |
| Domain entities | Medium | Value equality, computed properties |
| Widgets | Medium | Key interactions and error states |
| Selected source adapters | Appropriate to risk | Source integration and mapping edge cases |

## DO

- Use `mocktail` for all mocking (not mockito -- no code generation needed).
- Follow arrange/act/assert structure in every test.
- Use `setUp` for common mock initialization.
- Use `createContainer` helper with `addTearDown` for proper cleanup.
- Register `setUpAll` fallback values for mocktail when using `any()` with custom types.
- Test both success and failure paths for every repository method.

## DO NOT

- Do not test generated code (`.g.dart`, `.mapper.dart`, `.gr.dart`).
- Do not make real SDK, database, filesystem, or network calls in unit tests --
  fake or mock the selected source.
- Do not share mutable state between tests -- use `setUp` for fresh instances.
- Do not test private methods directly -- test through the public API.
- Do not write tests that depend on execution order.
