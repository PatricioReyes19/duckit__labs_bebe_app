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

class $FamilyEventCopyWith<$Res>  {
$FamilyEventCopyWith(FamilyEvent _, $Res Function(FamilyEvent) __);
}


extension FamilyEventPatterns on FamilyEvent {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Started value)?  started,TResult Function( _Retried value)?  retried,TResult Function( _BabySelected value)?  babySelected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _Retried() when retried != null:
return retried(_that);case _BabySelected() when babySelected != null:
return babySelected(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Started value)  started,required TResult Function( _Retried value)  retried,required TResult Function( _BabySelected value)  babySelected,}){
final _that = this;
switch (_that) {
case _Started():
return started(_that);case _Retried():
return retried(_that);case _BabySelected():
return babySelected(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Started value)?  started,TResult? Function( _Retried value)?  retried,TResult? Function( _BabySelected value)?  babySelected,}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _Retried() when retried != null:
return retried(_that);case _BabySelected() when babySelected != null:
return babySelected(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function()?  retried,TResult Function( String babyId)?  babySelected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _Retried() when retried != null:
return retried();case _BabySelected() when babySelected != null:
return babySelected(_that.babyId);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function()  retried,required TResult Function( String babyId)  babySelected,}) {final _that = this;
switch (_that) {
case _Started():
return started();case _Retried():
return retried();case _BabySelected():
return babySelected(_that.babyId);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function()?  retried,TResult? Function( String babyId)?  babySelected,}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _Retried() when retried != null:
return retried();case _BabySelected() when babySelected != null:
return babySelected(_that.babyId);case _:
  return null;

}
}

}



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






class _Retried implements FamilyEvent {
  const _Retried();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Retried);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FamilyEvent.retried()';
}


}






class _BabySelected implements FamilyEvent {
  const _BabySelected(this.babyId);
  

 final  String babyId;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BabySelectedCopyWith<_BabySelected> get copyWith => __$BabySelectedCopyWithImpl<_BabySelected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BabySelected&&(identical(other.babyId, babyId) || other.babyId == babyId));
}


@override
int get hashCode => Object.hash(runtimeType,babyId);

@override
String toString() {
  return 'FamilyEvent.babySelected(babyId: $babyId)';
}


}

abstract mixin class _$BabySelectedCopyWith<$Res> implements $FamilyEventCopyWith<$Res> {
  factory _$BabySelectedCopyWith(_BabySelected value, $Res Function(_BabySelected) _then) = __$BabySelectedCopyWithImpl;
@useResult
$Res call({
 String babyId
});




}
class __$BabySelectedCopyWithImpl<$Res>
    implements _$BabySelectedCopyWith<$Res> {
  __$BabySelectedCopyWithImpl(this._self, this._then);

  final _BabySelected _self;
  final $Res Function(_BabySelected) _then;

@pragma('vm:prefer-inline') $Res call({Object? babyId = null,}) {
  return _then(_BabySelected(
null == babyId ? _self.babyId : babyId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

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

class $FamilyStateCopyWith<$Res>  {
$FamilyStateCopyWith(FamilyState _, $Res Function(FamilyState) __);
}


extension FamilyStatePatterns on FamilyState {

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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( FamilyInitial value)  initial,required TResult Function( FamilyLoading value)  loading,required TResult Function( FamilyLoaded value)  loaded,required TResult Function( FamilyFailure value)  failure,}){
final _that = this;
switch (_that) {
case FamilyInitial():
return initial(_that);case FamilyLoading():
return loading(_that);case FamilyLoaded():
return loaded(_that);case FamilyFailure():
return failure(_that);}
}

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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( FamilyOverviewVm overview)?  loaded,TResult Function( String message)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case FamilyInitial() when initial != null:
return initial();case FamilyLoading() when loading != null:
return loading();case FamilyLoaded() when loaded != null:
return loaded(_that.overview);case FamilyFailure() when failure != null:
return failure(_that.message);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( FamilyOverviewVm overview)  loaded,required TResult Function( String message)  failure,}) {final _that = this;
switch (_that) {
case FamilyInitial():
return initial();case FamilyLoading():
return loading();case FamilyLoaded():
return loaded(_that.overview);case FamilyFailure():
return failure(_that.message);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( FamilyOverviewVm overview)?  loaded,TResult? Function( String message)?  failure,}) {final _that = this;
switch (_that) {
case FamilyInitial() when initial != null:
return initial();case FamilyLoading() when loading != null:
return loading();case FamilyLoaded() when loaded != null:
return loaded(_that.overview);case FamilyFailure() when failure != null:
return failure(_that.message);case _:
  return null;

}
}

}



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






class FamilyLoaded implements FamilyState {
  const FamilyLoaded({required this.overview});
  

 final  FamilyOverviewVm overview;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyLoadedCopyWith<FamilyLoaded> get copyWith => _$FamilyLoadedCopyWithImpl<FamilyLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyLoaded&&(identical(other.overview, overview) || other.overview == overview));
}


@override
int get hashCode => Object.hash(runtimeType,overview);

@override
String toString() {
  return 'FamilyState.loaded(overview: $overview)';
}


}

abstract mixin class $FamilyLoadedCopyWith<$Res> implements $FamilyStateCopyWith<$Res> {
  factory $FamilyLoadedCopyWith(FamilyLoaded value, $Res Function(FamilyLoaded) _then) = _$FamilyLoadedCopyWithImpl;
@useResult
$Res call({
 FamilyOverviewVm overview
});




}
class _$FamilyLoadedCopyWithImpl<$Res>
    implements $FamilyLoadedCopyWith<$Res> {
  _$FamilyLoadedCopyWithImpl(this._self, this._then);

  final FamilyLoaded _self;
  final $Res Function(FamilyLoaded) _then;

@pragma('vm:prefer-inline') $Res call({Object? overview = null,}) {
  return _then(FamilyLoaded(
overview: null == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as FamilyOverviewVm,
  ));
}


}



class FamilyFailure implements FamilyState {
  const FamilyFailure({required this.message});
  

 final  String message;

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

abstract mixin class $FamilyFailureCopyWith<$Res> implements $FamilyStateCopyWith<$Res> {
  factory $FamilyFailureCopyWith(FamilyFailure value, $Res Function(FamilyFailure) _then) = _$FamilyFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
class _$FamilyFailureCopyWithImpl<$Res>
    implements $FamilyFailureCopyWith<$Res> {
  _$FamilyFailureCopyWithImpl(this._self, this._then);

  final FamilyFailure _self;
  final $Res Function(FamilyFailure) _then;

@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(FamilyFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
