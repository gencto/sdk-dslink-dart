// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoke_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InvokeRequest _$InvokeRequestFromJson(Map<String, dynamic> json) {
  return _InvokeRequest.fromJson(json);
}

/// @nodoc
mixin _$InvokeRequest {
  int get rid => throw _privateConstructorUsedError;
  String get path => throw _privateConstructorUsedError;
  Map<String, dynamic>? get params => throw _privateConstructorUsedError;
  String? get permit => throw _privateConstructorUsedError;

  /// Serializes this InvokeRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InvokeRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InvokeRequestCopyWith<InvokeRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvokeRequestCopyWith<$Res> {
  factory $InvokeRequestCopyWith(
    InvokeRequest value,
    $Res Function(InvokeRequest) then,
  ) = _$InvokeRequestCopyWithImpl<$Res, InvokeRequest>;
  @useResult
  $Res call({
    int rid,
    String path,
    Map<String, dynamic>? params,
    String? permit,
  });
}

/// @nodoc
class _$InvokeRequestCopyWithImpl<$Res, $Val extends InvokeRequest>
    implements $InvokeRequestCopyWith<$Res> {
  _$InvokeRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InvokeRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rid = null,
    Object? path = null,
    Object? params = freezed,
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
            params: freezed == params
                ? _value.params
                : params // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
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
abstract class _$$InvokeRequestImplCopyWith<$Res>
    implements $InvokeRequestCopyWith<$Res> {
  factory _$$InvokeRequestImplCopyWith(
    _$InvokeRequestImpl value,
    $Res Function(_$InvokeRequestImpl) then,
  ) = __$$InvokeRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int rid,
    String path,
    Map<String, dynamic>? params,
    String? permit,
  });
}

/// @nodoc
class __$$InvokeRequestImplCopyWithImpl<$Res>
    extends _$InvokeRequestCopyWithImpl<$Res, _$InvokeRequestImpl>
    implements _$$InvokeRequestImplCopyWith<$Res> {
  __$$InvokeRequestImplCopyWithImpl(
    _$InvokeRequestImpl _value,
    $Res Function(_$InvokeRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InvokeRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rid = null,
    Object? path = null,
    Object? params = freezed,
    Object? permit = freezed,
  }) {
    return _then(
      _$InvokeRequestImpl(
        rid: null == rid
            ? _value.rid
            : rid // ignore: cast_nullable_to_non_nullable
                  as int,
        path: null == path
            ? _value.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
        params: freezed == params
            ? _value._params
            : params // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
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
class _$InvokeRequestImpl implements _InvokeRequest {
  const _$InvokeRequestImpl({
    required this.rid,
    required this.path,
    final Map<String, dynamic>? params,
    this.permit,
  }) : _params = params;

  factory _$InvokeRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$InvokeRequestImplFromJson(json);

  @override
  final int rid;
  @override
  final String path;
  final Map<String, dynamic>? _params;
  @override
  Map<String, dynamic>? get params {
    final value = _params;
    if (value == null) return null;
    if (_params is EqualUnmodifiableMapView) return _params;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? permit;

  @override
  String toString() {
    return 'InvokeRequest(rid: $rid, path: $path, params: $params, permit: $permit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvokeRequestImpl &&
            (identical(other.rid, rid) || other.rid == rid) &&
            (identical(other.path, path) || other.path == path) &&
            const DeepCollectionEquality().equals(other._params, _params) &&
            (identical(other.permit, permit) || other.permit == permit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    rid,
    path,
    const DeepCollectionEquality().hash(_params),
    permit,
  );

  /// Create a copy of InvokeRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InvokeRequestImplCopyWith<_$InvokeRequestImpl> get copyWith =>
      __$$InvokeRequestImplCopyWithImpl<_$InvokeRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InvokeRequestImplToJson(this);
  }
}

abstract class _InvokeRequest implements InvokeRequest {
  const factory _InvokeRequest({
    required final int rid,
    required final String path,
    final Map<String, dynamic>? params,
    final String? permit,
  }) = _$InvokeRequestImpl;

  factory _InvokeRequest.fromJson(Map<String, dynamic> json) =
      _$InvokeRequestImpl.fromJson;

  @override
  int get rid;
  @override
  String get path;
  @override
  Map<String, dynamic>? get params;
  @override
  String? get permit;

  /// Create a copy of InvokeRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InvokeRequestImplCopyWith<_$InvokeRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
