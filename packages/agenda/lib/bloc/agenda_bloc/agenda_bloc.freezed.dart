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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Started value)?  started,TResult Function( _Retried value)?  retried,TResult Function( _Refreshed value)?  refreshed,TResult Function( _DaySelected value)?  daySelected,TResult Function( _WeekChanged value)?  weekChanged,TResult Function( _MonthDaySelected value)?  monthDaySelected,TResult Function( _MonthChanged value)?  monthChanged,TResult Function( _CategorySelected value)?  categorySelected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _Retried() when retried != null:
return retried(_that);case _Refreshed() when refreshed != null:
return refreshed(_that);case _DaySelected() when daySelected != null:
return daySelected(_that);case _WeekChanged() when weekChanged != null:
return weekChanged(_that);case _MonthDaySelected() when monthDaySelected != null:
return monthDaySelected(_that);case _MonthChanged() when monthChanged != null:
return monthChanged(_that);case _CategorySelected() when categorySelected != null:
return categorySelected(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Started value)  started,required TResult Function( _Retried value)  retried,required TResult Function( _Refreshed value)  refreshed,required TResult Function( _DaySelected value)  daySelected,required TResult Function( _WeekChanged value)  weekChanged,required TResult Function( _MonthDaySelected value)  monthDaySelected,required TResult Function( _MonthChanged value)  monthChanged,required TResult Function( _CategorySelected value)  categorySelected,}){
final _that = this;
switch (_that) {
case _Started():
return started(_that);case _Retried():
return retried(_that);case _Refreshed():
return refreshed(_that);case _DaySelected():
return daySelected(_that);case _WeekChanged():
return weekChanged(_that);case _MonthDaySelected():
return monthDaySelected(_that);case _MonthChanged():
return monthChanged(_that);case _CategorySelected():
return categorySelected(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Started value)?  started,TResult? Function( _Retried value)?  retried,TResult? Function( _Refreshed value)?  refreshed,TResult? Function( _DaySelected value)?  daySelected,TResult? Function( _WeekChanged value)?  weekChanged,TResult? Function( _MonthDaySelected value)?  monthDaySelected,TResult? Function( _MonthChanged value)?  monthChanged,TResult? Function( _CategorySelected value)?  categorySelected,}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _Retried() when retried != null:
return retried(_that);case _Refreshed() when refreshed != null:
return refreshed(_that);case _DaySelected() when daySelected != null:
return daySelected(_that);case _WeekChanged() when weekChanged != null:
return weekChanged(_that);case _MonthDaySelected() when monthDaySelected != null:
return monthDaySelected(_that);case _MonthChanged() when monthChanged != null:
return monthChanged(_that);case _CategorySelected() when categorySelected != null:
return categorySelected(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function()?  retried,TResult Function()?  refreshed,TResult Function( DateTime selectedDay,  DateTime focusedDay)?  daySelected,TResult Function( DateTime focusedDay)?  weekChanged,TResult Function( DateTime selectedDay,  DateTime focusedDay)?  monthDaySelected,TResult Function( DateTime focusedDay)?  monthChanged,TResult Function( AgendaFilterCategory category)?  categorySelected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _Retried() when retried != null:
return retried();case _Refreshed() when refreshed != null:
return refreshed();case _DaySelected() when daySelected != null:
return daySelected(_that.selectedDay,_that.focusedDay);case _WeekChanged() when weekChanged != null:
return weekChanged(_that.focusedDay);case _MonthDaySelected() when monthDaySelected != null:
return monthDaySelected(_that.selectedDay,_that.focusedDay);case _MonthChanged() when monthChanged != null:
return monthChanged(_that.focusedDay);case _CategorySelected() when categorySelected != null:
return categorySelected(_that.category);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function()  retried,required TResult Function()  refreshed,required TResult Function( DateTime selectedDay,  DateTime focusedDay)  daySelected,required TResult Function( DateTime focusedDay)  weekChanged,required TResult Function( DateTime selectedDay,  DateTime focusedDay)  monthDaySelected,required TResult Function( DateTime focusedDay)  monthChanged,required TResult Function( AgendaFilterCategory category)  categorySelected,}) {final _that = this;
switch (_that) {
case _Started():
return started();case _Retried():
return retried();case _Refreshed():
return refreshed();case _DaySelected():
return daySelected(_that.selectedDay,_that.focusedDay);case _WeekChanged():
return weekChanged(_that.focusedDay);case _MonthDaySelected():
return monthDaySelected(_that.selectedDay,_that.focusedDay);case _MonthChanged():
return monthChanged(_that.focusedDay);case _CategorySelected():
return categorySelected(_that.category);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function()?  retried,TResult? Function()?  refreshed,TResult? Function( DateTime selectedDay,  DateTime focusedDay)?  daySelected,TResult? Function( DateTime focusedDay)?  weekChanged,TResult? Function( DateTime selectedDay,  DateTime focusedDay)?  monthDaySelected,TResult? Function( DateTime focusedDay)?  monthChanged,TResult? Function( AgendaFilterCategory category)?  categorySelected,}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _Retried() when retried != null:
return retried();case _Refreshed() when refreshed != null:
return refreshed();case _DaySelected() when daySelected != null:
return daySelected(_that.selectedDay,_that.focusedDay);case _WeekChanged() when weekChanged != null:
return weekChanged(_that.focusedDay);case _MonthDaySelected() when monthDaySelected != null:
return monthDaySelected(_that.selectedDay,_that.focusedDay);case _MonthChanged() when monthChanged != null:
return monthChanged(_that.focusedDay);case _CategorySelected() when categorySelected != null:
return categorySelected(_that.category);case _:
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


class _Refreshed implements AgendaEvent {
  const _Refreshed();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Refreshed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AgendaEvent.refreshed()';
}


}




/// @nodoc


class _DaySelected implements AgendaEvent {
  const _DaySelected({required this.selectedDay, required this.focusedDay});
  

 final  DateTime selectedDay;
 final  DateTime focusedDay;

/// Create a copy of AgendaEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DaySelectedCopyWith<_DaySelected> get copyWith => __$DaySelectedCopyWithImpl<_DaySelected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DaySelected&&(identical(other.selectedDay, selectedDay) || other.selectedDay == selectedDay)&&(identical(other.focusedDay, focusedDay) || other.focusedDay == focusedDay));
}


@override
int get hashCode => Object.hash(runtimeType,selectedDay,focusedDay);

@override
String toString() {
  return 'AgendaEvent.daySelected(selectedDay: $selectedDay, focusedDay: $focusedDay)';
}


}

/// @nodoc
abstract mixin class _$DaySelectedCopyWith<$Res> implements $AgendaEventCopyWith<$Res> {
  factory _$DaySelectedCopyWith(_DaySelected value, $Res Function(_DaySelected) _then) = __$DaySelectedCopyWithImpl;
@useResult
$Res call({
 DateTime selectedDay, DateTime focusedDay
});




}
/// @nodoc
class __$DaySelectedCopyWithImpl<$Res>
    implements _$DaySelectedCopyWith<$Res> {
  __$DaySelectedCopyWithImpl(this._self, this._then);

  final _DaySelected _self;
  final $Res Function(_DaySelected) _then;

/// Create a copy of AgendaEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? selectedDay = null,Object? focusedDay = null,}) {
  return _then(_DaySelected(
selectedDay: null == selectedDay ? _self.selectedDay : selectedDay // ignore: cast_nullable_to_non_nullable
as DateTime,focusedDay: null == focusedDay ? _self.focusedDay : focusedDay // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class _WeekChanged implements AgendaEvent {
  const _WeekChanged(this.focusedDay);
  

 final  DateTime focusedDay;

/// Create a copy of AgendaEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeekChangedCopyWith<_WeekChanged> get copyWith => __$WeekChangedCopyWithImpl<_WeekChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeekChanged&&(identical(other.focusedDay, focusedDay) || other.focusedDay == focusedDay));
}


@override
int get hashCode => Object.hash(runtimeType,focusedDay);

@override
String toString() {
  return 'AgendaEvent.weekChanged(focusedDay: $focusedDay)';
}


}

/// @nodoc
abstract mixin class _$WeekChangedCopyWith<$Res> implements $AgendaEventCopyWith<$Res> {
  factory _$WeekChangedCopyWith(_WeekChanged value, $Res Function(_WeekChanged) _then) = __$WeekChangedCopyWithImpl;
@useResult
$Res call({
 DateTime focusedDay
});




}
/// @nodoc
class __$WeekChangedCopyWithImpl<$Res>
    implements _$WeekChangedCopyWith<$Res> {
  __$WeekChangedCopyWithImpl(this._self, this._then);

  final _WeekChanged _self;
  final $Res Function(_WeekChanged) _then;

/// Create a copy of AgendaEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? focusedDay = null,}) {
  return _then(_WeekChanged(
null == focusedDay ? _self.focusedDay : focusedDay // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class _MonthDaySelected implements AgendaEvent {
  const _MonthDaySelected({required this.selectedDay, required this.focusedDay});
  

 final  DateTime selectedDay;
 final  DateTime focusedDay;

/// Create a copy of AgendaEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthDaySelectedCopyWith<_MonthDaySelected> get copyWith => __$MonthDaySelectedCopyWithImpl<_MonthDaySelected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthDaySelected&&(identical(other.selectedDay, selectedDay) || other.selectedDay == selectedDay)&&(identical(other.focusedDay, focusedDay) || other.focusedDay == focusedDay));
}


@override
int get hashCode => Object.hash(runtimeType,selectedDay,focusedDay);

@override
String toString() {
  return 'AgendaEvent.monthDaySelected(selectedDay: $selectedDay, focusedDay: $focusedDay)';
}


}

/// @nodoc
abstract mixin class _$MonthDaySelectedCopyWith<$Res> implements $AgendaEventCopyWith<$Res> {
  factory _$MonthDaySelectedCopyWith(_MonthDaySelected value, $Res Function(_MonthDaySelected) _then) = __$MonthDaySelectedCopyWithImpl;
@useResult
$Res call({
 DateTime selectedDay, DateTime focusedDay
});




}
/// @nodoc
class __$MonthDaySelectedCopyWithImpl<$Res>
    implements _$MonthDaySelectedCopyWith<$Res> {
  __$MonthDaySelectedCopyWithImpl(this._self, this._then);

  final _MonthDaySelected _self;
  final $Res Function(_MonthDaySelected) _then;

/// Create a copy of AgendaEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? selectedDay = null,Object? focusedDay = null,}) {
  return _then(_MonthDaySelected(
selectedDay: null == selectedDay ? _self.selectedDay : selectedDay // ignore: cast_nullable_to_non_nullable
as DateTime,focusedDay: null == focusedDay ? _self.focusedDay : focusedDay // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class _MonthChanged implements AgendaEvent {
  const _MonthChanged(this.focusedDay);
  

 final  DateTime focusedDay;

/// Create a copy of AgendaEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthChangedCopyWith<_MonthChanged> get copyWith => __$MonthChangedCopyWithImpl<_MonthChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthChanged&&(identical(other.focusedDay, focusedDay) || other.focusedDay == focusedDay));
}


@override
int get hashCode => Object.hash(runtimeType,focusedDay);

@override
String toString() {
  return 'AgendaEvent.monthChanged(focusedDay: $focusedDay)';
}


}

/// @nodoc
abstract mixin class _$MonthChangedCopyWith<$Res> implements $AgendaEventCopyWith<$Res> {
  factory _$MonthChangedCopyWith(_MonthChanged value, $Res Function(_MonthChanged) _then) = __$MonthChangedCopyWithImpl;
@useResult
$Res call({
 DateTime focusedDay
});




}
/// @nodoc
class __$MonthChangedCopyWithImpl<$Res>
    implements _$MonthChangedCopyWith<$Res> {
  __$MonthChangedCopyWithImpl(this._self, this._then);

  final _MonthChanged _self;
  final $Res Function(_MonthChanged) _then;

/// Create a copy of AgendaEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? focusedDay = null,}) {
  return _then(_MonthChanged(
null == focusedDay ? _self.focusedDay : focusedDay // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class _CategorySelected implements AgendaEvent {
  const _CategorySelected(this.category);
  

 final  AgendaFilterCategory category;

/// Create a copy of AgendaEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategorySelectedCopyWith<_CategorySelected> get copyWith => __$CategorySelectedCopyWithImpl<_CategorySelected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategorySelected&&(identical(other.category, category) || other.category == category));
}


@override
int get hashCode => Object.hash(runtimeType,category);

@override
String toString() {
  return 'AgendaEvent.categorySelected(category: $category)';
}


}

/// @nodoc
abstract mixin class _$CategorySelectedCopyWith<$Res> implements $AgendaEventCopyWith<$Res> {
  factory _$CategorySelectedCopyWith(_CategorySelected value, $Res Function(_CategorySelected) _then) = __$CategorySelectedCopyWithImpl;
@useResult
$Res call({
 AgendaFilterCategory category
});




}
/// @nodoc
class __$CategorySelectedCopyWithImpl<$Res>
    implements _$CategorySelectedCopyWith<$Res> {
  __$CategorySelectedCopyWithImpl(this._self, this._then);

  final _CategorySelected _self;
  final $Res Function(_CategorySelected) _then;

/// Create a copy of AgendaEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? category = null,}) {
  return _then(_CategorySelected(
null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as AgendaFilterCategory,
  ));
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AgendaInitial value)?  initial,TResult Function( AgendaLoading value)?  loading,TResult Function( AgendaLoaded value)?  loaded,TResult Function( AgendaEmpty value)?  empty,TResult Function( AgendaFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AgendaInitial() when initial != null:
return initial(_that);case AgendaLoading() when loading != null:
return loading(_that);case AgendaLoaded() when loaded != null:
return loaded(_that);case AgendaEmpty() when empty != null:
return empty(_that);case AgendaFailure() when failure != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AgendaInitial value)  initial,required TResult Function( AgendaLoading value)  loading,required TResult Function( AgendaLoaded value)  loaded,required TResult Function( AgendaEmpty value)  empty,required TResult Function( AgendaFailure value)  failure,}){
final _that = this;
switch (_that) {
case AgendaInitial():
return initial(_that);case AgendaLoading():
return loading(_that);case AgendaLoaded():
return loaded(_that);case AgendaEmpty():
return empty(_that);case AgendaFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AgendaInitial value)?  initial,TResult? Function( AgendaLoading value)?  loading,TResult? Function( AgendaLoaded value)?  loaded,TResult? Function( AgendaEmpty value)?  empty,TResult? Function( AgendaFailure value)?  failure,}){
final _that = this;
switch (_that) {
case AgendaInitial() when initial != null:
return initial(_that);case AgendaLoading() when loading != null:
return loading(_that);case AgendaLoaded() when loaded != null:
return loaded(_that);case AgendaEmpty() when empty != null:
return empty(_that);case AgendaFailure() when failure != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( AgendaOverviewVm overview)?  loaded,TResult Function( AgendaOverviewVm overview)?  empty,TResult Function( String message)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AgendaInitial() when initial != null:
return initial();case AgendaLoading() when loading != null:
return loading();case AgendaLoaded() when loaded != null:
return loaded(_that.overview);case AgendaEmpty() when empty != null:
return empty(_that.overview);case AgendaFailure() when failure != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( AgendaOverviewVm overview)  loaded,required TResult Function( AgendaOverviewVm overview)  empty,required TResult Function( String message)  failure,}) {final _that = this;
switch (_that) {
case AgendaInitial():
return initial();case AgendaLoading():
return loading();case AgendaLoaded():
return loaded(_that.overview);case AgendaEmpty():
return empty(_that.overview);case AgendaFailure():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( AgendaOverviewVm overview)?  loaded,TResult? Function( AgendaOverviewVm overview)?  empty,TResult? Function( String message)?  failure,}) {final _that = this;
switch (_that) {
case AgendaInitial() when initial != null:
return initial();case AgendaLoading() when loading != null:
return loading();case AgendaLoaded() when loaded != null:
return loaded(_that.overview);case AgendaEmpty() when empty != null:
return empty(_that.overview);case AgendaFailure() when failure != null:
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
  const AgendaLoaded({required this.overview});
  

 final  AgendaOverviewVm overview;

/// Create a copy of AgendaState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgendaLoadedCopyWith<AgendaLoaded> get copyWith => _$AgendaLoadedCopyWithImpl<AgendaLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgendaLoaded&&(identical(other.overview, overview) || other.overview == overview));
}


@override
int get hashCode => Object.hash(runtimeType,overview);

@override
String toString() {
  return 'AgendaState.loaded(overview: $overview)';
}


}

/// @nodoc
abstract mixin class $AgendaLoadedCopyWith<$Res> implements $AgendaStateCopyWith<$Res> {
  factory $AgendaLoadedCopyWith(AgendaLoaded value, $Res Function(AgendaLoaded) _then) = _$AgendaLoadedCopyWithImpl;
@useResult
$Res call({
 AgendaOverviewVm overview
});




}
/// @nodoc
class _$AgendaLoadedCopyWithImpl<$Res>
    implements $AgendaLoadedCopyWith<$Res> {
  _$AgendaLoadedCopyWithImpl(this._self, this._then);

  final AgendaLoaded _self;
  final $Res Function(AgendaLoaded) _then;

/// Create a copy of AgendaState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? overview = null,}) {
  return _then(AgendaLoaded(
overview: null == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as AgendaOverviewVm,
  ));
}


}

/// @nodoc


class AgendaEmpty implements AgendaState {
  const AgendaEmpty({required this.overview});
  

 final  AgendaOverviewVm overview;

/// Create a copy of AgendaState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgendaEmptyCopyWith<AgendaEmpty> get copyWith => _$AgendaEmptyCopyWithImpl<AgendaEmpty>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgendaEmpty&&(identical(other.overview, overview) || other.overview == overview));
}


@override
int get hashCode => Object.hash(runtimeType,overview);

@override
String toString() {
  return 'AgendaState.empty(overview: $overview)';
}


}

/// @nodoc
abstract mixin class $AgendaEmptyCopyWith<$Res> implements $AgendaStateCopyWith<$Res> {
  factory $AgendaEmptyCopyWith(AgendaEmpty value, $Res Function(AgendaEmpty) _then) = _$AgendaEmptyCopyWithImpl;
@useResult
$Res call({
 AgendaOverviewVm overview
});




}
/// @nodoc
class _$AgendaEmptyCopyWithImpl<$Res>
    implements $AgendaEmptyCopyWith<$Res> {
  _$AgendaEmptyCopyWithImpl(this._self, this._then);

  final AgendaEmpty _self;
  final $Res Function(AgendaEmpty) _then;

/// Create a copy of AgendaState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? overview = null,}) {
  return _then(AgendaEmpty(
overview: null == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as AgendaOverviewVm,
  ));
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
