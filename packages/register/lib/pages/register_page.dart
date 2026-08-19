import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:register/register.dart';

typedef SaveRegisterEventFactory = SaveRegisterEvent Function(
  BuildContext context,
);
typedef UpdateRegisterEventFactory = UpdateRegisterEvent Function(
  BuildContext context,
);
typedef RegisterRouteSaved = FutureOr<void> Function(
  BuildContext context,
  RegisteredEvent event,
);
typedef RegisterRouteAction = void Function(BuildContext context);
typedef GetFamilyOverviewFactory = GetFamilyOverview Function(
  BuildContext context,
);

class RegisterPage extends GoRoute {
  RegisterPage({
    required SaveRegisterEventFactory saveRegisterEvent,
    required RegisterRouteSaved onSaved,
    required RegisterRouteAction onCancel,
    this.updateRegisterEvent,
    this.onUpdated,
    this.getFamilyOverview,
    this.onNotificationsPressed,
    this.onHomePressed,
    this.onAgendaPressed,
    this.onHealthPressed,
    this.onFamilyPressed,
    this.onBabyPressed,
    this.babyId = 'baby-preview',
    this.babyName = 'Tu bebé',
    this.babyAge = 'Perfil activo',
    this.familyContextLabel = 'Tu familia',
    super.name,
    super.parentNavigatorKey,
    List<RouteBase> routes = const <RouteBase>[],
  }) : super(
          path: fullPath,
          redirect: (context, state) {
            final legacyType = state.uri.queryParameters['type'];
            if (legacyType == null) {
              return null;
            }
            return locationFor(
              RegisterEventKind.fromRouteValue(legacyType),
            );
          },
          pageBuilder: (context, state) => _buildPage(
            context: context,
            kind: RegisterEventKind.feeding,
            pageName: name ?? nameRoute,
            saveRegisterEvent: saveRegisterEvent,
            updateRegisterEvent: updateRegisterEvent,
            onSaved: onSaved,
            onUpdated: onUpdated,
            editingEvent: state.extra is RegisteredEvent
                ? state.extra! as RegisteredEvent
                : null,
            onCancel: onCancel,
            onNotificationsPressed: onNotificationsPressed,
            onHomePressed: onHomePressed,
            onAgendaPressed: onAgendaPressed,
            onHealthPressed: onHealthPressed,
            onFamilyPressed: onFamilyPressed,
            onBabyPressed: onBabyPressed,
            babyId: babyId,
            babyName: babyName,
            babyAge: babyAge,
            familyContextLabel: familyContextLabel,
            getFamilyOverview: getFamilyOverview,
          ),
          routes: [
            GoRoute(
              name: kindNameRoute,
              path: kindPath,
              redirect: (context, state) {
                final routeValue = state.pathParameters['kind'];
                final kind = RegisterEventKind.tryFromRouteValue(routeValue);
                if (kind == null || kind == RegisterEventKind.feeding) {
                  return fullPath;
                }
                if (routeValue != kind.routeValue) {
                  return locationFor(kind);
                }
                return null;
              },
              pageBuilder: (context, state) => _buildPage(
                context: context,
                kind: RegisterEventKind.fromRouteValue(
                  state.pathParameters['kind'],
                ),
                pageName: kindNameRoute,
                saveRegisterEvent: saveRegisterEvent,
                updateRegisterEvent: updateRegisterEvent,
                onSaved: onSaved,
                onUpdated: onUpdated,
                editingEvent: state.extra is RegisteredEvent
                    ? state.extra! as RegisteredEvent
                    : null,
                onCancel: onCancel,
                onNotificationsPressed: onNotificationsPressed,
                onHomePressed: onHomePressed,
                onAgendaPressed: onAgendaPressed,
                onHealthPressed: onHealthPressed,
                onFamilyPressed: onFamilyPressed,
                onBabyPressed: onBabyPressed,
                babyId: babyId,
                babyName: babyName,
                babyAge: babyAge,
                familyContextLabel: familyContextLabel,
                getFamilyOverview: getFamilyOverview,
              ),
            ),
            ...routes,
          ],
        );

  final String babyId;
  final String babyName;
  final String babyAge;
  final String familyContextLabel;
  final GetFamilyOverviewFactory? getFamilyOverview;
  final UpdateRegisterEventFactory? updateRegisterEvent;
  final RegisterRouteSaved? onUpdated;
  final RegisterRouteAction? onNotificationsPressed;
  final RegisterRouteAction? onHomePressed;
  final RegisterRouteAction? onAgendaPressed;
  final RegisterRouteAction? onHealthPressed;
  final RegisterRouteAction? onFamilyPressed;
  final RegisterRouteAction? onBabyPressed;

  static const nameRoute = 'Register';
  static const kindNameRoute = 'RegisterKind';
  static const fullPath = '/register';
  static const kindPath = ':kind';

  static String locationFor(RegisterEventKind kind) {
    if (kind == RegisterEventKind.feeding) {
      return fullPath;
    }
    return '$fullPath/${kind.routeValue}';
  }

  static void open(BuildContext context, {RegisterEventKind? kind}) {
    context.push(locationFor(kind ?? RegisterEventKind.feeding));
  }

  static void openForEdit(BuildContext context, RegisteredEvent event) {
    context.push(locationFor(_kindForType(event.type)), extra: event);
  }

  static Future<void> openForEditAndWait(
    BuildContext context,
    RegisteredEvent event,
  ) async {
    await context.push<void>(
      locationFor(_kindForType(event.type)),
      extra: event,
    );
  }
}

Page<void> _buildPage({
  required BuildContext context,
  required RegisterEventKind kind,
  required String pageName,
  required SaveRegisterEventFactory saveRegisterEvent,
  required UpdateRegisterEventFactory? updateRegisterEvent,
  required RegisterRouteSaved onSaved,
  required RegisterRouteSaved? onUpdated,
  required RegisteredEvent? editingEvent,
  required RegisterRouteAction onCancel,
  required RegisterRouteAction? onNotificationsPressed,
  required RegisterRouteAction? onHomePressed,
  required RegisterRouteAction? onAgendaPressed,
  required RegisterRouteAction? onHealthPressed,
  required RegisterRouteAction? onFamilyPressed,
  required RegisterRouteAction? onBabyPressed,
  required String babyId,
  required String babyName,
  required String babyAge,
  required String familyContextLabel,
  required GetFamilyOverviewFactory? getFamilyOverview,
}) {
  final save = saveRegisterEvent(context);
  final update = updateRegisterEvent?.call(context);
  final persist = editingEvent == null || update == null
      ? null
      : (RegisterEventDraft draft) async {
          if (draft.type != editingEvent.type) {
            throw StateError('The register event type cannot be changed.');
          }
          final notes = draft.notes?.trim();
          final caregiverId = draft.caregiverId?.trim();
          final updated = await update(
            editingEvent.id,
            RegisterEventPatch(
              occurredAt: draft.occurredAt,
              details: draft.details,
              notes: notes?.isEmpty == false ? notes : null,
              clearNotes: notes == null || notes.isEmpty,
              caregiverId: caregiverId?.isEmpty == false ? caregiverId : null,
              clearCaregiverId: caregiverId == null || caregiverId.isEmpty,
              schemaVersion: draft.schemaVersion,
            ),
          );
          if (updated == null) {
            throw StateError('The register event no longer exists.');
          }
          return updated;
        };
  return MaterialPage<void>(
    key: ValueKey(
      editingEvent == null
          ? 'register-${kind.routeValue}'
          : 'edit-register-${editingEvent.id}',
    ),
    name: pageName,
    child: getFamilyOverview == null
        ? _RegisterContent(
            kind: kind,
            save: save,
            persist: persist,
            initialEvent: editingEvent,
            onSaved: editingEvent == null ? onSaved : onUpdated ?? onSaved,
            onCancel: onCancel,
            onNotificationsPressed: onNotificationsPressed,
            onHomePressed: onHomePressed,
            onAgendaPressed: onAgendaPressed,
            onHealthPressed: onHealthPressed,
            onFamilyPressed: onFamilyPressed,
            onBabyPressed: onBabyPressed,
            babyId: editingEvent?.babyId ?? babyId,
            babyName: babyName,
            babyAge: babyAge,
            familyContextLabel: familyContextLabel,
          )
        : _FamilyAwareRegisterContent(
            getFamilyOverview: getFamilyOverview(context),
            builder: (context, family) {
              final activeBaby = family.activeBaby;
              return _RegisterContent(
                kind: kind,
                save: save,
                persist: persist,
                initialEvent: editingEvent,
                onSaved: editingEvent == null ? onSaved : onUpdated ?? onSaved,
                onCancel: onCancel,
                onNotificationsPressed: onNotificationsPressed,
                onHomePressed: onHomePressed,
                onAgendaPressed: onAgendaPressed,
                onHealthPressed: onHealthPressed,
                onFamilyPressed: onFamilyPressed,
                onBabyPressed: onBabyPressed,
                babyId: editingEvent?.babyId ?? activeBaby.id,
                babyName: activeBaby.name,
                babyAge: _babyAge(activeBaby.birthDate, DateTime.now()),
                familyContextLabel: family.babies.length == 1
                    ? '1 bebé en la familia'
                    : '${family.babies.length} bebés en la familia',
                babyAvatar: _babyAvatar(activeBaby),
              );
            },
            onRetry: () => RegisterPage.open(context, kind: kind),
          ),
  );
}

class _FamilyAwareRegisterContent extends StatefulWidget {
  const _FamilyAwareRegisterContent({
    required this.getFamilyOverview,
    required this.builder,
    required this.onRetry,
  });

  final GetFamilyOverview getFamilyOverview;
  final Widget Function(BuildContext context, FamilyOverviewEntity family)
      builder;
  final VoidCallback onRetry;

  @override
  State<_FamilyAwareRegisterContent> createState() =>
      _FamilyAwareRegisterContentState();
}

class _FamilyAwareRegisterContentState
    extends State<_FamilyAwareRegisterContent> {
  late Future<FamilyOverviewEntity> _family;
  FamilyOverviewEntity? _cachedFamily;
  late final StreamSubscription<String> _activeBabySubscription;

  @override
  void initState() {
    super.initState();
    _cachedFamily = widget.getFamilyOverview.cached;
    _family =
        _cachedFamily == null ? _loadFamily() : Future.value(_cachedFamily!);
    _activeBabySubscription = widget.getFamilyOverview.activeBabyChanges.listen(
      (_) {
        if (mounted) {
          setState(() {
            _cachedFamily = null;
            _family = _loadFamily();
          });
        }
      },
    );
  }

  Future<FamilyOverviewEntity> _loadFamily() async {
    final family = await widget.getFamilyOverview();
    if (mounted) setState(() => _cachedFamily = family);
    return family;
  }

  @override
  void dispose() {
    unawaited(_activeBabySubscription.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cached = _cachedFamily;
    if (cached != null) {
      return KeyedSubtree(
        key: ValueKey('register-active-baby-${cached.activeBabyId}'),
        child: widget.builder(context, cached),
      );
    }
    return FutureBuilder<FamilyOverviewEntity>(
      future: _family,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _RegisterBabySwitchLoading();
        }
        final family = snapshot.data;
        if (family == null) {
          return _RegisterContextError(onRetry: widget.onRetry);
        }
        return KeyedSubtree(
          key: ValueKey('register-active-baby-${family.activeBabyId}'),
          child: widget.builder(context, family),
        );
      },
    );
  }
}

class _RegisterBabySwitchLoading extends StatelessWidget {
  const _RegisterBabySwitchLoading();

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;
    return Scaffold(
      key: const ValueKey('register-baby-switch-loading'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(spacing.spacingXl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const BebeSkeleton.circle(size: 40),
                  SizedBox(width: spacing.spacingM),
                  const Expanded(
                    child: BebeSkeleton.line(height: 22, width: 180),
                  ),
                  const BebeSkeleton.circle(size: 40),
                ],
              ),
              SizedBox(height: spacing.spacingXl),
              const BebeSkeleton(height: 92),
              SizedBox(height: spacing.spacingXl),
              Row(
                children: [
                  for (var index = 0; index < 3; index++) ...[
                    const Expanded(child: BebeSkeleton(height: 72)),
                    if (index != 2) SizedBox(width: spacing.spacingM),
                  ],
                ],
              ),
              SizedBox(height: spacing.spacing2xl),
              const BebeSkeleton.line(height: 20, width: 190),
              SizedBox(height: spacing.spacingM),
              const BebeSkeleton(height: 260),
              SizedBox(height: spacing.spacingXl),
              const BebeSkeleton.line(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisterContent extends StatelessWidget {
  const _RegisterContent({
    required this.kind,
    required this.save,
    required this.persist,
    required this.initialEvent,
    required this.onSaved,
    required this.onCancel,
    required this.onNotificationsPressed,
    required this.onHomePressed,
    required this.onAgendaPressed,
    required this.onHealthPressed,
    required this.onFamilyPressed,
    required this.onBabyPressed,
    required this.babyId,
    required this.babyName,
    required this.babyAge,
    required this.familyContextLabel,
    this.babyAvatar,
  });

  final RegisterEventKind kind;
  final SaveRegisterEvent save;
  final PersistRegisterEvent? persist;
  final RegisteredEvent? initialEvent;
  final RegisterRouteSaved onSaved;
  final RegisterRouteAction onCancel;
  final RegisterRouteAction? onNotificationsPressed;
  final RegisterRouteAction? onHomePressed;
  final RegisterRouteAction? onAgendaPressed;
  final RegisterRouteAction? onHealthPressed;
  final RegisterRouteAction? onFamilyPressed;
  final RegisterRouteAction? onBabyPressed;
  final String babyId;
  final String babyName;
  final String babyAge;
  final String familyContextLabel;
  final BebeAvatar? babyAvatar;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => FeedingRegisterCubit(
              saveRegisterEvent: save,
              persistRegisterEvent: persist,
              initialEvent: initialEvent,
              babyId: babyId,
            ),
          ),
          BlocProvider(
            create: (_) => SleepRegisterCubit(
              saveRegisterEvent: save,
              persistRegisterEvent: persist,
              initialEvent: initialEvent,
              babyId: babyId,
            ),
          ),
          BlocProvider(
            create: (_) => DiaperRegisterCubit(
              saveRegisterEvent: save,
              persistRegisterEvent: persist,
              initialEvent: initialEvent,
              babyId: babyId,
            ),
          ),
          BlocProvider(
            create: (_) => ClinicalObservationRegisterCubit(
              saveRegisterEvent: save,
              persistRegisterEvent: persist,
              initialEvent: initialEvent,
              babyId: babyId,
            ),
          ),
          BlocProvider(
            create: (_) => MedicationRegisterCubit(
              saveRegisterEvent: save,
              persistRegisterEvent: persist,
              initialEvent: initialEvent,
              babyId: babyId,
            ),
          ),
          BlocProvider(
            create: (_) => MeasurementRegisterCubit(
              saveRegisterEvent: save,
              persistRegisterEvent: persist,
              initialEvent: initialEvent,
              babyId: babyId,
            ),
          ),
        ],
        child: Builder(
          builder: (pageContext) => RegisterPageView(
            initialKind: kind,
            initialEvent: initialEvent,
            isEditing: initialEvent != null,
            babyName: babyName,
            babyAge: babyAge,
            familyContextLabel: familyContextLabel,
            babyAvatar: babyAvatar,
            // Las categorías se comportan como tabs locales. Navegar por cada
            // cambio recreaba la página, repetía la carga del perfil activo y
            // dejaba un frame blanco entre formularios.
            onKindChanged: (_) {},
            onSaved: (event) => unawaited(
              Future<void>.sync(() => onSaved(pageContext, event)),
            ),
            onCancel: () => onCancel(pageContext),
            onNotificationsPressed: onNotificationsPressed == null
                ? null
                : () => onNotificationsPressed!(pageContext),
            onHomePressed: onHomePressed == null
                ? null
                : () => onHomePressed!(pageContext),
            onAgendaPressed: onAgendaPressed == null
                ? null
                : () => onAgendaPressed!(pageContext),
            onHealthPressed: onHealthPressed == null
                ? null
                : () => onHealthPressed!(pageContext),
            onFamilyPressed: onFamilyPressed == null
                ? null
                : () => onFamilyPressed!(pageContext),
            onBabyPressed: onBabyPressed == null
                ? null
                : () => onBabyPressed!(pageContext),
          ),
        ),
      );
}

class _RegisterContextError extends StatelessWidget {
  const _RegisterContextError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.child_care_outlined, size: 42),
              const SizedBox(height: 12),
              const Text(
                'No pudimos identificar el perfil activo.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
}

BebeAvatar? _babyAvatar(BabyEntity baby) {
  final path = baby.avatarAssetPath;
  if (path == null || path.isEmpty) return null;
  final file = File(path);
  if (!file.existsSync()) return null;
  return BebeAvatar.image(
    image: FileImage(file),
    size: BebeAvatarSize.lg,
    semanticLabel: 'Foto de ${baby.name}',
  );
}

String _babyAge(DateTime birthDate, DateTime referenceDate) {
  final birth = birthDate.toLocal();
  var months = (referenceDate.year - birth.year) * 12 +
      referenceDate.month -
      birth.month;
  if (referenceDate.day < birth.day) months--;
  if (months <= 0) return 'Menos de un mes';
  return months == 1 ? '1 mes' : '$months meses';
}

RegisterEventKind _kindForType(RegisterEventType type) => switch (type) {
      RegisterEventType.feeding => RegisterEventKind.feeding,
      RegisterEventType.sleep => RegisterEventKind.sleep,
      RegisterEventType.diaper => RegisterEventKind.diaper,
      RegisterEventType.clinicalObservation => RegisterEventKind.observation,
      RegisterEventType.medication => RegisterEventKind.medication,
      RegisterEventType.measurement => RegisterEventKind.measurement,
    };
