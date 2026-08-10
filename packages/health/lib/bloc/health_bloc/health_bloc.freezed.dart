// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
mixin _$HealthEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HealthEvent()';
}


}

class $HealthEventCopyWith<$Res>  {
$HealthEventCopyWith(HealthEvent _, $Res Function(HealthEvent) __);
}


extension HealthEventPatterns on HealthEvent {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Started value)?  started,TResult Function( _Retried value)?  retried,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _Retried() when retried != null:
return retried(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Started value)  started,required TResult Function( _Retried value)  retried,}){
final _that = this;
switch (_that) {
case _Started():
return started(_that);case _Retried():
return retried(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Started value)?  started,TResult? Function( _Retried value)?  retried,}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _Retried() when retried != null:
return retried(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function()?  retried,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _Retried() when retried != null:
return retried();case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function()  retried,}) {final _that = this;
switch (_that) {
case _Started():
return started();case _Retried():
return retried();}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function()?  retried,}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _Retried() when retried != null:
return retried();case _:
  return null;

}
}

}



class _Started implements HealthEvent {
  const _Started();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Started);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HealthEvent.started()';
}


}






class _Retried implements HealthEvent {
  const _Retried();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Retried);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HealthEvent.retried()';
}


}




mixin _$HealthState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HealthState()';
}


}

class $HealthStateCopyWith<$Res>  {
$HealthStateCopyWith(HealthState _, $Res Function(HealthState) __);
}


extension HealthStatePatterns on HealthState {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( HealthInitial value)?  initial,TResult Function( HealthLoading value)?  loading,TResult Function( HealthLoaded value)?  loaded,TResult Function( HealthFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case HealthInitial() when initial != null:
return initial(_that);case HealthLoading() when loading != null:
return loading(_that);case HealthLoaded() when loaded != null:
return loaded(_that);case HealthFailure() when failure != null:
return failure(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( HealthInitial value)  initial,required TResult Function( HealthLoading value)  loading,required TResult Function( HealthLoaded value)  loaded,required TResult Function( HealthFailure value)  failure,}){
final _that = this;
switch (_that) {
case HealthInitial():
return initial(_that);case HealthLoading():
return loading(_that);case HealthLoaded():
return loaded(_that);case HealthFailure():
return failure(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( HealthInitial value)?  initial,TResult? Function( HealthLoading value)?  loading,TResult? Function( HealthLoaded value)?  loaded,TResult? Function( HealthFailure value)?  failure,}){
final _that = this;
switch (_that) {
case HealthInitial() when initial != null:
return initial(_that);case HealthLoading() when loading != null:
return loading(_that);case HealthLoaded() when loaded != null:
return loaded(_that);case HealthFailure() when failure != null:
return failure(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( HealthOverviewVm overview)?  loaded,TResult Function( String message)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case HealthInitial() when initial != null:
return initial();case HealthLoading() when loading != null:
return loading();case HealthLoaded() when loaded != null:
return loaded(_that.overview);case HealthFailure() when failure != null:
return failure(_that.message);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( HealthOverviewVm overview)  loaded,required TResult Function( String message)  failure,}) {final _that = this;
switch (_that) {
case HealthInitial():
return initial();case HealthLoading():
return loading();case HealthLoaded():
return loaded(_that.overview);case HealthFailure():
return failure(_that.message);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( HealthOverviewVm overview)?  loaded,TResult? Function( String message)?  failure,}) {final _that = this;
switch (_that) {
case HealthInitial() when initial != null:
return initial();case HealthLoading() when loading != null:
return loading();case HealthLoaded() when loaded != null:
return loaded(_that.overview);case HealthFailure() when failure != null:
return failure(_that.message);case _:
  return null;

}
}

}



class HealthInitial implements HealthState {
  const HealthInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HealthState.initial()';
}


}






class HealthLoading implements HealthState {
  const HealthLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HealthState.loading()';
}


}






class HealthLoaded implements HealthState {
  const HealthLoaded({required this.overview});
  

 final  HealthOverviewVm overview;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthLoadedCopyWith<HealthLoaded> get copyWith => _$HealthLoadedCopyWithImpl<HealthLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthLoaded&&(identical(other.overview, overview) || other.overview == overview));
}


@override
int get hashCode => Object.hash(runtimeType,overview);

@override
String toString() {
  return 'HealthState.loaded(overview: $overview)';
}


}

abstract mixin class $HealthLoadedCopyWith<$Res> implements $HealthStateCopyWith<$Res> {
  factory $HealthLoadedCopyWith(HealthLoaded value, $Res Function(HealthLoaded) _then) = _$HealthLoadedCopyWithImpl;
@useResult
$Res call({
 HealthOverviewVm overview
});




}
class _$HealthLoadedCopyWithImpl<$Res>
    implements $HealthLoadedCopyWith<$Res> {
  _$HealthLoadedCopyWithImpl(this._self, this._then);

  final HealthLoaded _self;
  final $Res Function(HealthLoaded) _then;

@pragma('vm:prefer-inline') $Res call({Object? overview = null,}) {
  return _then(HealthLoaded(
overview: null == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as HealthOverviewVm,
  ));
}


}



class HealthFailure implements HealthState {
  const HealthFailure({required this.message});
  

 final  String message;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthFailureCopyWith<HealthFailure> get copyWith => _$HealthFailureCopyWithImpl<HealthFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'HealthState.failure(message: $message)';
}


}

abstract mixin class $HealthFailureCopyWith<$Res> implements $HealthStateCopyWith<$Res> {
  factory $HealthFailureCopyWith(HealthFailure value, $Res Function(HealthFailure) _then) = _$HealthFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
class _$HealthFailureCopyWithImpl<$Res>
    implements $HealthFailureCopyWith<$Res> {
  _$HealthFailureCopyWithImpl(this._self, this._then);

  final HealthFailure _self;
  final $Res Function(HealthFailure) _then;

@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(HealthFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
