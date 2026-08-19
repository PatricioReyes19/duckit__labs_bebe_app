/// Stable keyset cursor for Supabase delta pulls.
///
/// `updated_at` alone is not unique: two caregivers can write rows with the
/// same server timestamp. Keeping the row id as a tiebreaker prevents both
/// skipped rows and repeated inclusive pulls.
class RemoteSyncCursor {
  const RemoteSyncCursor({required this.updatedAt, required this.id});

  final DateTime updatedAt;
  final String id;
}
