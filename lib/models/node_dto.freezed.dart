// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'node_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NodeDTO _$NodeDTOFromJson(Map<String, dynamic> json) {
  return _NodeDTO.fromJson(json);
}

/// @nodoc
mixin _$NodeDTO {
  String get name => throw _privateConstructorUsedError;
  dynamic get value => throw _privateConstructorUsedError;
  Map<String, dynamic>? get attributes => throw _privateConstructorUsedError;
  bool? get action => throw _privateConstructorUsedError;
  List<NodeDTO>? get children => throw _privateConstructorUsedError;

  /// Serializes this NodeDTO to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NodeDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NodeDTOCopyWith<NodeDTO> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NodeDTOCopyWith<$Res> {
  factory $NodeDTOCopyWith(NodeDTO value, $Res Function(NodeDTO) then) =
      _$NodeDTOCopyWithImpl<$Res, NodeDTO>;
  @useResult
  $Res call({
    String name,
    dynamic value,
    Map<String, dynamic>? attributes,
    bool? action,
    List<NodeDTO>? children,
  });
}

/// @nodoc
class _$NodeDTOCopyWithImpl<$Res, $Val extends NodeDTO>
    implements $NodeDTOCopyWith<$Res> {
  _$NodeDTOCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NodeDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? value = freezed,
    Object? attributes = freezed,
    Object? action = freezed,
    Object? children = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            value: freezed == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            attributes: freezed == attributes
                ? _value.attributes
                : attributes // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            action: freezed == action
                ? _value.action
                : action // ignore: cast_nullable_to_non_nullable
                      as bool?,
            children: freezed == children
                ? _value.children
                : children // ignore: cast_nullable_to_non_nullable
                      as List<NodeDTO>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NodeDTOImplCopyWith<$Res> implements $NodeDTOCopyWith<$Res> {
  factory _$$NodeDTOImplCopyWith(
    _$NodeDTOImpl value,
    $Res Function(_$NodeDTOImpl) then,
  ) = __$$NodeDTOImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    dynamic value,
    Map<String, dynamic>? attributes,
    bool? action,
    List<NodeDTO>? children,
  });
}

/// @nodoc
class __$$NodeDTOImplCopyWithImpl<$Res>
    extends _$NodeDTOCopyWithImpl<$Res, _$NodeDTOImpl>
    implements _$$NodeDTOImplCopyWith<$Res> {
  __$$NodeDTOImplCopyWithImpl(
    _$NodeDTOImpl _value,
    $Res Function(_$NodeDTOImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NodeDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? value = freezed,
    Object? attributes = freezed,
    Object? action = freezed,
    Object? children = freezed,
  }) {
    return _then(
      _$NodeDTOImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        value: freezed == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        attributes: freezed == attributes
            ? _value._attributes
            : attributes // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        action: freezed == action
            ? _value.action
            : action // ignore: cast_nullable_to_non_nullable
                  as bool?,
        children: freezed == children
            ? _value._children
            : children // ignore: cast_nullable_to_non_nullable
                  as List<NodeDTO>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NodeDTOImpl implements _NodeDTO {
  const _$NodeDTOImpl({
    required this.name,
    this.value,
    final Map<String, dynamic>? attributes,
    this.action,
    final List<NodeDTO>? children,
  }) : _attributes = attributes,
       _children = children;

  factory _$NodeDTOImpl.fromJson(Map<String, dynamic> json) =>
      _$$NodeDTOImplFromJson(json);

  @override
  final String name;
  @override
  final dynamic value;
  final Map<String, dynamic>? _attributes;
  @override
  Map<String, dynamic>? get attributes {
    final value = _attributes;
    if (value == null) return null;
    if (_attributes is EqualUnmodifiableMapView) return _attributes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final bool? action;
  final List<NodeDTO>? _children;
  @override
  List<NodeDTO>? get children {
    final value = _children;
    if (value == null) return null;
    if (_children is EqualUnmodifiableListView) return _children;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'NodeDTO(name: $name, value: $value, attributes: $attributes, action: $action, children: $children)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NodeDTOImpl &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other.value, value) &&
            const DeepCollectionEquality().equals(
              other._attributes,
              _attributes,
            ) &&
            (identical(other.action, action) || other.action == action) &&
            const DeepCollectionEquality().equals(other._children, _children));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    const DeepCollectionEquality().hash(value),
    const DeepCollectionEquality().hash(_attributes),
    action,
    const DeepCollectionEquality().hash(_children),
  );

  /// Create a copy of NodeDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NodeDTOImplCopyWith<_$NodeDTOImpl> get copyWith =>
      __$$NodeDTOImplCopyWithImpl<_$NodeDTOImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NodeDTOImplToJson(this);
  }
}

abstract class _NodeDTO implements NodeDTO {
  const factory _NodeDTO({
    required final String name,
    final dynamic value,
    final Map<String, dynamic>? attributes,
    final bool? action,
    final List<NodeDTO>? children,
  }) = _$NodeDTOImpl;

  factory _NodeDTO.fromJson(Map<String, dynamic> json) = _$NodeDTOImpl.fromJson;

  @override
  String get name;
  @override
  dynamic get value;
  @override
  Map<String, dynamic>? get attributes;
  @override
  bool? get action;
  @override
  List<NodeDTO>? get children;

  /// Create a copy of NodeDTO
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NodeDTOImplCopyWith<_$NodeDTOImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
