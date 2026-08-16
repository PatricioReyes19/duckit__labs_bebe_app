import 'package:app_base/src/notifications/notification_navigation_guard.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notifications/notifications.dart';

void main() {
  const user = AuthUser(
    id: 'user-1',
    email: 'caregiver@example.com',
    displayName: 'Caregiver',
    emailVerification: true,
  );
  const session = AuthSession(user: user);
  final family = FamilyOverviewEntity(
    id: 'family-1',
    name: 'Familia',
    activeBabyId: 'baby-1',
    babies: [
      BabyEntity(
        id: 'baby-1',
        familyId: 'family-1',
        name: 'Bebé',
        birthDate: DateTime.utc(2025),
      ),
    ],
    members: const [],
  );

  test('IT-NOTIF-004 tap opens the authorized destination', () async {
    final contextRepository = _MemoryActiveContextRepository();
    String? activatedBabyId;
    final guard = NotificationNavigationGuard(
      getCurrentSession: () async => session,
      restoreAuthenticatedContext: (_) async => const EntryResolution(
        destination: EntryDestination.selectBaby,
      ),
      readAvailableFamilies: () async => [family],
      activateBaby: (babyId) async => activatedBabyId = babyId,
      activeContextRepository: contextRepository,
    );
    final notification = AppNotification(
      id: 'notification-1',
      title: 'Recordatorio',
      body: 'Tienes un recordatorio.',
      receivedAt: DateTime.utc(2026, 8, 16),
      data: const {
        'route': '/agenda/events/event-1',
        'account_id': 'user-1',
        'baby_id': 'baby-1',
      },
    );

    expect(await guard.resolve(notification), '/agenda/events/event-1');
    expect(activatedBabyId, 'baby-1');
    expect(contextRepository.value?.userId, 'user-1');
    expect(contextRepository.value?.babyId, 'baby-1');
  });

  test('IT-NOTIF-005 tap with revoked baby access stays in inbox', () async {
    var activationCount = 0;
    final guard = NotificationNavigationGuard(
      getCurrentSession: () async => session,
      restoreAuthenticatedContext: (_) async => const EntryResolution(
        destination: EntryDestination.home,
      ),
      readAvailableFamilies: () async => [family],
      activateBaby: (_) async => activationCount += 1,
      activeContextRepository: _MemoryActiveContextRepository(),
    );
    final notification = AppNotification(
      id: 'notification-revoked',
      title: 'Recordatorio',
      body: 'Tienes un recordatorio.',
      receivedAt: DateTime.utc(2026, 8, 16),
      data: const {
        'route': '/health',
        'account_id': 'user-1',
        'baby_id': 'baby-revoked',
      },
    );

    expect(await guard.resolve(notification), '/notifications');
    expect(activationCount, 0);
  });

  test('IT-NOTIF-006 logout never restores the previous baby context',
      () async {
    var restoreCount = 0;
    var activationCount = 0;
    final contextRepository = _MemoryActiveContextRepository()
      ..value = const ActiveContext(
        userId: 'user-1',
        circleId: 'family-1',
        babyId: 'baby-1',
      );
    final guard = NotificationNavigationGuard(
      getCurrentSession: () async => null,
      restoreAuthenticatedContext: (_) async {
        restoreCount += 1;
        return const EntryResolution(destination: EntryDestination.home);
      },
      readAvailableFamilies: () async => [family],
      activateBaby: (_) async => activationCount += 1,
      activeContextRepository: contextRepository,
    );
    final notification = AppNotification(
      id: 'notification-old-account',
      title: 'Recordatorio',
      body: 'Tienes un recordatorio.',
      receivedAt: DateTime.utc(2026, 8, 16),
      data: const {
        'route': '/health',
        'account_id': 'user-1',
        'baby_id': 'baby-1',
      },
    );

    expect(await guard.resolve(notification), '/login');
    expect(restoreCount, 0);
    expect(activationCount, 0);
  });

  test('logged-out invitation tap preserves its invitation code', () async {
    final guard = NotificationNavigationGuard(
      getCurrentSession: () async => null,
      restoreAuthenticatedContext: (_) async => const EntryResolution(
        destination: EntryDestination.home,
      ),
      readAvailableFamilies: () async => [family],
      activateBaby: (_) async {},
      activeContextRepository: _MemoryActiveContextRepository(),
    );
    final notification = AppNotification(
      id: 'invitation-1',
      title: 'Invitación',
      body: 'Tienes una invitación.',
      receivedAt: DateTime.utc(2026, 8, 16),
      data: const {
        'route': '/invitation?code=ABC123',
        'account_id': 'user-1',
        'baby_id': 'baby-1',
      },
    );

    expect(
      await guard.resolve(notification),
      '/login?next=invitation&code=ABC123',
    );
  });
}

class _MemoryActiveContextRepository implements ActiveContextRepository {
  ActiveContext? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<ActiveContext?> read() async => value;

  @override
  Future<void> save(ActiveContext context) async => value = context;
}
