// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'list_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ListRequest _$ListRequestFromJson(Map<String, dynamic> json) {
  return _ListRequest.fromJson(json);
}

/// @nodoc
mixin _$ListRequest {
  int get rid => throw _privateConstructorUsedError;
  String get path => throw _privateConstructorUsedError;

  /// Serializes this ListRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ListRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ListRequestCopyWith<ListRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListRequestCopyWith<$Res> {
  factory $ListRequestCopyWith(
    ListRequest value,
    $Res Function(ListRequest) then,
  ) = _$ListRequestCopyWithImpl<$Res, ListRequest>;
  @useResult
  $Res call({int rid, String path});
}

/// @nodoc
class _$ListRequestCopyWithImpl<$Res, $Val extends ListRequest>
    implements $ListRequestCopyWith<$Res> {
  _$ListRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ListRequest
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
abstract class _$$ListRequestImplCopyWith<$Res>
    implements $ListRequestCopyWith<$Res> {
  factory _$$ListRequestImplCopyWith(
    _$ListRequestImpl value,
    $Res Function(_$ListRequestImpl) then,
  ) = __$$ListRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int rid, String path});
}

/// @nodoc
class __$$ListRequestImplCopyWithImpl<$Res>
    extends _$ListRequestCopyWithImpl<$Res, _$ListRequestImpl>
    implements _$$ListRequestImplCopyWith<$Res> {
  __$$ListRequestImplCopyWithImpl(
    _$ListRequestImpl _value,
    $Res Function(_$ListRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ListRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rid = null, Object? path = null}) {
    return _then(
      _$ListRequestImpl(
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
class _$ListRequestImpl implements _ListRequest {
  const _$ListRequestImpl({required this.rid, required this.path});

  factory _$ListRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ListRequestImplFromJson(json);

  @override
  final int rid;
  @override
  final String path;

  @override
  String toString() {
    return 'ListRequest(rid: $rid, path: $path)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListRequestImpl &&
            (identical(other.rid, rid) || other.rid == rid) &&
            (identical(other.path, path) || other.path == path));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, rid, path);

  /// Create a copy of ListRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ListRequestImplCopyWith<_$ListRequestImpl> get copyWith =>
      __$$ListRequestImplCopyWithImpl<_$ListRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ListRequestImplToJson(this);
  }
}

abstract class _ListRequest implements ListRequest {
  const factory _ListRequest({
    required final int rid,
    required final String path,
  }) = _$ListRequestImpl;

  factory _ListRequest.fromJson(Map<String, dynamic> json) =
      _$ListRequestImpl.fromJson;

  @override
  int get rid;
  @override
  String get path;

  /// Create a copy of ListRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ListRequestImplCopyWith<_$ListRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
