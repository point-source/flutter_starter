// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'user_dto.dart';

class UserDtoMapper extends ClassMapperBase<UserDto> {
  UserDtoMapper._();

  static UserDtoMapper? _instance;
  static UserDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UserDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'UserDto';

  static String _$id(UserDto v) => v.id;
  static const Field<UserDto, String> _f$id = Field('id', _$id);
  static String _$email(UserDto v) => v.email;
  static const Field<UserDto, String> _f$email = Field('email', _$email);
  static String _$name(UserDto v) => v.name;
  static const Field<UserDto, String> _f$name = Field('name', _$name);
  static String? _$avatarUrl(UserDto v) => v.avatarUrl;
  static const Field<UserDto, String> _f$avatarUrl = Field(
    'avatarUrl',
    _$avatarUrl,
    opt: true,
  );

  @override
  final MappableFields<UserDto> fields = const {
    #id: _f$id,
    #email: _f$email,
    #name: _f$name,
    #avatarUrl: _f$avatarUrl,
  };

  static UserDto _instantiate(DecodingData data) {
    return UserDto(
      id: data.dec(_f$id),
      email: data.dec(_f$email),
      name: data.dec(_f$name),
      avatarUrl: data.dec(_f$avatarUrl),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static UserDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<UserDto>(map);
  }

  static UserDto fromJson(String json) {
    return ensureInitialized().decodeJson<UserDto>(json);
  }
}

mixin UserDtoMappable {
  String toJson() {
    return UserDtoMapper.ensureInitialized().encodeJson<UserDto>(
      this as UserDto,
    );
  }

  Map<String, dynamic> toMap() {
    return UserDtoMapper.ensureInitialized().encodeMap<UserDto>(
      this as UserDto,
    );
  }

  UserDtoCopyWith<UserDto, UserDto, UserDto> get copyWith =>
      _UserDtoCopyWithImpl<UserDto, UserDto>(
        this as UserDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return UserDtoMapper.ensureInitialized().stringifyValue(this as UserDto);
  }

  @override
  bool operator ==(Object other) {
    return UserDtoMapper.ensureInitialized().equalsValue(
      this as UserDto,
      other,
    );
  }

  @override
  int get hashCode {
    return UserDtoMapper.ensureInitialized().hashValue(this as UserDto);
  }
}

extension UserDtoValueCopy<$R, $Out> on ObjectCopyWith<$R, UserDto, $Out> {
  UserDtoCopyWith<$R, UserDto, $Out> get $asUserDto =>
      $base.as((v, t, t2) => _UserDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class UserDtoCopyWith<$R, $In extends UserDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? id, String? email, String? name, String? avatarUrl});
  UserDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _UserDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, UserDto, $Out>
    implements UserDtoCopyWith<$R, UserDto, $Out> {
  _UserDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<UserDto> $mapper =
      UserDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? email,
    String? name,
    Object? avatarUrl = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (email != null) #email: email,
      if (name != null) #name: name,
      if (avatarUrl != $none) #avatarUrl: avatarUrl,
    }),
  );
  @override
  UserDto $make(CopyWithData data) => UserDto(
    id: data.get(#id, or: $value.id),
    email: data.get(#email, or: $value.email),
    name: data.get(#name, or: $value.name),
    avatarUrl: data.get(#avatarUrl, or: $value.avatarUrl),
  );

  @override
  UserDtoCopyWith<$R2, UserDto, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _UserDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

