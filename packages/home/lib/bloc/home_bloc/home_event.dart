part of 'home_bloc.dart';
sealed class HomeEvent extends Equatable{const HomeEvent();@override List<Object?> get props=>const[];}
final class HomeStarted extends HomeEvent{const HomeStarted();}
final class HomeRetried extends HomeEvent{const HomeRetried();}
