// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscribe_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SubscribePath _$SubscribePathFromJson(Map<String, dynamic> json) {
  return _SubscribePath.fromJson(json);
}

/// @nodoc
mixin _$SubscribePath {
  String get path => throw _privateConstructorUsedError;
  int get sid => throw _privateConstructorUsedError;
  int? get qos => throw _privateConstructorUsedError;

  /// Serializes this SubscribePath to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubscribePath
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscribePathCopyWith<SubscribePath> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscribePathCopyWith<$Res> {
  factory $SubscribePathCopyWith(
    SubscribePath value,
    $Res Function(SubscribePath) then,
  ) = _$SubscribePathCopyWithImpl<$Res, SubscribePath>;
  @useResult
  $Res call({String path, int sid, int? qos});
}

/// @nodoc
class _$SubscribePathCopyWithImpl<$Res, $Val extends SubscribePath>
    implements $SubscribePathCopyWith<$Res> {
  _$SubscribePathCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscribePath
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? path = null, Object? sid = null, Object? qos = freezed}) {
    return _then(
      _value.copyWith(
            path: null == path
                ? _value.path
                : path // ignore: cast_nullable_to_non_nullable
                      as String,
            sid: null == sid
                ? _value.sid
                : sid // ignore: cast_nullable_to_non_nullable
                      as int,
            qos: freezed == qos
                ? _value.qos
                : qos // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubscribePathImplCopyWith<$Res>
    implements $SubscribePathCopyWith<$Res> {
  factory _$$SubscribePathImplCopyWith(
    _$SubscribePathImpl value,
    $Res Function(_$SubscribePathImpl) then,
  ) = __$$SubscribePathImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String path, int sid, int? qos});
}

/// @nodoc
class __$$SubscribePathImplCopyWithImpl<$Res>
    extends _$SubscribePathCopyWithImpl<$Res, _$SubscribePathImpl>
    implements _$$SubscribePathImplCopyWith<$Res> {
  __$$SubscribePathImplCopyWithImpl(
    _$SubscribePathImpl _value,
    $Res Function(_$SubscribePathImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubscribePath
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? path = null, Object? sid = null, Object? qos = freezed}) {
    return _then(
      _$SubscribePathImpl(
        path: null == path
            ? _value.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
        sid: null == sid
            ? _value.sid
            : sid // ignore: cast_nullable_to_non_nullable
                  as int,
        qos: freezed == qos
            ? _value.qos
            : qos // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubscribePathImpl implements _SubscribePath {
  const _$SubscribePathImpl({required this.path, required this.sid, this.qos});

  factory _$SubscribePathImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscribePathImplFromJson(json);

  @override
  final String path;
  @override
  final int sid;
  @override
  final int? qos;

  @override
  String toString() {
    return 'SubscribePath(path: $path, sid: $sid, qos: $qos)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscribePathImpl &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.sid, sid) || other.sid == sid) &&
            (identical(other.qos, qos) || other.qos == qos));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, path, sid, qos);

  /// Create a copy of SubscribePath
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscribePathImplCopyWith<_$SubscribePathImpl> get copyWith =>
      __$$SubscribePathImplCopyWithImpl<_$SubscribePathImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscribePathImplToJson(this);
  }
}

abstract class _SubscribePath implements SubscribePath {
  const factory _SubscribePath({
    required final String path,
    required final int sid,
    final int? qos,
  }) = _$SubscribePathImpl;

  factory _SubscribePath.fromJson(Map<String, dynamic> json) =
      _$SubscribePathImpl.fromJson;

  @override
  String get path;
  @override
  int get sid;
  @override
  int? get qos;

  /// Create a copy of SubscribePath
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscribePathImplCopyWith<_$SubscribePathImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubscribeRequest _$SubscribeRequestFromJson(Map<String, dynamic> json) {
  return _SubscribeRequest.fromJson(json);
}

/// @nodoc
mixin _$SubscribeRequest {
  int get rid => throw _privateConstructorUsedError;
  List<SubscribePath> get paths => throw _privateConstructorUsedError;

  /// Serializes this SubscribeRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubscribeRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscribeRequestCopyWith<SubscribeRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscribeRequestCopyWith<$Res> {
  factory $SubscribeRequestCopyWith(
    SubscribeRequest value,
    $Res Function(SubscribeRequest) then,
  ) = _$SubscribeRequestCopyWithImpl<$Res, SubscribeRequest>;
  @useResult
  $Res call({int rid, List<SubscribePath> paths});
}

/// @nodoc
class _$SubscribeRequestCopyWithImpl<$Res, $Val extends SubscribeRequest>
    implements $SubscribeRequestCopyWith<$Res> {
  _$SubscribeRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscribeRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rid = null, Object? paths = null}) {
    return _then(
      _value.copyWith(
            rid: null == rid
                ? _value.rid
                : rid // ignore: cast_nullable_to_non_nullable
                      as int,
            paths: null == paths
                ? _value.paths
                : paths // ignore: cast_nullable_to_non_nullable
                      as List<SubscribePath>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubscribeRequestImplCopyWith<$Res>
    implements $SubscribeRequestCopyWith<$Res> {
  factory _$$SubscribeRequestImplCopyWith(
    _$SubscribeRequestImpl value,
    $Res Function(_$SubscribeRequestImpl) then,
  ) = __$$SubscribeRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int rid, List<SubscribePath> paths});
}

/// @nodoc
class __$$SubscribeRequestImplCopyWithImpl<$Res>
    extends _$SubscribeRequestCopyWithImpl<$Res, _$SubscribeRequestImpl>
    implements _$$SubscribeRequestImplCopyWith<$Res> {
  __$$SubscribeRequestImplCopyWithImpl(
    _$SubscribeRequestImpl _value,
    $Res Function(_$SubscribeRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubscribeRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rid = null, Object? paths = null}) {
    return _then(
      _$SubscribeRequestImpl(
        rid: null == rid
            ? _value.rid
            : rid // ignore: cast_nullable_to_non_nullable
                  as int,
        paths: null == paths
            ? _value._paths
            : paths // ignore: cast_nullable_to_non_nullable
                  as List<SubscribePath>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubscribeRequestImpl implements _SubscribeRequest {
  const _$SubscribeRequestImpl({
    required this.rid,
    required final List<SubscribePath> paths,
  }) : _paths = paths;

  factory _$SubscribeRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscribeRequestImplFromJson(json);

  @override
  final int rid;
  final List<SubscribePath> _paths;
  @override
  List<SubscribePath> get paths {
    if (_paths is EqualUnmodifiableListView) return _paths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_paths);
  }

  @override
  String toString() {
    return 'SubscribeRequest(rid: $rid, paths: $paths)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscribeRequestImpl &&
            (identical(other.rid, rid) || other.rid == rid) &&
            const DeepCollectionEquality().equals(other._paths, _paths));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    rid,
    const DeepCollectionEquality().hash(_paths),
  );

  /// Create a copy of SubscribeRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscribeRequestImplCopyWith<_$SubscribeRequestImpl> get copyWith =>
      __$$SubscribeRequestImplCopyWithImpl<_$SubscribeRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscribeRequestImplToJson(this);
  }
}

abstract class _SubscribeRequest implements SubscribeRequest {
  const factory _SubscribeRequest({
    required final int rid,
    required final List<SubscribePath> paths,
  }) = _$SubscribeRequestImpl;

  factory _SubscribeRequest.fromJson(Map<String, dynamic> json) =
      _$SubscribeRequestImpl.fromJson;

  @override
  int get rid;
  @override
  List<SubscribePath> get paths;

  /// Create a copy of SubscribeRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscribeRequestImplCopyWith<_$SubscribeRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
