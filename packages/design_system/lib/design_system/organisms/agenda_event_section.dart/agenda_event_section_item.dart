import 'package:flutter/widgets.dart';

@immutable
class BebeAgendaEventSectionItem {
  const BebeAgendaEventSectionItem({required this.id, required this.child});

  final String id;
  final Widget child;
}
