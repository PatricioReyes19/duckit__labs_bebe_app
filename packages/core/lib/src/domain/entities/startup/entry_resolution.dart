import 'entry_destination.dart';

class EntryResolution {
  const EntryResolution({
    required this.destination,
    this.reason,
  });

  final EntryDestination destination;
  final String? reason;
}
