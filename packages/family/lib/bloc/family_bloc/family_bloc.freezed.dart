// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'family_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FamilyEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FamilyEvent()';
}


}

/// @nodoc
class $FamilyEventCopyWith<$Res>  {
$FamilyEventCopyWith(FamilyEvent _, $Res Function(FamilyEvent) __);
}


/// Adds pattern-matching-related methods to [FamilyEvent].
extension FamilyEventPatterns on FamilyEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Started value)?  started,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Started value)  started,}){
final _that = this;
switch (_that) {
case _Started():
return started(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Started value)?  started,}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,}) {final _that = this;
switch (_that) {
case _Started():
return started();}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _:
  return null;

}
}

}

/// @nodoc


class _Started implements FamilyEvent {
  const _Started();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Started);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FamilyEvent.started()';
}


}




/// @nodoc
mixin _$FamilyState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FamilyState()';
}


}

/// @nodoc
class $FamilyStateCopyWith<$Res>  {
$FamilyStateCopyWith(FamilyState _, $Res Function(FamilyState) __);
}


/// Adds pattern-matching-related methods to [FamilyState].
extension FamilyStatePatterns on FamilyState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( FamilyInitial value)?  initial,TResult Function( FamilyLoading value)?  loading,TResult Function( FamilyLoaded value)?  loaded,TResult Function( FamilyFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case FamilyInitial() when initial != null:
return initial(_that);case FamilyLoading() when loading != null:
return loading(_that);case FamilyLoaded() when loaded != null:
return loaded(_that);case FamilyFailure() when failure != null:
return failure(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( FamilyInitial value)  initial,required TResult Function( FamilyLoading value)  loading,required TResult Function( FamilyLoaded value)  loaded,required TResult Function( FamilyFailure value)  failure,}){
final _that = this;
switch (_that) {
case FamilyInitial():
return initial(_that);case FamilyLoading():
return loading(_that);case FamilyLoaded():
return loaded(_that);case FamilyFailure():
return failure(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( FamilyInitial value)?  initial,TResult? Function( FamilyLoading value)?  loading,TResult? Function( FamilyLoaded value)?  loaded,TResult? Function( FamilyFailure value)?  failure,}){
final _that = this;
switch (_that) {
case FamilyInitial() when initial != null:
return initial(_that);case FamilyLoading() when loading != null:
return loading(_that);case FamilyLoaded() when loaded != null:
return loaded(_that);case FamilyFailure() when failure != null:
return failure(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function()?  loaded,TResult Function( String message)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case FamilyInitial() when initial != null:
return initial();case FamilyLoading() when loading != null:
return loading();case FamilyLoaded() when loaded != null:
return loaded();case FamilyFailure() when failure != null:
return failure(_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function()  loaded,required TResult Function( String message)  failure,}) {final _that = this;
switch (_that) {
case FamilyInitial():
return initial();case FamilyLoading():
return loading();case FamilyLoaded():
return loaded();case FamilyFailure():
return failure(_that.message);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function()?  loaded,TResult? Function( String message)?  failure,}) {final _that = this;
switch (_that) {
case FamilyInitial() when initial != null:
return initial();case FamilyLoading() when loading != null:
return loading();case FamilyLoaded() when loaded != null:
return loaded();case FamilyFailure() when failure != null:
return failure(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class FamilyInitial implements FamilyState {
  const FamilyInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FamilyState.initial()';
}


}




/// @nodoc


class FamilyLoading implements FamilyState {
  const FamilyLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FamilyState.loading()';
}


}




/// @nodoc


class FamilyLoaded implements FamilyState {
  const FamilyLoaded();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyLoaded);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FamilyState.loaded()';
}


}




/// @nodoc


class FamilyFailure implements FamilyState {
  const FamilyFailure({required this.message});
  

 final  String message;

/// Create a copy of FamilyState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyFailureCopyWith<FamilyFailure> get copyWith => _$FamilyFailureCopyWithImpl<FamilyFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'FamilyState.failure(message: $message)';
}


}

/// @nodoc
abstract mixin class $FamilyFailureCopyWith<$Res> implements $FamilyStateCopyWith<$Res> {
  factory $FamilyFailureCopyWith(FamilyFailure value, $Res Function(FamilyFailure) _then) = _$FamilyFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$FamilyFailureCopyWithImpl<$Res>
    implements $FamilyFailureCopyWith<$Res> {
  _$FamilyFailureCopyWithImpl(this._self, this._then);

  final FamilyFailure _self;
  final $Res Function(FamilyFailure) _then;

/// Create a copy of FamilyState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(FamilyFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
