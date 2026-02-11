/// Implement [IProfileRepository] by delegating to [ProfileService].
///
/// Catches [DioException]s from the service layer (which carry
/// [AppException]s from [ErrorInterceptor]) and maps them into
/// [Result] values with feature-specific [ProfileFailure] types.
/// Converts DTOs to domain entities via [ProfileMapper].
library;

import 'package:dio/dio.dart';

import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/core/error/failures.dart';
import 'package:flutter_starter/core/error/result.dart';
import 'package:flutter_starter/features/profile/data/mappers/profile_mapper.dart';
import 'package:flutter_starter/features/profile/data/models/update_profile_request.dart';
import 'package:flutter_starter/features/profile/data/services/profile_service.dart';
import 'package:flutter_starter/features/profile/domain/entities/profile.dart';
import 'package:flutter_starter/features/profile/domain/failures/profile_failure.dart';
import 'package:flutter_starter/features/profile/domain/repositories/i_profile_repository.dart';

/// Repository that fetches and updates profiles via the API.
///
/// Wraps every service call in try/catch and returns [Result] values.
/// On success, DTOs are mapped to domain entities. On failure,
/// [DioException] errors (which carry an [AppException] from
/// [ErrorInterceptor]) are mapped to the appropriate [ProfileFailure]
/// or infrastructure [Failure] subtype.
class ProfileRepository implements IProfileRepository {
  /// Create a [ProfileRepository] with the given [_service].
  const ProfileRepository(this._service);

  final ProfileService _service;

  @override
  Future<Result<Profile>> getProfile() async {
    try {
      final dto = await _service.getProfile();
      return Success(dto.toDomain());
    } on DioException catch (e, st) {
      return Err(_mapDioException(e, st));
    } on Exception catch (e, st) {
      return Err(UnexpectedFailure(e, st));
    }
  }

  @override
  Future<Result<Profile>> updateProfile({
    String? name,
    String? bio,
    String? phoneNumber,
  }) async {
    try {
      final dto = await _service.updateProfile(
        UpdateProfileRequest(name: name, bio: bio, phoneNumber: phoneNumber),
      );
      return Success(dto.toDomain());
    } on DioException catch (e, st) {
      return Err(_mapDioException(e, st));
    } on Exception catch (e, st) {
      return Err(UnexpectedFailure(e, st));
    }
  }

  /// Map a [DioException] to the appropriate [Failure].
  ///
  /// The [ErrorInterceptor] wraps the original error as an [AppException]
  /// inside [DioException.error], preserving the HTTP status code.
  Failure _mapDioException(DioException e, StackTrace st) {
    final error = e.error;
    if (error is AppException) {
      return switch (error.statusCode) {
        404 => ProfileNotFound(st),
        422 => ProfileUpdateRejected(error.message, st),
        _ => BadResponse(error.statusCode ?? 500, error.message, st),
      };
    }
    return UnexpectedFailure(e, st);
  }
}
