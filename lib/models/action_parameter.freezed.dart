// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'action_parameter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ActionParameter _$ActionParameterFromJson(Map<String, dynamic> json) {
  return _ActionParameter.fromJson(json);
}

/// @nodoc
mixin _$ActionParameter {
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String? get editor => throw _privateConstructorUsedError;
  dynamic get defaultValue => throw _privateConstructorUsedError;
  dynamic get min => throw _privateConstructorUsedError;
  dynamic get max => throw _privateConstructorUsedError;
  List<dynamic>? get enumValues => throw _privateConstructorUsedError;

  /// Serializes this ActionParameter to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActionParameter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActionParameterCopyWith<ActionParameter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActionParameterCopyWith<$Res> {
  factory $ActionParameterCopyWith(
    ActionParameter value,
    $Res Function(ActionParameter) then,
  ) = _$ActionParameterCopyWithImpl<$Res, ActionParameter>;
  @useResult
  $Res call({
    String name,
    String type,
    String? editor,
    dynamic defaultValue,
    dynamic min,
    dynamic max,
    List<dynamic>? enumValues,
  });
}

/// @nodoc
class _$ActionParameterCopyWithImpl<$Res, $Val extends ActionParameter>
    implements $ActionParameterCopyWith<$Res> {
  _$ActionParameterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActionParameter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? editor = freezed,
    Object? defaultValue = freezed,
    Object? min = freezed,
    Object? max = freezed,
    Object? enumValues = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            editor: freezed == editor
                ? _value.editor
                : editor // ignore: cast_nullable_to_non_nullable
                      as String?,
            defaultValue: freezed == defaultValue
                ? _value.defaultValue
                : defaultValue // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            min: freezed == min
                ? _value.min
                : min // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            max: freezed == max
                ? _value.max
                : max // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            enumValues: freezed == enumValues
                ? _value.enumValues
                : enumValues // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ActionParameterImplCopyWith<$Res>
    implements $ActionParameterCopyWith<$Res> {
  factory _$$ActionParameterImplCopyWith(
    _$ActionParameterImpl value,
    $Res Function(_$ActionParameterImpl) then,
  ) = __$$ActionParameterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String type,
    String? editor,
    dynamic defaultValue,
    dynamic min,
    dynamic max,
    List<dynamic>? enumValues,
  });
}

/// @nodoc
class __$$ActionParameterImplCopyWithImpl<$Res>
    extends _$ActionParameterCopyWithImpl<$Res, _$ActionParameterImpl>
    implements _$$ActionParameterImplCopyWith<$Res> {
  __$$ActionParameterImplCopyWithImpl(
    _$ActionParameterImpl _value,
    $Res Function(_$ActionParameterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActionParameter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? editor = freezed,
    Object? defaultValue = freezed,
    Object? min = freezed,
    Object? max = freezed,
    Object? enumValues = freezed,
  }) {
    return _then(
      _$ActionParameterImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        editor: freezed == editor
            ? _value.editor
            : editor // ignore: cast_nullable_to_non_nullable
                  as String?,
        defaultValue: freezed == defaultValue
            ? _value.defaultValue
            : defaultValue // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        min: freezed == min
            ? _value.min
            : min // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        max: freezed == max
            ? _value.max
            : max // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        enumValues: freezed == enumValues
            ? _value._enumValues
            : enumValues // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ActionParameterImpl implements _ActionParameter {
  const _$ActionParameterImpl({
    required this.name,
    required this.type,
    this.editor,
    this.defaultValue,
    this.min,
    this.max,
    final List<dynamic>? enumValues,
  }) : _enumValues = enumValues;

  factory _$ActionParameterImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActionParameterImplFromJson(json);

  @override
  final String name;
  @override
  final String type;
  @override
  final String? editor;
  @override
  final dynamic defaultValue;
  @override
  final dynamic min;
  @override
  final dynamic max;
  final List<dynamic>? _enumValues;
  @override
  List<dynamic>? get enumValues {
    final value = _enumValues;
    if (value == null) return null;
    if (_enumValues is EqualUnmodifiableListView) return _enumValues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ActionParameter(name: $name, type: $type, editor: $editor, defaultValue: $defaultValue, min: $min, max: $max, enumValues: $enumValues)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActionParameterImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.editor, editor) || other.editor == editor) &&
            const DeepCollectionEquality().equals(
              other.defaultValue,
              defaultValue,
            ) &&
            const DeepCollectionEquality().equals(other.min, min) &&
            const DeepCollectionEquality().equals(other.max, max) &&
            const DeepCollectionEquality().equals(
              other._enumValues,
              _enumValues,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    type,
    editor,
    const DeepCollectionEquality().hash(defaultValue),
    const DeepCollectionEquality().hash(min),
    const DeepCollectionEquality().hash(max),
    const DeepCollectionEquality().hash(_enumValues),
  );

  /// Create a copy of ActionParameter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActionParameterImplCopyWith<_$ActionParameterImpl> get copyWith =>
      __$$ActionParameterImplCopyWithImpl<_$ActionParameterImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ActionParameterImplToJson(this);
  }
}

abstract class _ActionParameter implements ActionParameter {
  const factory _ActionParameter({
    required final String name,
    required final String type,
    final String? editor,
    final dynamic defaultValue,
    final dynamic min,
    final dynamic max,
    final List<dynamic>? enumValues,
  }) = _$ActionParameterImpl;

  factory _ActionParameter.fromJson(Map<String, dynamic> json) =
      _$ActionParameterImpl.fromJson;

  @override
  String get name;
  @override
  String get type;
  @override
  String? get editor;
  @override
  dynamic get defaultValue;
  @override
  dynamic get min;
  @override
  dynamic get max;
  @override
  List<dynamic>? get enumValues;

  /// Create a copy of ActionParameter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActionParameterImplCopyWith<_$ActionParameterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
