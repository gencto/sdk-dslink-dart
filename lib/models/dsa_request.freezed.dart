// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dsa_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DsaRequest _$DsaRequestFromJson(Map<String, dynamic> json) {
  return _DsaRequest.fromJson(json);
}

/// @nodoc
mixin _$DsaRequest {
  int get rid => throw _privateConstructorUsedError;
  String get method => throw _privateConstructorUsedError;
  String? get path => throw _privateConstructorUsedError;
  Map<String, dynamic>? get params => throw _privateConstructorUsedError;
  dynamic get value => throw _privateConstructorUsedError;
  List<dynamic>? get paths => throw _privateConstructorUsedError;
  List<dynamic>? get sids => throw _privateConstructorUsedError;
  String? get permit => throw _privateConstructorUsedError;

  /// Serializes this DsaRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DsaRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DsaRequestCopyWith<DsaRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DsaRequestCopyWith<$Res> {
  factory $DsaRequestCopyWith(
    DsaRequest value,
    $Res Function(DsaRequest) then,
  ) = _$DsaRequestCopyWithImpl<$Res, DsaRequest>;
  @useResult
  $Res call({
    int rid,
    String method,
    String? path,
    Map<String, dynamic>? params,
    dynamic value,
    List<dynamic>? paths,
    List<dynamic>? sids,
    String? permit,
  });
}

/// @nodoc
class _$DsaRequestCopyWithImpl<$Res, $Val extends DsaRequest>
    implements $DsaRequestCopyWith<$Res> {
  _$DsaRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DsaRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rid = null,
    Object? method = null,
    Object? path = freezed,
    Object? params = freezed,
    Object? value = freezed,
    Object? paths = freezed,
    Object? sids = freezed,
    Object? permit = freezed,
  }) {
    return _then(
      _value.copyWith(
            rid: null == rid
                ? _value.rid
                : rid // ignore: cast_nullable_to_non_nullable
                      as int,
            method: null == method
                ? _value.method
                : method // ignore: cast_nullable_to_non_nullable
                      as String,
            path: freezed == path
                ? _value.path
                : path // ignore: cast_nullable_to_non_nullable
                      as String?,
            params: freezed == params
                ? _value.params
                : params // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            value: freezed == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            paths: freezed == paths
                ? _value.paths
                : paths // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>?,
            sids: freezed == sids
                ? _value.sids
                : sids // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>?,
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
abstract class _$$DsaRequestImplCopyWith<$Res>
    implements $DsaRequestCopyWith<$Res> {
  factory _$$DsaRequestImplCopyWith(
    _$DsaRequestImpl value,
    $Res Function(_$DsaRequestImpl) then,
  ) = __$$DsaRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int rid,
    String method,
    String? path,
    Map<String, dynamic>? params,
    dynamic value,
    List<dynamic>? paths,
    List<dynamic>? sids,
    String? permit,
  });
}

/// @nodoc
class __$$DsaRequestImplCopyWithImpl<$Res>
    extends _$DsaRequestCopyWithImpl<$Res, _$DsaRequestImpl>
    implements _$$DsaRequestImplCopyWith<$Res> {
  __$$DsaRequestImplCopyWithImpl(
    _$DsaRequestImpl _value,
    $Res Function(_$DsaRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DsaRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rid = null,
    Object? method = null,
    Object? path = freezed,
    Object? params = freezed,
    Object? value = freezed,
    Object? paths = freezed,
    Object? sids = freezed,
    Object? permit = freezed,
  }) {
    return _then(
      _$DsaRequestImpl(
        rid: null == rid
            ? _value.rid
            : rid // ignore: cast_nullable_to_non_nullable
                  as int,
        method: null == method
            ? _value.method
            : method // ignore: cast_nullable_to_non_nullable
                  as String,
        path: freezed == path
            ? _value.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String?,
        params: freezed == params
            ? _value._params
            : params // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        value: freezed == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        paths: freezed == paths
            ? _value._paths
            : paths // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>?,
        sids: freezed == sids
            ? _value._sids
            : sids // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>?,
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
class _$DsaRequestImpl implements _DsaRequest {
  const _$DsaRequestImpl({
    required this.rid,
    required this.method,
    this.path,
    final Map<String, dynamic>? params,
    this.value,
    final List<dynamic>? paths,
    final List<dynamic>? sids,
    this.permit,
  }) : _params = params,
       _paths = paths,
       _sids = sids;

  factory _$DsaRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$DsaRequestImplFromJson(json);

  @override
  final int rid;
  @override
  final String method;
  @override
  final String? path;
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
  final dynamic value;
  final List<dynamic>? _paths;
  @override
  List<dynamic>? get paths {
    final value = _paths;
    if (value == null) return null;
    if (_paths is EqualUnmodifiableListView) return _paths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<dynamic>? _sids;
  @override
  List<dynamic>? get sids {
    final value = _sids;
    if (value == null) return null;
    if (_sids is EqualUnmodifiableListView) return _sids;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? permit;

  @override
  String toString() {
    return 'DsaRequest(rid: $rid, method: $method, path: $path, params: $params, value: $value, paths: $paths, sids: $sids, permit: $permit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DsaRequestImpl &&
            (identical(other.rid, rid) || other.rid == rid) &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.path, path) || other.path == path) &&
            const DeepCollectionEquality().equals(other._params, _params) &&
            const DeepCollectionEquality().equals(other.value, value) &&
            const DeepCollectionEquality().equals(other._paths, _paths) &&
            const DeepCollectionEquality().equals(other._sids, _sids) &&
            (identical(other.permit, permit) || other.permit == permit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    rid,
    method,
    path,
    const DeepCollectionEquality().hash(_params),
    const DeepCollectionEquality().hash(value),
    const DeepCollectionEquality().hash(_paths),
    const DeepCollectionEquality().hash(_sids),
    permit,
  );

  /// Create a copy of DsaRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DsaRequestImplCopyWith<_$DsaRequestImpl> get copyWith =>
      __$$DsaRequestImplCopyWithImpl<_$DsaRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DsaRequestImplToJson(this);
  }
}

abstract class _DsaRequest implements DsaRequest {
  const factory _DsaRequest({
    required final int rid,
    required final String method,
    final String? path,
    final Map<String, dynamic>? params,
    final dynamic value,
    final List<dynamic>? paths,
    final List<dynamic>? sids,
    final String? permit,
  }) = _$DsaRequestImpl;

  factory _DsaRequest.fromJson(Map<String, dynamic> json) =
      _$DsaRequestImpl.fromJson;

  @override
  int get rid;
  @override
  String get method;
  @override
  String? get path;
  @override
  Map<String, dynamic>? get params;
  @override
  dynamic get value;
  @override
  List<dynamic>? get paths;
  @override
  List<dynamic>? get sids;
  @override
  String? get permit;

  /// Create a copy of DsaRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DsaRequestImplCopyWith<_$DsaRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
