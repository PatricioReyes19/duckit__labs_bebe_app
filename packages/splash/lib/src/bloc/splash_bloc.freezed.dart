// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'splash_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

mixin _$SplashEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is SplashEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'SplashEvent()';
  }
}

class $SplashEventCopyWith<$Res> {
  $SplashEventCopyWith(SplashEvent _, $Res Function(SplashEvent) __);
}

extension SplashEventPatterns on SplashEvent {

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_Retried value)? retried,
    TResult Function(_LoginRequested value)? loginRequested,
    TResult Function(_SignUpRequested value)? signUpRequested,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started(_that);
      case _Retried() when retried != null:
        return retried(_that);
      case _LoginRequested() when loginRequested != null:
        return loginRequested(_that);
      case _SignUpRequested() when signUpRequested != null:
        return signUpRequested(_that);
      case _:
        return orElse();
    }
  }


  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_Retried value) retried,
    required TResult Function(_LoginRequested value) loginRequested,
    required TResult Function(_SignUpRequested value) signUpRequested,
  }) {
    final _that = this;
    switch (_that) {
      case _Started():
        return started(_that);
      case _Retried():
        return retried(_that);
      case _LoginRequested():
        return loginRequested(_that);
      case _SignUpRequested():
        return signUpRequested(_that);
    }
  }


  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_Retried value)? retried,
    TResult? Function(_LoginRequested value)? loginRequested,
    TResult? Function(_SignUpRequested value)? signUpRequested,
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started(_that);
      case _Retried() when retried != null:
        return retried(_that);
      case _LoginRequested() when loginRequested != null:
        return loginRequested(_that);
      case _SignUpRequested() when signUpRequested != null:
        return signUpRequested(_that);
      case _:
        return null;
    }
  }


  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? retried,
    TResult Function()? loginRequested,
    TResult Function()? signUpRequested,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started();
      case _Retried() when retried != null:
        return retried();
      case _LoginRequested() when loginRequested != null:
        return loginRequested();
      case _SignUpRequested() when signUpRequested != null:
        return signUpRequested();
      case _:
        return orElse();
    }
  }


  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() retried,
    required TResult Function() loginRequested,
    required TResult Function() signUpRequested,
  }) {
    final _that = this;
    switch (_that) {
      case _Started():
        return started();
      case _Retried():
        return retried();
      case _LoginRequested():
        return loginRequested();
      case _SignUpRequested():
        return signUpRequested();
    }
  }


  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? retried,
    TResult? Function()? loginRequested,
    TResult? Function()? signUpRequested,
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started();
      case _Retried() when retried != null:
        return retried();
      case _LoginRequested() when loginRequested != null:
        return loginRequested();
      case _SignUpRequested() when signUpRequested != null:
        return signUpRequested();
      case _:
        return null;
    }
  }
}


class _Started implements SplashEvent {
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
    return 'SplashEvent.started()';
  }
}


class _Retried implements SplashEvent {
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
    return 'SplashEvent.retried()';
  }
}


class _LoginRequested implements SplashEvent {
  const _LoginRequested();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _LoginRequested);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'SplashEvent.loginRequested()';
  }
}


class _SignUpRequested implements SplashEvent {
  const _SignUpRequested();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _SignUpRequested);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'SplashEvent.signUpRequested()';
  }
}

mixin _$SplashState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is SplashState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'SplashState()';
  }
}

class $SplashStateCopyWith<$Res> {
  $SplashStateCopyWith(SplashState _, $Res Function(SplashState) __);
}

extension SplashStatePatterns on SplashState {

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SplashResolving value)? resolving,
    TResult Function(SplashAuthEntryState value)? authEntry,
    TResult Function(SplashRouteRequested value)? routeRequested,
    TResult Function(SplashFailure value)? failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case SplashResolving() when resolving != null:
        return resolving(_that);
      case SplashAuthEntryState() when authEntry != null:
        return authEntry(_that);
      case SplashRouteRequested() when routeRequested != null:
        return routeRequested(_that);
      case SplashFailure() when failure != null:
        return failure(_that);
      case _:
        return orElse();
    }
  }


  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SplashResolving value) resolving,
    required TResult Function(SplashAuthEntryState value) authEntry,
    required TResult Function(SplashRouteRequested value) routeRequested,
    required TResult Function(SplashFailure value) failure,
  }) {
    final _that = this;
    switch (_that) {
      case SplashResolving():
        return resolving(_that);
      case SplashAuthEntryState():
        return authEntry(_that);
      case SplashRouteRequested():
        return routeRequested(_that);
      case SplashFailure():
        return failure(_that);
    }
  }


  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SplashResolving value)? resolving,
    TResult? Function(SplashAuthEntryState value)? authEntry,
    TResult? Function(SplashRouteRequested value)? routeRequested,
    TResult? Function(SplashFailure value)? failure,
  }) {
    final _that = this;
    switch (_that) {
      case SplashResolving() when resolving != null:
        return resolving(_that);
      case SplashAuthEntryState() when authEntry != null:
        return authEntry(_that);
      case SplashRouteRequested() when routeRequested != null:
        return routeRequested(_that);
      case SplashFailure() when failure != null:
        return failure(_that);
      case _:
        return null;
    }
  }


  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? resolving,
    TResult Function()? authEntry,
    TResult Function(EntryDestination destination)? routeRequested,
    TResult Function(String message, bool canRetry)? failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case SplashResolving() when resolving != null:
        return resolving();
      case SplashAuthEntryState() when authEntry != null:
        return authEntry();
      case SplashRouteRequested() when routeRequested != null:
        return routeRequested(_that.destination);
      case SplashFailure() when failure != null:
        return failure(_that.message, _that.canRetry);
      case _:
        return orElse();
    }
  }


  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() resolving,
    required TResult Function() authEntry,
    required TResult Function(EntryDestination destination) routeRequested,
    required TResult Function(String message, bool canRetry) failure,
  }) {
    final _that = this;
    switch (_that) {
      case SplashResolving():
        return resolving();
      case SplashAuthEntryState():
        return authEntry();
      case SplashRouteRequested():
        return routeRequested(_that.destination);
      case SplashFailure():
        return failure(_that.message, _that.canRetry);
    }
  }


  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? resolving,
    TResult? Function()? authEntry,
    TResult? Function(EntryDestination destination)? routeRequested,
    TResult? Function(String message, bool canRetry)? failure,
  }) {
    final _that = this;
    switch (_that) {
      case SplashResolving() when resolving != null:
        return resolving();
      case SplashAuthEntryState() when authEntry != null:
        return authEntry();
      case SplashRouteRequested() when routeRequested != null:
        return routeRequested(_that.destination);
      case SplashFailure() when failure != null:
        return failure(_that.message, _that.canRetry);
      case _:
        return null;
    }
  }
}


class SplashResolving implements SplashState {
  const SplashResolving();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is SplashResolving);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'SplashState.resolving()';
  }
}


class SplashAuthEntryState implements SplashState {
  const SplashAuthEntryState();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is SplashAuthEntryState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'SplashState.authEntry()';
  }
}


class SplashRouteRequested implements SplashState {
  const SplashRouteRequested({required this.destination});

  final EntryDestination destination;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SplashRouteRequestedCopyWith<SplashRouteRequested> get copyWith =>
      _$SplashRouteRequestedCopyWithImpl<SplashRouteRequested>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SplashRouteRequested &&
            (identical(other.destination, destination) ||
                other.destination == destination));
  }

  @override
  int get hashCode => Object.hash(runtimeType, destination);

  @override
  String toString() {
    return 'SplashState.routeRequested(destination: $destination)';
  }
}

abstract mixin class $SplashRouteRequestedCopyWith<$Res>
    implements $SplashStateCopyWith<$Res> {
  factory $SplashRouteRequestedCopyWith(SplashRouteRequested value,
          $Res Function(SplashRouteRequested) _then) =
      _$SplashRouteRequestedCopyWithImpl;
  @useResult
  $Res call({EntryDestination destination});
}

class _$SplashRouteRequestedCopyWithImpl<$Res>
    implements $SplashRouteRequestedCopyWith<$Res> {
  _$SplashRouteRequestedCopyWithImpl(this._self, this._then);

  final SplashRouteRequested _self;
  final $Res Function(SplashRouteRequested) _then;

  @pragma('vm:prefer-inline')
  $Res call({
    Object? destination = null,
  }) {
    return _then(SplashRouteRequested(
      destination: null == destination
          ? _self.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as EntryDestination,
    ));
  }
}


class SplashFailure implements SplashState {
  const SplashFailure({required this.message, required this.canRetry});

  final String message;
  final bool canRetry;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SplashFailureCopyWith<SplashFailure> get copyWith =>
      _$SplashFailureCopyWithImpl<SplashFailure>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SplashFailure &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.canRetry, canRetry) ||
                other.canRetry == canRetry));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, canRetry);

  @override
  String toString() {
    return 'SplashState.failure(message: $message, canRetry: $canRetry)';
  }
}

abstract mixin class $SplashFailureCopyWith<$Res>
    implements $SplashStateCopyWith<$Res> {
  factory $SplashFailureCopyWith(
          SplashFailure value, $Res Function(SplashFailure) _then) =
      _$SplashFailureCopyWithImpl;
  @useResult
  $Res call({String message, bool canRetry});
}

class _$SplashFailureCopyWithImpl<$Res>
    implements $SplashFailureCopyWith<$Res> {
  _$SplashFailureCopyWithImpl(this._self, this._then);

  final SplashFailure _self;
  final $Res Function(SplashFailure) _then;

  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? canRetry = null,
  }) {
    return _then(SplashFailure(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      canRetry: null == canRetry
          ? _self.canRetry
          : canRetry // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
