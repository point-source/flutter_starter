# Architecture Rule 07: Testing Standards

## Overview

Tests use **mocktail** for mocking, mirror the `lib/` directory structure, and follow a consistent arrange/act/assert pattern. Tests are organized by layer: repository tests, ViewModel tests, and widget tests.

## Test Directory Structure

```
test/
  core/
    error/
      result_test.dart
    network/
      dio_provider_test.dart
      interceptors/
        auth_interceptor_test.dart
        refresh_token_interceptor_test.dart
  features/
    auth/
      data/
        repositories/
          auth_repository_test.dart
      ui/
        view_models/
          auth_view_model_test.dart
    profile/
      data/
        repositories/
          profile_repository_test.dart
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
class MockAuthService extends Mock implements AuthService {}
class MockTokenStorage extends Mock implements ITokenStorage {}
class MockDio extends Mock implements Dio {}
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
  late MockAuthService mockService;
  late MockTokenStorage mockTokenStorage;
  late AuthRepository repository;

  setUp(() {
    mockService = MockAuthService();
    mockTokenStorage = MockTokenStorage();
    repository = AuthRepository(mockService, mockTokenStorage);
  });

  group('login', () {
    test('returns Success with User on successful login', () async {
      // Arrange
      when(() => mockService.login(any()))
          .thenAnswer((_) async => AuthResponse(/* ... */));
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
      when(() => mockService.login(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          error: const ServerException('Unauthorized', statusCode: 401),
        ),
      );

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

## ViewModel Tests

Test ViewModels using `ProviderContainer` with mock overrides:

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
    final notifier = container.read(authViewModelProvider.notifier);
    await notifier.login('test@example.com', 'password');

    // Assert
    final state = container.read(authViewModelProvider);
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
| Services | Low | Generated code, test via integration |
| Interceptors | Medium | Edge cases in auth/refresh flow |

## DO

- Use `mocktail` for all mocking (not mockito -- no code generation needed).
- Follow arrange/act/assert structure in every test.
- Use `setUp` for common mock initialization.
- Use `createContainer` helper with `addTearDown` for proper cleanup.
- Register `setUpAll` fallback values for mocktail when using `any()` with custom types.
- Test both success and failure paths for every repository method.

## DO NOT

- Do not test generated code (`.g.dart`, `.mapper.dart`, `.gr.dart`).
- Do not make real network calls in unit tests -- always mock services.
- Do not share mutable state between tests -- use `setUp` for fresh instances.
- Do not test private methods directly -- test through the public API.
- Do not write tests that depend on execution order.
