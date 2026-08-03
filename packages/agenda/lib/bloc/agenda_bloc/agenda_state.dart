part of 'agenda_bloc.dart';
sealed class AgendaState extends Equatable { const AgendaState(); @override List<Object?> get props => const []; }
final class AgendaInitial extends AgendaState { const AgendaInitial(); }
final class AgendaLoading extends AgendaState { const AgendaLoading(); }
final class AgendaLoaded extends AgendaState { const AgendaLoaded(); }
final class AgendaFailure extends AgendaState { const AgendaFailure({required this.message}); final String message; @override List<Object?> get props => [message]; }
