// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_theme_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
mixin _$AppThemeEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppThemeEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppThemeEvent()';
}


}

class $AppThemeEventCopyWith<$Res>  {
$AppThemeEventCopyWith(AppThemeEvent _, $Res Function(AppThemeEvent) __);
}


extension AppThemeEventPatterns on AppThemeEvent {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _UpdateAppThemeEvent value)?  updateTheme,TResult Function( _UpdateThemeModeEvent value)?  updateThemeMode,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateAppThemeEvent() when updateTheme != null:
return updateTheme(_that);case _UpdateThemeModeEvent() when updateThemeMode != null:
return updateThemeMode(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _UpdateAppThemeEvent value)  updateTheme,required TResult Function( _UpdateThemeModeEvent value)  updateThemeMode,}){
final _that = this;
switch (_that) {
case _UpdateAppThemeEvent():
return updateTheme(_that);case _UpdateThemeModeEvent():
return updateThemeMode(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _UpdateAppThemeEvent value)?  updateTheme,TResult? Function( _UpdateThemeModeEvent value)?  updateThemeMode,}){
final _that = this;
switch (_that) {
case _UpdateAppThemeEvent() when updateTheme != null:
return updateTheme(_that);case _UpdateThemeModeEvent() when updateThemeMode != null:
return updateThemeMode(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( BebeTheme theme)?  updateTheme,TResult Function( ThemeMode themeMode)?  updateThemeMode,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateAppThemeEvent() when updateTheme != null:
return updateTheme(_that.theme);case _UpdateThemeModeEvent() when updateThemeMode != null:
return updateThemeMode(_that.themeMode);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( BebeTheme theme)  updateTheme,required TResult Function( ThemeMode themeMode)  updateThemeMode,}) {final _that = this;
switch (_that) {
case _UpdateAppThemeEvent():
return updateTheme(_that.theme);case _UpdateThemeModeEvent():
return updateThemeMode(_that.themeMode);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( BebeTheme theme)?  updateTheme,TResult? Function( ThemeMode themeMode)?  updateThemeMode,}) {final _that = this;
switch (_that) {
case _UpdateAppThemeEvent() when updateTheme != null:
return updateTheme(_that.theme);case _UpdateThemeModeEvent() when updateThemeMode != null:
return updateThemeMode(_that.themeMode);case _:
  return null;

}
}

}



class _UpdateAppThemeEvent implements AppThemeEvent {
  const _UpdateAppThemeEvent({required this.theme});
  

 final  BebeTheme theme;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateAppThemeEventCopyWith<_UpdateAppThemeEvent> get copyWith => __$UpdateAppThemeEventCopyWithImpl<_UpdateAppThemeEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateAppThemeEvent&&(identical(other.theme, theme) || other.theme == theme));
}


@override
int get hashCode => Object.hash(runtimeType,theme);

@override
String toString() {
  return 'AppThemeEvent.updateTheme(theme: $theme)';
}


}

abstract mixin class _$UpdateAppThemeEventCopyWith<$Res> implements $AppThemeEventCopyWith<$Res> {
  factory _$UpdateAppThemeEventCopyWith(_UpdateAppThemeEvent value, $Res Function(_UpdateAppThemeEvent) _then) = __$UpdateAppThemeEventCopyWithImpl;
@useResult
$Res call({
 BebeTheme theme
});




}
class __$UpdateAppThemeEventCopyWithImpl<$Res>
    implements _$UpdateAppThemeEventCopyWith<$Res> {
  __$UpdateAppThemeEventCopyWithImpl(this._self, this._then);

  final _UpdateAppThemeEvent _self;
  final $Res Function(_UpdateAppThemeEvent) _then;

@pragma('vm:prefer-inline') $Res call({Object? theme = null,}) {
  return _then(_UpdateAppThemeEvent(
theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as BebeTheme,
  ));
}


}



class _UpdateThemeModeEvent implements AppThemeEvent {
  const _UpdateThemeModeEvent({required this.themeMode});
  

 final  ThemeMode themeMode;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateThemeModeEventCopyWith<_UpdateThemeModeEvent> get copyWith => __$UpdateThemeModeEventCopyWithImpl<_UpdateThemeModeEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateThemeModeEvent&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode));
}


@override
int get hashCode => Object.hash(runtimeType,themeMode);

@override
String toString() {
  return 'AppThemeEvent.updateThemeMode(themeMode: $themeMode)';
}


}

abstract mixin class _$UpdateThemeModeEventCopyWith<$Res> implements $AppThemeEventCopyWith<$Res> {
  factory _$UpdateThemeModeEventCopyWith(_UpdateThemeModeEvent value, $Res Function(_UpdateThemeModeEvent) _then) = __$UpdateThemeModeEventCopyWithImpl;
@useResult
$Res call({
 ThemeMode themeMode
});




}
class __$UpdateThemeModeEventCopyWithImpl<$Res>
    implements _$UpdateThemeModeEventCopyWith<$Res> {
  __$UpdateThemeModeEventCopyWithImpl(this._self, this._then);

  final _UpdateThemeModeEvent _self;
  final $Res Function(_UpdateThemeModeEvent) _then;

@pragma('vm:prefer-inline') $Res call({Object? themeMode = null,}) {
  return _then(_UpdateThemeModeEvent(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,
  ));
}


}

mixin _$AppThemeState {

 BebeTheme get theme; ThemeMode get themeMode;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppThemeStateCopyWith<AppThemeState> get copyWith => _$AppThemeStateCopyWithImpl<AppThemeState>(this as AppThemeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppThemeState&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode));
}


@override
int get hashCode => Object.hash(runtimeType,theme,themeMode);

@override
String toString() {
  return 'AppThemeState(theme: $theme, themeMode: $themeMode)';
}


}

abstract mixin class $AppThemeStateCopyWith<$Res>  {
  factory $AppThemeStateCopyWith(AppThemeState value, $Res Function(AppThemeState) _then) = _$AppThemeStateCopyWithImpl;
@useResult
$Res call({
 BebeTheme theme, ThemeMode themeMode
});




}
class _$AppThemeStateCopyWithImpl<$Res>
    implements $AppThemeStateCopyWith<$Res> {
  _$AppThemeStateCopyWithImpl(this._self, this._then);

  final AppThemeState _self;
  final $Res Function(AppThemeState) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? theme = null,Object? themeMode = null,}) {
  return _then(_self.copyWith(
theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as BebeTheme,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,
  ));
}

}


extension AppThemeStatePatterns on AppThemeState {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppThemeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppThemeState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppThemeState value)  $default,){
final _that = this;
switch (_that) {
case _AppThemeState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppThemeState value)?  $default,){
final _that = this;
switch (_that) {
case _AppThemeState() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BebeTheme theme,  ThemeMode themeMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppThemeState() when $default != null:
return $default(_that.theme,_that.themeMode);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BebeTheme theme,  ThemeMode themeMode)  $default,) {final _that = this;
switch (_that) {
case _AppThemeState():
return $default(_that.theme,_that.themeMode);case _:
  throw StateError('Unexpected subclass');

}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BebeTheme theme,  ThemeMode themeMode)?  $default,) {final _that = this;
switch (_that) {
case _AppThemeState() when $default != null:
return $default(_that.theme,_that.themeMode);case _:
  return null;

}
}

}



class _AppThemeState implements AppThemeState {
  const _AppThemeState({required this.theme, required this.themeMode});
  

@override final  BebeTheme theme;
@override final  ThemeMode themeMode;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppThemeStateCopyWith<_AppThemeState> get copyWith => __$AppThemeStateCopyWithImpl<_AppThemeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppThemeState&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode));
}


@override
int get hashCode => Object.hash(runtimeType,theme,themeMode);

@override
String toString() {
  return 'AppThemeState(theme: $theme, themeMode: $themeMode)';
}


}

abstract mixin class _$AppThemeStateCopyWith<$Res> implements $AppThemeStateCopyWith<$Res> {
  factory _$AppThemeStateCopyWith(_AppThemeState value, $Res Function(_AppThemeState) _then) = __$AppThemeStateCopyWithImpl;
@override @useResult
$Res call({
 BebeTheme theme, ThemeMode themeMode
});




}
class __$AppThemeStateCopyWithImpl<$Res>
    implements _$AppThemeStateCopyWith<$Res> {
  __$AppThemeStateCopyWithImpl(this._self, this._then);

  final _AppThemeState _self;
  final $Res Function(_AppThemeState) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? theme = null,Object? themeMode = null,}) {
  return _then(_AppThemeState(
theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as BebeTheme,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,
  ));
}


}

// dart format on
