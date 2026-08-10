// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

mixin _$HomeEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is HomeEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'HomeEvent()';
  }
}

class $HomeEventCopyWith<$Res> {
  $HomeEventCopyWith(HomeEvent _, $Res Function(HomeEvent) __);
}

extension HomeEventPatterns on HomeEvent {

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_Refreshed value)? refreshed,
    TResult Function(_Retried value)? retried,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started(_that);
      case _Refreshed() when refreshed != null:
        return refreshed(_that);
      case _Retried() when retried != null:
        return retried(_that);
      case _:
        return orElse();
    }
  }


  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_Refreshed value) refreshed,
    required TResult Function(_Retried value) retried,
  }) {
    final _that = this;
    switch (_that) {
      case _Started():
        return started(_that);
      case _Refreshed():
        return refreshed(_that);
      case _Retried():
        return retried(_that);
    }
  }


  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_Refreshed value)? refreshed,
    TResult? Function(_Retried value)? retried,
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started(_that);
      case _Refreshed() when refreshed != null:
        return refreshed(_that);
      case _Retried() when retried != null:
        return retried(_that);
      case _:
        return null;
    }
  }


  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? refreshed,
    TResult Function()? retried,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started();
      case _Refreshed() when refreshed != null:
        return refreshed();
      case _Retried() when retried != null:
        return retried();
      case _:
        return orElse();
    }
  }


  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() refreshed,
    required TResult Function() retried,
  }) {
    final _that = this;
    switch (_that) {
      case _Started():
        return started();
      case _Refreshed():
        return refreshed();
      case _Retried():
        return retried();
    }
  }


  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? refreshed,
    TResult? Function()? retried,
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started();
      case _Refreshed() when refreshed != null:
        return refreshed();
      case _Retried() when retried != null:
        return retried();
      case _:
        return null;
    }
  }
}


class _Started implements HomeEvent {
  const _Started();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Started);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'HomeEvent.started()';
  }
}


class _Refreshed implements HomeEvent {
  const _Refreshed();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Refreshed);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'HomeEvent.refreshed()';
  }
}


class _Retried implements HomeEvent {
  const _Retried();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Retried);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'HomeEvent.retried()';
  }
}

mixin _$HomeState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is HomeState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'HomeState()';
  }
}

class $HomeStateCopyWith<$Res> {
  $HomeStateCopyWith(HomeState _, $Res Function(HomeState) __);
}

extension HomeStatePatterns on HomeState {

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HomeInitial value)? initial,
    TResult Function(HomeLoading value)? loading,
    TResult Function(HomeLoaded value)? loaded,
    TResult Function(HomeFailure value)? failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case HomeInitial() when initial != null:
        return initial(_that);
      case HomeLoading() when loading != null:
        return loading(_that);
      case HomeLoaded() when loaded != null:
        return loaded(_that);
      case HomeFailure() when failure != null:
        return failure(_that);
      case _:
        return orElse();
    }
  }


  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HomeInitial value) initial,
    required TResult Function(HomeLoading value) loading,
    required TResult Function(HomeLoaded value) loaded,
    required TResult Function(HomeFailure value) failure,
  }) {
    final _that = this;
    switch (_that) {
      case HomeInitial():
        return initial(_that);
      case HomeLoading():
        return loading(_that);
      case HomeLoaded():
        return loaded(_that);
      case HomeFailure():
        return failure(_that);
    }
  }


  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(HomeInitial value)? initial,
    TResult? Function(HomeLoading value)? loading,
    TResult? Function(HomeLoaded value)? loaded,
    TResult? Function(HomeFailure value)? failure,
  }) {
    final _that = this;
    switch (_that) {
      case HomeInitial() when initial != null:
        return initial(_that);
      case HomeLoading() when loading != null:
        return loading(_that);
      case HomeLoaded() when loaded != null:
        return loaded(_that);
      case HomeFailure() when failure != null:
        return failure(_that);
      case _:
        return null;
    }
  }


  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(HomeOverviewVm overview, bool isRefreshing)? loaded,
    TResult Function(String message)? failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case HomeInitial() when initial != null:
        return initial();
      case HomeLoading() when loading != null:
        return loading();
      case HomeLoaded() when loaded != null:
        return loaded(_that.overview, _that.isRefreshing);
      case HomeFailure() when failure != null:
        return failure(_that.message);
      case _:
        return orElse();
    }
  }


  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(HomeOverviewVm overview, bool isRefreshing)
        loaded,
    required TResult Function(String message) failure,
  }) {
    final _that = this;
    switch (_that) {
      case HomeInitial():
        return initial();
      case HomeLoading():
        return loading();
      case HomeLoaded():
        return loaded(_that.overview, _that.isRefreshing);
      case HomeFailure():
        return failure(_that.message);
    }
  }


  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(HomeOverviewVm overview, bool isRefreshing)? loaded,
    TResult? Function(String message)? failure,
  }) {
    final _that = this;
    switch (_that) {
      case HomeInitial() when initial != null:
        return initial();
      case HomeLoading() when loading != null:
        return loading();
      case HomeLoaded() when loaded != null:
        return loaded(_that.overview, _that.isRefreshing);
      case HomeFailure() when failure != null:
        return failure(_that.message);
      case _:
        return null;
    }
  }
}


class HomeInitial implements HomeState {
  const HomeInitial();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is HomeInitial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'HomeState.initial()';
  }
}


class HomeLoading implements HomeState {
  const HomeLoading();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is HomeLoading);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'HomeState.loading()';
  }
}


class HomeLoaded implements HomeState {
  const HomeLoaded({required this.overview, this.isRefreshing = false});

  final HomeOverviewVm overview;
  @JsonKey()
  final bool isRefreshing;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HomeLoadedCopyWith<HomeLoaded> get copyWith =>
      _$HomeLoadedCopyWithImpl<HomeLoaded>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HomeLoaded &&
            (identical(other.overview, overview) ||
                other.overview == overview) &&
            (identical(other.isRefreshing, isRefreshing) ||
                other.isRefreshing == isRefreshing));
  }

  @override
  int get hashCode => Object.hash(runtimeType, overview, isRefreshing);

  @override
  String toString() {
    return 'HomeState.loaded(overview: $overview, isRefreshing: $isRefreshing)';
  }
}

abstract mixin class $HomeLoadedCopyWith<$Res>
    implements $HomeStateCopyWith<$Res> {
  factory $HomeLoadedCopyWith(
          HomeLoaded value, $Res Function(HomeLoaded) _then) =
      _$HomeLoadedCopyWithImpl;
  @useResult
  $Res call({HomeOverviewVm overview, bool isRefreshing});
}

class _$HomeLoadedCopyWithImpl<$Res> implements $HomeLoadedCopyWith<$Res> {
  _$HomeLoadedCopyWithImpl(this._self, this._then);

  final HomeLoaded _self;
  final $Res Function(HomeLoaded) _then;

  @pragma('vm:prefer-inline')
  $Res call({
    Object? overview = null,
    Object? isRefreshing = null,
  }) {
    return _then(HomeLoaded(
      overview: null == overview
          ? _self.overview
          : overview // ignore: cast_nullable_to_non_nullable
              as HomeOverviewVm,
      isRefreshing: null == isRefreshing
          ? _self.isRefreshing
          : isRefreshing // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}


class HomeFailure implements HomeState {
  const HomeFailure({required this.message});

  final String message;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HomeFailureCopyWith<HomeFailure> get copyWith =>
      _$HomeFailureCopyWithImpl<HomeFailure>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HomeFailure &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'HomeState.failure(message: $message)';
  }
}

abstract mixin class $HomeFailureCopyWith<$Res>
    implements $HomeStateCopyWith<$Res> {
  factory $HomeFailureCopyWith(
          HomeFailure value, $Res Function(HomeFailure) _then) =
      _$HomeFailureCopyWithImpl;
  @useResult
  $Res call({String message});
}

class _$HomeFailureCopyWithImpl<$Res> implements $HomeFailureCopyWith<$Res> {
  _$HomeFailureCopyWithImpl(this._self, this._then);

  final HomeFailure _self;
  final $Res Function(HomeFailure) _then;

  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(HomeFailure(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
