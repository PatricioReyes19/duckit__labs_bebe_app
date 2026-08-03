part of 'agenda_bloc.dart';
sealed class AgendaEvent extends Equatable { const AgendaEvent(); @override List<Object?> get props => const []; }
final class AgendaStarted extends AgendaEvent { const AgendaStarted(); }
final class AgendaRefreshed extends AgendaEvent { const AgendaRefreshed(); }
final class AgendaRetried extends AgendaEvent { const AgendaRetried(); }
