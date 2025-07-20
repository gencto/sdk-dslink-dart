// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'remove_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RemoveRequest _$RemoveRequestFromJson(Map<String, dynamic> json) {
  return _RemoveRequest.fromJson(json);
}

/// @nodoc
mixin _$RemoveRequest {
  int get rid => throw _privateConstructorUsedError;
  String get path => throw _privateConstructorUsedError;

  /// Serializes this RemoveRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RemoveRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RemoveRequestCopyWith<RemoveRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RemoveRequestCopyWith<$Res> {
  factory $RemoveRequestCopyWith(
    RemoveRequest value,
    $Res Function(RemoveRequest) then,
  ) = _$RemoveRequestCopyWithImpl<$Res, RemoveRequest>;
  @useResult
  $Res call({int rid, String path});
}

/// @nodoc
class _$RemoveRequestCopyWithImpl<$Res, $Val extends RemoveRequest>
    implements $RemoveRequestCopyWith<$Res> {
  _$RemoveRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RemoveRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rid = null, Object? path = null}) {
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RemoveRequestImplCopyWith<$Res>
    implements $RemoveRequestCopyWith<$Res> {
  factory _$$RemoveRequestImplCopyWith(
    _$RemoveRequestImpl value,
    $Res Function(_$RemoveRequestImpl) then,
  ) = __$$RemoveRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int rid, String path});
}

/// @nodoc
class __$$RemoveRequestImplCopyWithImpl<$Res>
    extends _$RemoveRequestCopyWithImpl<$Res, _$RemoveRequestImpl>
    implements _$$RemoveRequestImplCopyWith<$Res> {
  __$$RemoveRequestImplCopyWithImpl(
    _$RemoveRequestImpl _value,
    $Res Function(_$RemoveRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RemoveRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rid = null, Object? path = null}) {
    return _then(
      _$RemoveRequestImpl(
        rid: null == rid
            ? _value.rid
            : rid // ignore: cast_nullable_to_non_nullable
                  as int,
        path: null == path
            ? _value.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RemoveRequestImpl implements _RemoveRequest {
  const _$RemoveRequestImpl({required this.rid, required this.path});

  factory _$RemoveRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$RemoveRequestImplFromJson(json);

  @override
  final int rid;
  @override
  final String path;

  @override
  String toString() {
    return 'RemoveRequest(rid: $rid, path: $path)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RemoveRequestImpl &&
            (identical(other.rid, rid) || other.rid == rid) &&
            (identical(other.path, path) || other.path == path));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, rid, path);

  /// Create a copy of RemoveRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RemoveRequestImplCopyWith<_$RemoveRequestImpl> get copyWith =>
      __$$RemoveRequestImplCopyWithImpl<_$RemoveRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RemoveRequestImplToJson(this);
  }
}

abstract class _RemoveRequest implements RemoveRequest {
  const factory _RemoveRequest({
    required final int rid,
    required final String path,
  }) = _$RemoveRequestImpl;

  factory _RemoveRequest.fromJson(Map<String, dynamic> json) =
      _$RemoveRequestImpl.fromJson;

  @override
  int get rid;
  @override
  String get path;

  /// Create a copy of RemoveRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RemoveRequestImplCopyWith<_$RemoveRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
