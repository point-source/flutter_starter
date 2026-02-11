/// Shared mock classes for use across test suites.
///
/// All mocks use [mocktail] so that stubbing and verification use the
/// `when(() => ...)` / `verify(() => ...)` syntax rather than code
/// generation.
library;

import 'package:flutter_starter/core/storage/token_storage.dart';
import 'package:flutter_starter/features/auth/data/services/auth_service.dart';
import 'package:flutter_starter/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:flutter_starter/features/profile/data/services/profile_service.dart';
import 'package:flutter_starter/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:mocktail/mocktail.dart';

/// Mock implementation of [IAuthRepository].
class MockAuthRepository extends Mock implements IAuthRepository {}

/// Mock implementation of [IProfileRepository].
class MockProfileRepository extends Mock implements IProfileRepository {}

/// Mock implementation of [ITokenStorage].
class MockTokenStorage extends Mock implements ITokenStorage {}

/// Mock implementation of [AuthService].
class MockAuthService extends Mock implements AuthService {}

/// Mock implementation of [ProfileService].
class MockProfileService extends Mock implements ProfileService {}
