class ActiveContext {
  const ActiveContext({
    required this.userId,
    required this.circleId,
    required this.babyId,
  });

  final String userId;
  final String circleId;
  final String babyId;
}

abstract interface class ActiveContextRepository {
  Future<ActiveContext?> read();

  Future<void> save(ActiveContext context);

  Future<void> clear();
}
