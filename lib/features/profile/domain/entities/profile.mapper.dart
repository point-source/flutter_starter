// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'profile.dart';

class ProfileMapper extends ClassMapperBase<Profile> {
  ProfileMapper._();

  static ProfileMapper? _instance;
  static ProfileMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ProfileMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Profile';

  static String _$id(Profile v) => v.id;
  static const Field<Profile, String> _f$id = Field('id', _$id);
  static String _$email(Profile v) => v.email;
  static const Field<Profile, String> _f$email = Field('email', _$email);
  static String _$name(Profile v) => v.name;
  static const Field<Profile, String> _f$name = Field('name', _$name);
  static String? _$avatarUrl(Profile v) => v.avatarUrl;
  static const Field<Profile, String> _f$avatarUrl = Field(
    'avatarUrl',
    _$avatarUrl,
    opt: true,
  );
  static String? _$bio(Profile v) => v.bio;
  static const Field<Profile, String> _f$bio = Field('bio', _$bio, opt: true);
  static String? _$phoneNumber(Profile v) => v.phoneNumber;
  static const Field<Profile, String> _f$phoneNumber = Field(
    'phoneNumber',
    _$phoneNumber,
    opt: true,
  );

  @override
  final MappableFields<Profile> fields = const {
    #id: _f$id,
    #email: _f$email,
    #name: _f$name,
    #avatarUrl: _f$avatarUrl,
    #bio: _f$bio,
    #phoneNumber: _f$phoneNumber,
  };

  static Profile _instantiate(DecodingData data) {
    return Profile(
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

  static Profile fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Profile>(map);
  }

  static Profile fromJson(String json) {
    return ensureInitialized().decodeJson<Profile>(json);
  }
}

mixin ProfileMappable {
  String toJson() {
    return ProfileMapper.ensureInitialized().encodeJson<Profile>(
      this as Profile,
    );
  }

  Map<String, dynamic> toMap() {
    return ProfileMapper.ensureInitialized().encodeMap<Profile>(
      this as Profile,
    );
  }

  ProfileCopyWith<Profile, Profile, Profile> get copyWith =>
      _ProfileCopyWithImpl<Profile, Profile>(
        this as Profile,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ProfileMapper.ensureInitialized().stringifyValue(this as Profile);
  }

  @override
  bool operator ==(Object other) {
    return ProfileMapper.ensureInitialized().equalsValue(
      this as Profile,
      other,
    );
  }

  @override
  int get hashCode {
    return ProfileMapper.ensureInitialized().hashValue(this as Profile);
  }
}

extension ProfileValueCopy<$R, $Out> on ObjectCopyWith<$R, Profile, $Out> {
  ProfileCopyWith<$R, Profile, $Out> get $asProfile =>
      $base.as((v, t, t2) => _ProfileCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ProfileCopyWith<$R, $In extends Profile, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    String? bio,
    String? phoneNumber,
  });
  ProfileCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ProfileCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Profile, $Out>
    implements ProfileCopyWith<$R, Profile, $Out> {
  _ProfileCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Profile> $mapper =
      ProfileMapper.ensureInitialized();
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
  Profile $make(CopyWithData data) => Profile(
    id: data.get(#id, or: $value.id),
    email: data.get(#email, or: $value.email),
    name: data.get(#name, or: $value.name),
    avatarUrl: data.get(#avatarUrl, or: $value.avatarUrl),
    bio: data.get(#bio, or: $value.bio),
    phoneNumber: data.get(#phoneNumber, or: $value.phoneNumber),
  );

  @override
  ProfileCopyWith<$R2, Profile, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ProfileCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
