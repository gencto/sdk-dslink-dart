// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unsubscribe_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UnsubscribeRequest _$UnsubscribeRequestFromJson(Map<String, dynamic> json) {
  return _UnsubscribeRequest.fromJson(json);
}

/// @nodoc
mixin _$UnsubscribeRequest {
  int get rid => throw _privateConstructorUsedError;
  List<int> get sids => throw _privateConstructorUsedError;

  /// Serializes this UnsubscribeRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UnsubscribeRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UnsubscribeRequestCopyWith<UnsubscribeRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UnsubscribeRequestCopyWith<$Res> {
  factory $UnsubscribeRequestCopyWith(
    UnsubscribeRequest value,
    $Res Function(UnsubscribeRequest) then,
  ) = _$UnsubscribeRequestCopyWithImpl<$Res, UnsubscribeRequest>;
  @useResult
  $Res call({int rid, List<int> sids});
}

/// @nodoc
class _$UnsubscribeRequestCopyWithImpl<$Res, $Val extends UnsubscribeRequest>
    implements $UnsubscribeRequestCopyWith<$Res> {
  _$UnsubscribeRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UnsubscribeRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rid = null, Object? sids = null}) {
    return _then(
      _value.copyWith(
            rid: null == rid
                ? _value.rid
                : rid // ignore: cast_nullable_to_non_nullable
                      as int,
            sids: null == sids
                ? _value.sids
                : sids // ignore: cast_nullable_to_non_nullable
                      as List<int>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UnsubscribeRequestImplCopyWith<$Res>
    implements $UnsubscribeRequestCopyWith<$Res> {
  factory _$$UnsubscribeRequestImplCopyWith(
    _$UnsubscribeRequestImpl value,
    $Res Function(_$UnsubscribeRequestImpl) then,
  ) = __$$UnsubscribeRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int rid, List<int> sids});
}

/// @nodoc
class __$$UnsubscribeRequestImplCopyWithImpl<$Res>
    extends _$UnsubscribeRequestCopyWithImpl<$Res, _$UnsubscribeRequestImpl>
    implements _$$UnsubscribeRequestImplCopyWith<$Res> {
  __$$UnsubscribeRequestImplCopyWithImpl(
    _$UnsubscribeRequestImpl _value,
    $Res Function(_$UnsubscribeRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UnsubscribeRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rid = null, Object? sids = null}) {
    return _then(
      _$UnsubscribeRequestImpl(
        rid: null == rid
            ? _value.rid
            : rid // ignore: cast_nullable_to_non_nullable
                  as int,
        sids: null == sids
            ? _value._sids
            : sids // ignore: cast_nullable_to_non_nullable
                  as List<int>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UnsubscribeRequestImpl implements _UnsubscribeRequest {
  const _$UnsubscribeRequestImpl({
    required this.rid,
    required final List<int> sids,
  }) : _sids = sids;

  factory _$UnsubscribeRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UnsubscribeRequestImplFromJson(json);

  @override
  final int rid;
  final List<int> _sids;
  @override
  List<int> get sids {
    if (_sids is EqualUnmodifiableListView) return _sids;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sids);
  }

  @override
  String toString() {
    return 'UnsubscribeRequest(rid: $rid, sids: $sids)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnsubscribeRequestImpl &&
            (identical(other.rid, rid) || other.rid == rid) &&
            const DeepCollectionEquality().equals(other._sids, _sids));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, rid, const DeepCollectionEquality().hash(_sids));

  /// Create a copy of UnsubscribeRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnsubscribeRequestImplCopyWith<_$UnsubscribeRequestImpl> get copyWith =>
      __$$UnsubscribeRequestImplCopyWithImpl<_$UnsubscribeRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UnsubscribeRequestImplToJson(this);
  }
}

abstract class _UnsubscribeRequest implements UnsubscribeRequest {
  const factory _UnsubscribeRequest({
    required final int rid,
    required final List<int> sids,
  }) = _$UnsubscribeRequestImpl;

  factory _UnsubscribeRequest.fromJson(Map<String, dynamic> json) =
      _$UnsubscribeRequestImpl.fromJson;

  @override
  int get rid;
  @override
  List<int> get sids;

  /// Create a copy of UnsubscribeRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnsubscribeRequestImplCopyWith<_$UnsubscribeRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
