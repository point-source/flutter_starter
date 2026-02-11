/// Retrofit-generated HTTP client for profile API endpoints.
///
/// Provides typed methods for fetching and updating the current
/// user's profile. Uses [Dio] for HTTP transport.
library;

import 'package:dio/dio.dart';
import 'package:flutter_starter/features/profile/data/models/profile_dto.dart';
import 'package:flutter_starter/features/profile/data/models/update_profile_request.dart';
import 'package:retrofit/retrofit.dart';

part 'profile_service.g.dart';

/// HTTP client for the profile API.
@RestApi()
abstract class ProfileService {
  /// Create a [ProfileService] backed by the given [dio] instance.
  factory ProfileService(Dio dio) = _ProfileService;

  /// Fetch the current user's profile.
  @GET('/profile')
  Future<ProfileDto> getProfile();

  /// Update the current user's profile.
  @PUT('/profile')
  Future<ProfileDto> updateProfile(@Body() UpdateProfileRequest request);
}
