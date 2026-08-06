import '../../entities/startup/startup.dart';

abstract interface class ResolveEntryDestination {
  Future<EntryResolution> call();
}
