// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'update_profile_request.dart';

class UpdateProfileRequestMapper extends ClassMapperBase<UpdateProfileRequest> {
  UpdateProfileRequestMapper._();

  static UpdateProfileRequestMapper? _instance;
  static UpdateProfileRequestMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UpdateProfileRequestMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'UpdateProfileRequest';

  static String? _$name(UpdateProfileRequest v) => v.name;
  static const Field<UpdateProfileRequest, String> _f$name =
      Field('name', _$name, opt: true);
  static String? _$bio(UpdateProfileRequest v) => v.bio;
  static const Field<UpdateProfileRequest, String> _f$bio =
      Field('bio', _$bio, opt: true);
  static String? _$phoneNumber(UpdateProfileRequest v) => v.phoneNumber;
  static const Field<UpdateProfileRequest, String> _f$phoneNumber =
      Field('phoneNumber', _$phoneNumber, opt: true);

  @override
  final MappableFields<UpdateProfileRequest> fields = const {
    #name: _f$name,
    #bio: _f$bio,
    #phoneNumber: _f$phoneNumber,
  };

  static UpdateProfileRequest _instantiate(DecodingData data) {
    return UpdateProfileRequest(
        name: data.dec(_f$name),
        bio: data.dec(_f$bio),
        phoneNumber: data.dec(_f$phoneNumber));
  }

  @override
  final Function instantiate = _instantiate;

  static UpdateProfileRequest fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<UpdateProfileRequest>(map);
  }

  static UpdateProfileRequest fromJson(String json) {
    return ensureInitialized().decodeJson<UpdateProfileRequest>(json);
  }
}

mixin UpdateProfileRequestMappable {
  String toJson() {
    return UpdateProfileRequestMapper.ensureInitialized()
        .encodeJson<UpdateProfileRequest>(this as UpdateProfileRequest);
  }

  Map<String, dynamic> toMap() {
    return UpdateProfileRequestMapper.ensureInitialized()
        .encodeMap<UpdateProfileRequest>(this as UpdateProfileRequest);
  }

  UpdateProfileRequestCopyWith<UpdateProfileRequest, UpdateProfileRequest,
      UpdateProfileRequest> get copyWith => _UpdateProfileRequestCopyWithImpl<
          UpdateProfileRequest, UpdateProfileRequest>(
      this as UpdateProfileRequest, $identity, $identity);
  @override
  String toString() {
    return UpdateProfileRequestMapper.ensureInitialized()
        .stringifyValue(this as UpdateProfileRequest);
  }

  @override
  bool operator ==(Object other) {
    return UpdateProfileRequestMapper.ensureInitialized()
        .equalsValue(this as UpdateProfileRequest, other);
  }

  @override
  int get hashCode {
    return UpdateProfileRequestMapper.ensureInitialized()
        .hashValue(this as UpdateProfileRequest);
  }
}

extension UpdateProfileRequestValueCopy<$R, $Out>
    on ObjectCopyWith<$R, UpdateProfileRequest, $Out> {
  UpdateProfileRequestCopyWith<$R, UpdateProfileRequest, $Out>
      get $asUpdateProfileRequest => $base.as(
          (v, t, t2) => _UpdateProfileRequestCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class UpdateProfileRequestCopyWith<
    $R,
    $In extends UpdateProfileRequest,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? name, String? bio, String? phoneNumber});
  UpdateProfileRequestCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _UpdateProfileRequestCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, UpdateProfileRequest, $Out>
    implements UpdateProfileRequestCopyWith<$R, UpdateProfileRequest, $Out> {
  _UpdateProfileRequestCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<UpdateProfileRequest> $mapper =
      UpdateProfileRequestMapper.ensureInitialized();
  @override
  $R call(
          {Object? name = $none,
          Object? bio = $none,
          Object? phoneNumber = $none}) =>
      $apply(FieldCopyWithData({
        if (name != $none) #name: name,
        if (bio != $none) #bio: bio,
        if (phoneNumber != $none) #phoneNumber: phoneNumber
      }));
  @override
  UpdateProfileRequest $make(CopyWithData data) => UpdateProfileRequest(
      name: data.get(#name, or: $value.name),
      bio: data.get(#bio, or: $value.bio),
      phoneNumber: data.get(#phoneNumber, or: $value.phoneNumber));

  @override
  UpdateProfileRequestCopyWith<$R2, UpdateProfileRequest, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _UpdateProfileRequestCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
