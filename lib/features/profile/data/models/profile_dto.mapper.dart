// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'profile_dto.dart';

class ProfileDtoMapper extends ClassMapperBase<ProfileDto> {
  ProfileDtoMapper._();

  static ProfileDtoMapper? _instance;
  static ProfileDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ProfileDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ProfileDto';

  static String _$id(ProfileDto v) => v.id;
  static const Field<ProfileDto, String> _f$id = Field('id', _$id);
  static String _$email(ProfileDto v) => v.email;
  static const Field<ProfileDto, String> _f$email = Field('email', _$email);
  static String _$name(ProfileDto v) => v.name;
  static const Field<ProfileDto, String> _f$name = Field('name', _$name);
  static String? _$avatarUrl(ProfileDto v) => v.avatarUrl;
  static const Field<ProfileDto, String> _f$avatarUrl = Field(
    'avatarUrl',
    _$avatarUrl,
    opt: true,
  );
  static String? _$bio(ProfileDto v) => v.bio;
  static const Field<ProfileDto, String> _f$bio = Field(
    'bio',
    _$bio,
    opt: true,
  );
  static String? _$phoneNumber(ProfileDto v) => v.phoneNumber;
  static const Field<ProfileDto, String> _f$phoneNumber = Field(
    'phoneNumber',
    _$phoneNumber,
    opt: true,
  );

  @override
  final MappableFields<ProfileDto> fields = const {
    #id: _f$id,
    #email: _f$email,
    #name: _f$name,
    #avatarUrl: _f$avatarUrl,
    #bio: _f$bio,
    #phoneNumber: _f$phoneNumber,
  };

  static ProfileDto _instantiate(DecodingData data) {
    return ProfileDto(
      id: data.dec(_f$id),
      email: data.dec(_f$email),
      name: data.dec(_f$name),
      avatarUrl: data.dec(_f$avatarUrl),
      bio: data.dec(_f$bio),
      phoneNumber: data.dec(_f$phoneNumber),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ProfileDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ProfileDto>(map);
  }

  static ProfileDto fromJson(String json) {
    return ensureInitialized().decodeJson<ProfileDto>(json);
  }
}

mixin ProfileDtoMappable {
  String toJson() {
    return ProfileDtoMapper.ensureInitialized().encodeJson<ProfileDto>(
      this as ProfileDto,
    );
  }

  Map<String, dynamic> toMap() {
    return ProfileDtoMapper.ensureInitialized().encodeMap<ProfileDto>(
      this as ProfileDto,
    );
  }

  ProfileDtoCopyWith<ProfileDto, ProfileDto, ProfileDto> get copyWith =>
      _ProfileDtoCopyWithImpl<ProfileDto, ProfileDto>(
        this as ProfileDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ProfileDtoMapper.ensureInitialized().stringifyValue(
      this as ProfileDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return ProfileDtoMapper.ensureInitialized().equalsValue(
      this as ProfileDto,
      other,
    );
  }

  @override
  int get hashCode {
    return ProfileDtoMapper.ensureInitialized().hashValue(this as ProfileDto);
  }
}

extension ProfileDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ProfileDto, $Out> {
  ProfileDtoCopyWith<$R, ProfileDto, $Out> get $asProfileDto =>
      $base.as((v, t, t2) => _ProfileDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ProfileDtoCopyWith<$R, $In extends ProfileDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    String? bio,
    String? phoneNumber,
  });
  ProfileDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ProfileDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ProfileDto, $Out>
    implements ProfileDtoCopyWith<$R, ProfileDto, $Out> {
  _ProfileDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ProfileDto> $mapper =
      ProfileDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? email,
    String? name,
    Object? avatarUrl = $none,
    Object? bio = $none,
    Object? phoneNumber = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (email != null) #email: email,
      if (name != null) #name: name,
      if (avatarUrl != $none) #avatarUrl: avatarUrl,
      if (bio != $none) #bio: bio,
      if (phoneNumber != $none) #phoneNumber: phoneNumber,
    }),
  );
  @override
  ProfileDto $make(CopyWithData data) => ProfileDto(
    id: data.get(#id, or: $value.id),
    email: data.get(#email, or: $value.email),
    name: data.get(#name, or: $value.name),
    avatarUrl: data.get(#avatarUrl, or: $value.avatarUrl),
    bio: data.get(#bio, or: $value.bio),
    phoneNumber: data.get(#phoneNumber, or: $value.phoneNumber),
  );

  @override
  ProfileDtoCopyWith<$R2, ProfileDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ProfileDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
