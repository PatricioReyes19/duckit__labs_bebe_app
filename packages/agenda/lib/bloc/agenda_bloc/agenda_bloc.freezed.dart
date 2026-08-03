// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agenda_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AgendaEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgendaEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AgendaEvent()';
}


}

/// @nodoc
class $AgendaEventCopyWith<$Res>  {
$AgendaEventCopyWith(AgendaEvent _, $Res Function(AgendaEvent) __);
}


/// Adds pattern-matching-related methods to [AgendaEvent].
extension AgendaEventPatterns on AgendaEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Started value)?  started,TResult Function( _Retried value)?  retried,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _Retried() when retried != null:
return retried(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Started value)  started,required TResult Function( _Retried value)  retried,}){
final _that = this;
switch (_that) {
case _Started():
return started(_that);case _Retried():
return retried(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Started value)?  started,TResult? Function( _Retried value)?  retried,}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _Retried() when retried != null:
return retried(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function()?  retried,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _Retried() when retried != null:
return retried();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function()  retried,}) {final _that = this;
switch (_that) {
case _Started():
return started();case _Retried():
return retried();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function()?  retried,}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _Retried() when retried != null:
return retried();case _:
  return null;

}
}

}

/// @nodoc


class _Started implements AgendaEvent {
  const _Started();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Started);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AgendaEvent.started()';
}


}




/// @nodoc


class _Retried implements AgendaEvent {
  const _Retried();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Retried);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AgendaEvent.retried()';
}


}




/// @nodoc
mixin _$AgendaState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgendaState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AgendaState()';
}


}

/// @nodoc
class $AgendaStateCopyWith<$Res>  {
$AgendaStateCopyWith(AgendaState _, $Res Function(AgendaState) __);
}


/// Adds pattern-matching-related methods to [AgendaState].
extension AgendaStatePatterns on AgendaState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AgendaInitial value)?  initial,TResult Function( AgendaLoading value)?  loading,TResult Function( AgendaLoaded value)?  loaded,TResult Function( AgendaFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AgendaInitial() when initial != null:
return initial(_that);case AgendaLoading() when loading != null:
return loading(_that);case AgendaLoaded() when loaded != null:
return loaded(_that);case AgendaFailure() when failure != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AgendaInitial value)  initial,required TResult Function( AgendaLoading value)  loading,required TResult Function( AgendaLoaded value)  loaded,required TResult Function( AgendaFailure value)  failure,}){
final _that = this;
switch (_that) {
case AgendaInitial():
return initial(_that);case AgendaLoading():
return loading(_that);case AgendaLoaded():
return loaded(_that);case AgendaFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AgendaInitial value)?  initial,TResult? Function( AgendaLoading value)?  loading,TResult? Function( AgendaLoaded value)?  loaded,TResult? Function( AgendaFailure value)?  failure,}){
final _that = this;
switch (_that) {
case AgendaInitial() when initial != null:
return initial(_that);case AgendaLoading() when loading != null:
return loading(_that);case AgendaLoaded() when loaded != null:
return loaded(_that);case AgendaFailure() when failure != null:
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
case AgendaInitial() when initial != null:
return initial();case AgendaLoading() when loading != null:
return loading();case AgendaLoaded() when loaded != null:
return loaded();case AgendaFailure() when failure != null:
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
case AgendaInitial():
return initial();case AgendaLoading():
return loading();case AgendaLoaded():
return loaded();case AgendaFailure():
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
case AgendaInitial() when initial != null:
return initial();case AgendaLoading() when loading != null:
return loading();case AgendaLoaded() when loaded != null:
return loaded();case AgendaFailure() when failure != null:
return failure(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class AgendaInitial implements AgendaState {
  const AgendaInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgendaInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AgendaState.initial()';
}


}




/// @nodoc


class AgendaLoading implements AgendaState {
  const AgendaLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgendaLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AgendaState.loading()';
}


}




/// @nodoc


class AgendaLoaded implements AgendaState {
  const AgendaLoaded();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgendaLoaded);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AgendaState.loaded()';
}


}




/// @nodoc


class AgendaFailure implements AgendaState {
  const AgendaFailure({required this.message});
  

 final  String message;

/// Create a copy of AgendaState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgendaFailureCopyWith<AgendaFailure> get copyWith => _$AgendaFailureCopyWithImpl<AgendaFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgendaFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AgendaState.failure(message: $message)';
}


}

/// @nodoc
abstract mixin class $AgendaFailureCopyWith<$Res> implements $AgendaStateCopyWith<$Res> {
  factory $AgendaFailureCopyWith(AgendaFailure value, $Res Function(AgendaFailure) _then) = _$AgendaFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$AgendaFailureCopyWithImpl<$Res>
    implements $AgendaFailureCopyWith<$Res> {
  _$AgendaFailureCopyWithImpl(this._self, this._then);

  final AgendaFailure _self;
  final $Res Function(AgendaFailure) _then;

/// Create a copy of AgendaState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(AgendaFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
