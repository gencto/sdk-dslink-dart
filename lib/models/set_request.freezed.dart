// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'set_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SetRequest _$SetRequestFromJson(Map<String, dynamic> json) {
  return _SetRequest.fromJson(json);
}

/// @nodoc
mixin _$SetRequest {
  int get rid => throw _privateConstructorUsedError;
  String get path => throw _privateConstructorUsedError;
  dynamic get value => throw _privateConstructorUsedError;
  String? get permit => throw _privateConstructorUsedError;

  /// Serializes this SetRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SetRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SetRequestCopyWith<SetRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SetRequestCopyWith<$Res> {
  factory $SetRequestCopyWith(
    SetRequest value,
    $Res Function(SetRequest) then,
  ) = _$SetRequestCopyWithImpl<$Res, SetRequest>;
  @useResult
  $Res call({int rid, String path, dynamic value, String? permit});
}

/// @nodoc
class _$SetRequestCopyWithImpl<$Res, $Val extends SetRequest>
    implements $SetRequestCopyWith<$Res> {
  _$SetRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SetRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rid = null,
    Object? path = null,
    Object? value = freezed,
    Object? permit = freezed,
  }) {
    return _then(
      _value.copyWith(
            rid: null == rid
                ? _value.rid
                : rid // ignore: cast_nullable_to_non_nullable
                      as int,
            path: null == path
                ? _value.path
                : path // ignore: cast_nullable_to_non_nullable
                      as String,
            value: freezed == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            permit: freezed == permit
                ? _value.permit
                : permit // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SetRequestImplCopyWith<$Res>
    implements $SetRequestCopyWith<$Res> {
  factory _$$SetRequestImplCopyWith(
    _$SetRequestImpl value,
    $Res Function(_$SetRequestImpl) then,
  ) = __$$SetRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int rid, String path, dynamic value, String? permit});
}

/// @nodoc
class __$$SetRequestImplCopyWithImpl<$Res>
    extends _$SetRequestCopyWithImpl<$Res, _$SetRequestImpl>
    implements _$$SetRequestImplCopyWith<$Res> {
  __$$SetRequestImplCopyWithImpl(
    _$SetRequestImpl _value,
    $Res Function(_$SetRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SetRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rid = null,
    Object? path = null,
    Object? value = freezed,
    Object? permit = freezed,
  }) {
    return _then(
      _$SetRequestImpl(
        rid: null == rid
            ? _value.rid
            : rid // ignore: cast_nullable_to_non_nullable
                  as int,
        path: null == path
            ? _value.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
        value: freezed == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        permit: freezed == permit
            ? _value.permit
            : permit // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SetRequestImpl implements _SetRequest {
  const _$SetRequestImpl({
    required this.rid,
    required this.path,
    required this.value,
    this.permit,
  });

  factory _$SetRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$SetRequestImplFromJson(json);

  @override
  final int rid;
  @override
  final String path;
  @override
  final dynamic value;
  @override
  final String? permit;

  @override
  String toString() {
    return 'SetRequest(rid: $rid, path: $path, value: $value, permit: $permit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SetRequestImpl &&
            (identical(other.rid, rid) || other.rid == rid) &&
            (identical(other.path, path) || other.path == path) &&
            const DeepCollectionEquality().equals(other.value, value) &&
            (identical(other.permit, permit) || other.permit == permit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    rid,
    path,
    const DeepCollectionEquality().hash(value),
    permit,
  );

  /// Create a copy of SetRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SetRequestImplCopyWith<_$SetRequestImpl> get copyWith =>
      __$$SetRequestImplCopyWithImpl<_$SetRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SetRequestImplToJson(this);
  }
}

abstract class _SetRequest implements SetRequest {
  const factory _SetRequest({
    required final int rid,
    required final String path,
    required final dynamic value,
    final String? permit,
  }) = _$SetRequestImpl;

  factory _SetRequest.fromJson(Map<String, dynamic> json) =
      _$SetRequestImpl.fromJson;

  @override
  int get rid;
  @override
  String get path;
  @override
  dynamic get value;
  @override
  String? get permit;

  /// Create a copy of SetRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SetRequestImplCopyWith<_$SetRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
