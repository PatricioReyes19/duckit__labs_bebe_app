import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:family/family.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class FamilyFlowView extends StatelessWidget {
  const FamilyFlowView({
    required this.kind,
    required this.getFamilyOverview,
    required this.familyRepository,
    required this.onClose,
    required this.onBabySelected,
    required this.onBabyCreated,
    this.babyId,
    this.memberId,
    super.key,
  });

  final FamilySubpageKind kind;
  final GetFamilyOverview getFamilyOverview;
  final FamilyRepository familyRepository;
  final String? babyId;
  final String? memberId;
  final VoidCallback onClose;
  final ValueChanged<String> onBabySelected;
  final ValueChanged<FamilyBabyDraftResult> onBabyCreated;

  @override
  Widget build(BuildContext context) => FutureBuilder<FamilyOverviewEntity>(
    future: getFamilyOverview(),
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Center(child: CircularProgressIndicator());
      }
      final family = snapshot.data;
      if (family == null) {
        return const Center(child: Text('No pudimos cargar la familia.'));
      }
      return switch (kind) {
        FamilySubpageKind.babySelector => _BabySelectorView(
          family: family,
          onSelected: onBabySelected,
        ),
        FamilySubpageKind.addBaby => _AddBabyView(onCreated: onBabyCreated),
        FamilySubpageKind.babyDetail => _BabyDetailView(
          family: family,
          babyId: babyId ?? family.activeBabyId,
        ),
        FamilySubpageKind.careCircle => _CareCircleView(
          family: family,
          repository: familyRepository,
          getFamilyOverview: getFamilyOverview,
        ),
        FamilySubpageKind.inviteCaregiver => _InviteCaregiverView(
          familyId: family.id,
          babyId: family.activeBaby.id,
          babyName: family.activeBaby.name,
          onCompleted: onClose,
        ),
        FamilySubpageKind.memberDetail => _MemberDetailView(
          family: family,
          memberId: memberId ?? family.members.first.id,
          onRevoked: onClose,
        ),
        FamilySubpageKind.familyConfiguration =>
          const _FamilyConfigurationView(),
      };
    },
  );
}

class _FlowPage extends StatelessWidget {
  const _FlowPage({
    required this.description,
    required this.children,
    this.maxWidth = BebeLayout.formContentMaxWidth,
  });

  final String description;
  final List<Widget> children;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return ColoredBox(
      color: theme.colors.background.neutralsPage,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          theme.spacing.spacingL,
          theme.spacing.spacingL,
          theme.spacing.spacingL,
          theme.spacing.spacing5xl,
        ),
        child: BebeResponsiveContent(
          maxWidth: maxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                description,
                style: theme.typography.styles.body.md.regular.copyWith(
                  color: theme.colors.text.neutralBody,
                ),
              ),
              SizedBox(height: theme.spacing.spacingXl),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _BabySelectorView extends StatelessWidget {
  const _BabySelectorView({required this.family, required this.onSelected});

  final FamilyOverviewEntity family;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FamilyFlowBloc, FamilyFlowState>(
      builder: (context, state) {
        final bloc = context.read<FamilyFlowBloc>();
        final selectedId = state.selectedBabyId.isEmpty
            ? family.activeBabyId
            : state.selectedBabyId;
        return _FlowPage(
          description:
              'El perfil activo organiza Inicio, Agenda, Salud y los nuevos registros.',
          children: [
            for (var index = 0; index < family.babies.length; index++) ...[
              _BabyChoiceCard(
                name: family.babies[index].name,
                age: _familyBabyAge(family.babies[index].birthDate),
                initials: _initials(family.babies[index].name),
                selected: selectedId == family.babies[index].id,
                accent: index.isOdd,
                onPressed: () =>
                    bloc.add(FamilyFlowBabySelected(family.babies[index].id)),
              ),
              if (index != family.babies.length - 1)
                SizedBox(height: context.theme.spacing.spacingM),
            ],
            SizedBox(height: context.theme.spacing.spacingXl),
            BebeInfoBanner(
              title: 'Todo queda en su lugar',
              description:
                  'Cambiar de bebé no mezcla historiales ni recordatorios.',
              icon: const Icon(Icons.auto_awesome_rounded),
              variant: BebeInfoBannerVariant.brand,
            ),
            SizedBox(height: context.theme.spacing.spacingXl),
            BebeButton(
              label: 'Usar este perfil',
              leading: const Icon(Icons.check_rounded),
              onPressed: () => onSelected(selectedId),
            ),
            SizedBox(height: context.theme.spacing.spacingM),
            BebeButton(
              label: 'Agregar otro bebé',
              variant: BebeButtonVariant.secondary,
              leading: const Icon(Icons.add_rounded),
              onPressed: () => context.push(FamilySubpage.addBabyPath),
            ),
          ],
        );
      },
    );
  }
}

class _BabyChoiceCard extends StatelessWidget {
  const _BabyChoiceCard({
    required this.name,
    required this.age,
    required this.initials,
    required this.selected,
    required this.onPressed,
    this.accent = false,
  });

  final String name;
  final String age;
  final String initials;
  final bool selected;
  final VoidCallback onPressed;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Material(
      color: selected
          ? theme.colors.background.brandSurface
          : theme.colors.background.neutralsSurface,
      shape: RoundedRectangleBorder(
        borderRadius: theme.borderRadius.x3l,
        side: BorderSide(
          color: selected
              ? theme.colors.border.brandAlternative
              : theme.colors.border.neutralDefault,
          width: selected ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.all(theme.spacing.spacingL),
          child: Row(
            children: [
              _InitialAvatar(initials: initials, accent: accent, size: 64),
              SizedBox(width: theme.spacing.spacingL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.typography.styles.title.md.semibold.copyWith(
                        color: theme.colors.text.neutralTitle,
                      ),
                    ),
                    SizedBox(height: theme.spacing.spacingXs),
                    Text(
                      age,
                      style: theme.typography.styles.body.sm.regular.copyWith(
                        color: theme.colors.text.neutralBody,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: selected
                    ? Icon(
                        Icons.check_circle_rounded,
                        key: const ValueKey('selected'),
                        color: theme.colors.icons.brandDefault,
                      )
                    : Icon(
                        Icons.radio_button_unchecked_rounded,
                        key: const ValueKey('unselected'),
                        color: theme.colors.icons.neutralAlternative,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddBabyView extends StatefulWidget {
  const _AddBabyView({required this.onCreated});

  final ValueChanged<FamilyBabyDraftResult> onCreated;

  @override
  State<_AddBabyView> createState() => _AddBabyViewState();
}

class _AddBabyViewState extends State<_AddBabyView> {
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return _FlowPage(
      description:
          'Crea un perfil independiente para conservar su crecimiento, salud y rutina.',
      children: [
        Align(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              const _InitialAvatar(initials: 'BB', size: 96),
              Material(
                color: theme.colors.background.brandDefault,
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: 'Agregar fotografía',
                  onPressed: () => _showMessage(
                    context,
                    'Podrás elegir una foto al guardar el perfil.',
                  ),
                  color: theme.colors.onPrimary.neutralDefault,
                  icon: const Icon(Icons.camera_alt_outlined),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: theme.spacing.spacingXl),
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Nombre del bebé',
            hintText: 'Ej. Mateo Reyes',
            errorText: _error,
            prefixIcon: const Icon(Icons.child_care_rounded),
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
        ),
        SizedBox(height: theme.spacing.spacingL),
        InkWell(
          borderRadius: theme.borderRadius.xl,
          onTap: _pickBirthDate,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Fecha de nacimiento',
              prefixIcon: Icon(Icons.calendar_month_outlined),
              suffixIcon: Icon(Icons.chevron_right_rounded),
              border: OutlineInputBorder(),
            ),
            child: Text(
              _birthDate == null
                  ? 'Seleccionar fecha'
                  : MaterialLocalizations.of(
                      context,
                    ).formatMediumDate(_birthDate!),
            ),
          ),
        ),
        SizedBox(height: theme.spacing.spacingXl),
        BebeInfoBanner(
          title: 'Privado por diseño',
          description:
              'Solo las personas que autorices podrán ver este perfil.',
          icon: const Icon(Icons.shield_outlined),
        ),
        SizedBox(height: theme.spacing.spacingXl),
        BebeButton(
          label: 'Guardar perfil',
          leading: const Icon(Icons.check_rounded),
          onPressed: _save,
        ),
      ],
    );
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDate: _birthDate ?? DateTime(now.year, now.month - 2, now.day),
      helpText: 'Fecha de nacimiento',
    );
    if (date != null && mounted) setState(() => _birthDate = date);
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.length < 2) {
      setState(() => _error = 'Escribe al menos 2 caracteres.');
      return;
    }
    if (_birthDate == null) {
      _showMessage(context, 'Selecciona la fecha de nacimiento.');
      return;
    }
    widget.onCreated(FamilyBabyDraftResult(name: name, birthDate: _birthDate!));
  }
}

class _BabyDetailView extends StatelessWidget {
  const _BabyDetailView({required this.family, required this.babyId});

  final FamilyOverviewEntity family;
  final String babyId;

  @override
  Widget build(BuildContext context) {
    final baby = family.babies.firstWhere(
      (item) => item.id == babyId,
      orElse: () => family.activeBaby,
    );
    final name = baby.name;
    final age = _familyBabyAge(baby.birthDate);
    final initials = _initials(baby.name);
    final activeCaregivers = family.members
        .where((member) => member.status == FamilyMemberStatus.active)
        .length;
    final pendingInvitations = family.pendingInvitations;
    final theme = context.theme;

    return _FlowPage(
      description:
          'Información, accesos rápidos y personas que acompañan su cuidado.',
      maxWidth: BebeLayout.pageContentMaxWidth,
      children: [
        _SurfaceCard(
          child: Padding(
            padding: EdgeInsets.all(theme.spacing.spacingXl),
            child: Row(
              children: [
                _InitialAvatar(initials: initials, size: 92),
                SizedBox(width: theme.spacing.spacingXl),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.typography.styles.title.lg.bold.copyWith(
                          color: theme.colors.text.neutralTitle,
                        ),
                      ),
                      SizedBox(height: theme.spacing.spacingS),
                      Text(
                        age,
                        style: theme.typography.styles.title.md.semibold
                            .copyWith(color: theme.colors.text.brandDefault),
                      ),
                      SizedBox(height: theme.spacing.spacingS),
                      Text(
                        '$activeCaregivers ${activeCaregivers == 1 ? 'cuidador' : 'cuidadores'} con acceso',
                        style: theme.typography.styles.body.sm.regular.copyWith(
                          color: theme.colors.text.neutralBody,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Editar datos',
                  onPressed: () => _showMessage(
                    context,
                    'La edición del perfil se guardará en este bebé.',
                  ),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: theme.spacing.spacingXl),
        BebeSettingsSection(
          title: 'Información básica',
          children: [
            BebeSettingsValueTile(
              title: 'Fecha de nacimiento',
              value: _familyBirthDate(baby.birthDate),
              onPressed: () => _showMessage(context, 'Editar fecha'),
            ),
            BebeSettingsValueTile(
              title: 'Fotografía',
              value: baby.avatarAssetPath == null ? 'Sin foto' : 'Agregada',
              onPressed: () => _showMessage(context, 'Cambiar fotografía'),
            ),
            BebeSettingsValueTile(
              title: 'Referencia para crecimiento',
              value: 'Definida al crear el perfil',
              onPressed: () => _showMessage(context, 'Editar referencia'),
            ),
          ],
        ),
        SizedBox(height: theme.spacing.spacingXl),
        BebeSettingsSection(
          title: 'Accesos rápidos',
          children: [
            BebeSettingsActionTile(
              title: 'Crecimiento',
              description: 'Peso, talla y percentiles',
              icon: const Icon(Icons.show_chart_rounded),
              onPressed: () => context.go('/health/growth'),
            ),
            BebeSettingsActionTile(
              title: 'Vacunas y controles',
              description: 'Próximas dosis y controles',
              icon: const Icon(Icons.vaccines_outlined),
              onPressed: () => context.go('/health/vaccines'),
            ),
            BebeSettingsActionTile(
              title: 'Historial clínico',
              description: 'Registros y visitas previas',
              icon: const Icon(Icons.assignment_outlined),
              onPressed: () => context.go('/health/clinical-history'),
            ),
          ],
        ),
        SizedBox(height: theme.spacing.spacingXl),
        BebeSettingsSection(
          title: 'Cuidado compartido',
          children: [
            BebeSettingsActionTile(
              title:
                  '$activeCaregivers ${activeCaregivers == 1 ? 'cuidador activo' : 'cuidadores activos'}',
              description: 'Familiares y personas de confianza',
              icon: const Icon(Icons.groups_2_outlined),
              onPressed: () => context.push(FamilySubpage.careCirclePath),
            ),
            BebeSettingsActionTile(
              title: 'Gestionar invitaciones',
              description: pendingInvitations == 1
                  ? '1 invitación pendiente'
                  : '$pendingInvitations invitaciones pendientes',
              icon: const Icon(Icons.mark_email_unread_outlined),
              onPressed: () => context.push(FamilySubpage.inviteCaregiverPath),
            ),
          ],
        ),
      ],
    );
  }
}

class _CareCircleView extends StatefulWidget {
  const _CareCircleView({
    required this.family,
    required this.repository,
    required this.getFamilyOverview,
  });

  final FamilyOverviewEntity family;
  final FamilyRepository repository;
  final GetFamilyOverview getFamilyOverview;

  @override
  State<_CareCircleView> createState() => _CareCircleViewState();
}

class _CareCircleViewState extends State<_CareCircleView> {
  late FamilyOverviewEntity _family = widget.family;
  String? _busyMemberId;

  @override
  Widget build(BuildContext context) {
    final family = _family;
    final theme = context.theme;
    return _FlowPage(
      description:
          'Administra quién puede acompañar el cuidado de ${family.activeBaby.name} y qué puede hacer.',
      children: [
        if (family.pendingInvitations > 0) ...[
          BebeInfoBanner(
            title: family.pendingInvitations == 1
                ? '1 invitación pendiente'
                : '${family.pendingInvitations} invitaciones pendientes',
            description: 'Puedes revisar o reenviar los accesos pendientes.',
            icon: const Icon(Icons.schedule_send_outlined),
            variant: BebeInfoBannerVariant.warning,
          ),
          SizedBox(height: theme.spacing.spacingXl),
          const BebeTitleSection(title: 'Invitaciones enviadas'),
          SizedBox(height: theme.spacing.spacingL),
          for (final member in family.members)
            if (member.status == FamilyMemberStatus.pending) ...[
              _PendingInvitationCard(
                member: member,
                isLoading: _busyMemberId == member.id,
                onResend: () => _resend(member),
                onCancel: () => _cancel(member),
                onCopy: () => _copyMemberInvitation(context, member),
              ),
              SizedBox(height: theme.spacing.spacingM),
            ],
          SizedBox(height: theme.spacing.spacingXl),
        ],
        const BebeTitleSection(title: 'Cuidadores activos'),
        SizedBox(height: theme.spacing.spacingL),
        for (var index = 0; index < family.members.length; index++)
          if (family.members[index].status == FamilyMemberStatus.active) ...[
            _MemberCard(
              name: family.members[index].name,
              role:
                  '${family.members[index].role} · ${family.members[index].accessDescription}',
              initials: _initials(family.members[index].name),
              accent: index.isOdd,
              onPressed: () => context.push(
                FamilySubpage.memberDetailPath(family.members[index].id),
              ),
            ),
            SizedBox(height: theme.spacing.spacingM),
          ],
        SizedBox(height: theme.spacing.spacingXl),
        BebeButton(
          label: 'Invitar cuidador',
          leading: const Icon(Icons.person_add_alt_1_rounded),
          onPressed: () => context.push(FamilySubpage.inviteCaregiverPath),
        ),
        SizedBox(height: theme.spacing.spacingM),
        BebeButton(
          label: 'Revisar reglas familiares',
          variant: BebeButtonVariant.secondary,
          leading: const Icon(Icons.tune_rounded),
          onPressed: () => context.push(FamilySubpage.familyConfigurationPath),
        ),
      ],
    );
  }

  Future<void> _resend(FamilyMemberEntity member) async {
    setState(() => _busyMemberId = member.id);
    try {
      await widget.repository.resendInvitation(member.id);
      await _reload();
      if (mounted) _showMessage(context, 'Invitación reenviada por 7 días.');
    } on Object {
      if (mounted) _showMessage(context, 'No pudimos reenviar la invitación.');
    } finally {
      if (mounted) setState(() => _busyMemberId = null);
    }
  }

  Future<void> _cancel(FamilyMemberEntity member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Cancelar invitación?'),
        content: Text(
          '${member.name} ya no podrá usar este código para unirse al círculo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cancelar invitación'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busyMemberId = member.id);
    try {
      await widget.repository.cancelInvitation(member.id);
      await _reload();
      if (mounted) _showMessage(context, 'Invitación cancelada.');
    } on Object {
      if (mounted) _showMessage(context, 'No pudimos cancelar la invitación.');
    } finally {
      if (mounted) setState(() => _busyMemberId = null);
    }
  }

  Future<void> _reload() async {
    final family = await widget.getFamilyOverview();
    if (mounted) setState(() => _family = family);
  }
}

class _PendingInvitationCard extends StatelessWidget {
  const _PendingInvitationCard({
    required this.member,
    required this.isLoading,
    required this.onResend,
    required this.onCancel,
    required this.onCopy,
  });

  final FamilyMemberEntity member;
  final bool isLoading;
  final VoidCallback onResend;
  final VoidCallback onCancel;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) => _SurfaceCard(
    child: Padding(
      padding: EdgeInsets.all(context.theme.spacing.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.outgoing_mail),
              SizedBox(width: context.theme.spacing.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: context.theme.typography.styles.title.sm.semibold,
                    ),
                    Text(member.contact ?? member.role),
                  ],
                ),
              ),
              Chip(
                label: Text(member.invitationExpired ? 'Vencida' : 'Pendiente'),
              ),
            ],
          ),
          SizedBox(height: context.theme.spacing.spacingM),
          Text(
            'Código: ${member.invitationCode ?? 'No disponible'} · ${_invitationExpiryLabel(member)}',
            style: context.theme.typography.styles.body.sm.regular,
          ),
          SizedBox(height: context.theme.spacing.spacingM),
          Wrap(
            spacing: context.theme.spacing.spacingS,
            children: [
              TextButton.icon(
                onPressed: isLoading ? null : onCopy,
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copiar'),
              ),
              TextButton.icon(
                onPressed: isLoading ? null : onResend,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reenviar'),
              ),
              TextButton.icon(
                onPressed: isLoading ? null : onCancel,
                icon: const Icon(Icons.close_rounded),
                label: const Text('Cancelar'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.name,
    required this.role,
    required this.initials,
    required this.onPressed,
    this.accent = false,
  });

  final String name;
  final String role;
  final String initials;
  final VoidCallback onPressed;
  final bool accent;

  @override
  Widget build(BuildContext context) => _SurfaceCard(
    onPressed: onPressed,
    child: Padding(
      padding: EdgeInsets.all(context.theme.spacing.spacingL),
      child: Row(
        children: [
          _InitialAvatar(initials: initials, accent: accent, size: 52),
          SizedBox(width: context.theme.spacing.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: context.theme.typography.styles.title.sm.semibold
                      .copyWith(color: context.theme.colors.text.neutralTitle),
                ),
                SizedBox(height: context.theme.spacing.spacingXs),
                Text(
                  role,
                  style: context.theme.typography.styles.body.sm.regular
                      .copyWith(color: context.theme.colors.text.neutralBody),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    ),
  );
}

class _InviteCaregiverView extends StatefulWidget {
  const _InviteCaregiverView({
    required this.familyId,
    required this.babyId,
    required this.babyName,
    required this.onCompleted,
  });

  final String familyId;
  final String babyId;
  final String babyName;
  final VoidCallback onCompleted;

  @override
  State<_InviteCaregiverView> createState() => _InviteCaregiverViewState();
}

class _InviteCaregiverViewState extends State<_InviteCaregiverView> {
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FamilyFlowBloc, FamilyFlowState>(
      builder: (context, state) {
        if (state.submission == FamilyFlowSubmission.success) {
          return _InvitationSuccessView(
            babyName: widget.babyName,
            contact: _contactController.text.trim(),
            invitationCode: state.invitedMember?.invitationCode,
            onCompleted: widget.onCompleted,
          );
        }
        final theme = context.theme;
        final bloc = context.read<FamilyFlowBloc>();
        return _FlowPage(
          description:
              'Invita por correo o teléfono y decide exactamente qué podrá consultar.',
          children: [
            _BabyMiniHeader(babyName: widget.babyName),
            SizedBox(height: theme.spacing.spacingXl),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre (opcional)',
                prefixIcon: Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: theme.spacing.spacingL),
            TextField(
              controller: _contactController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Correo o teléfono',
                prefixIcon: const Icon(Icons.alternate_email_rounded),
                border: const OutlineInputBorder(),
                errorText: state.submission == FamilyFlowSubmission.invalid
                    ? 'Ingresa un correo o teléfono válido.'
                    : null,
              ),
              onChanged: (_) => bloc.add(const FamilyFlowInvitationReset()),
            ),
            SizedBox(height: theme.spacing.spacingXl),
            const BebeTitleSection(title: 'Relación'),
            SizedBox(height: theme.spacing.spacingL),
            Wrap(
              spacing: theme.spacing.spacingM,
              runSpacing: theme.spacing.spacingM,
              children: [
                for (final relationship in FamilyRelationship.values)
                  ChoiceChip(
                    label: Text(_relationshipLabel(relationship)),
                    selected: state.relationship == relationship,
                    onSelected: (_) =>
                        bloc.add(FamilyFlowRelationshipSelected(relationship)),
                  ),
              ],
            ),
            SizedBox(height: theme.spacing.spacingXl),
            BebeSettingsSection(
              title: 'Capacidades',
              description: 'Puedes modificar el acceso después.',
              children: [
                for (final capability in FamilyCapability.values)
                  BebeSettingsSwitchTile(
                    title: _capabilityTitle(capability),
                    description: _capabilityDescription(capability),
                    value: state.capabilityEnabled(capability),
                    onChanged: (value) => bloc.add(
                      FamilyFlowCapabilityChanged(capability, value),
                    ),
                  ),
              ],
            ),
            SizedBox(height: theme.spacing.spacingXl),
            BebeInfoBanner(
              title: 'Acceso bajo tu control',
              description:
                  'La relación es visual; las capacidades definen el acceso real.',
              icon: const Icon(Icons.info_outline_rounded),
              variant: BebeInfoBannerVariant.accent,
            ),
            SizedBox(height: theme.spacing.spacingXl),
            BebeButton(
              label: 'Enviar invitación',
              leading: const Icon(Icons.send_rounded),
              isLoading: state.submission == FamilyFlowSubmission.submitting,
              onPressed: state.submission == FamilyFlowSubmission.submitting
                  ? null
                  : () => bloc.add(
                      FamilyFlowInvitationSubmitted(
                        familyId: widget.familyId,
                        babyId: widget.babyId,
                        babyName: widget.babyName,
                        name: _nameController.text,
                        contact: _contactController.text,
                      ),
                    ),
            ),
            if (state.message != null) ...[
              SizedBox(height: theme.spacing.spacingM),
              BebeInfoBanner(
                title: 'No pudimos enviar la invitación',
                description: state.message!,
                icon: const Icon(Icons.error_outline_rounded),
                variant: BebeInfoBannerVariant.warning,
              ),
            ],
            SizedBox(height: theme.spacing.spacingM),
            BebeButton(
              label: 'Cómo funciona el enlace',
              variant: BebeButtonVariant.secondary,
              leading: const Icon(Icons.link_rounded),
              onPressed: () => _showMessage(
                context,
                'El código y el enlace seguro se generan al enviar la invitación.',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InvitationSuccessView extends StatelessWidget {
  const _InvitationSuccessView({
    required this.babyName,
    required this.contact,
    required this.invitationCode,
    required this.onCompleted,
  });

  final String babyName;
  final String contact;
  final String? invitationCode;
  final VoidCallback onCompleted;

  @override
  Widget build(BuildContext context) => _FlowPage(
    description: 'La invitación ya está en camino.',
    children: [
      SizedBox(height: context.theme.spacing.spacingXl),
      Icon(
        Icons.mark_email_read_rounded,
        size: 72,
        color: context.theme.colors.icons.brandDefault,
      ),
      SizedBox(height: context.theme.spacing.spacingXl),
      Text(
        '¡Invitación enviada!',
        textAlign: TextAlign.center,
        style: context.theme.typography.styles.title.lg.bold.copyWith(
          color: context.theme.colors.text.neutralTitle,
        ),
      ),
      SizedBox(height: context.theme.spacing.spacingS),
      Text(
        'Enviamos un acceso para $babyName a $contact. Podrás revocarlo en cualquier momento.',
        textAlign: TextAlign.center,
        style: context.theme.typography.styles.body.md.regular.copyWith(
          color: context.theme.colors.text.neutralBody,
        ),
      ),
      if (invitationCode != null) ...[
        SizedBox(height: context.theme.spacing.spacingXl),
        BebeInfoBanner(
          title: 'Código $invitationCode',
          description:
              'La persona invitada puede ingresarlo desde “Tengo una invitación”. Vence en 7 días.',
          icon: const Icon(Icons.vpn_key_outlined),
          variant: BebeInfoBannerVariant.accent,
        ),
        SizedBox(height: context.theme.spacing.spacingM),
        BebeButton(
          label: 'Copiar código y enlace',
          variant: BebeButtonVariant.secondary,
          leading: const Icon(Icons.copy_rounded),
          onPressed: () => _copyCodeInvitation(context, invitationCode!),
        ),
      ],
      SizedBox(height: context.theme.spacing.spacing3xl),
      BebeButton(label: 'Volver a Familia', onPressed: onCompleted),
    ],
  );
}

class _MemberDetailView extends StatelessWidget {
  const _MemberDetailView({
    required this.family,
    required this.memberId,
    required this.onRevoked,
  });

  final FamilyOverviewEntity family;
  final String memberId;
  final VoidCallback onRevoked;

  @override
  Widget build(BuildContext context) {
    final member = family.members.firstWhere(
      (item) => item.id == memberId,
      orElse: () => family.members.first,
    );
    final babyName = family.activeBaby.name;
    final theme = context.theme;
    return BlocBuilder<FamilyFlowBloc, FamilyFlowState>(
      builder: (context, state) {
        final bloc = context.read<FamilyFlowBloc>();
        return _FlowPage(
          description:
              'Revisa capacidades, restricciones y la actividad realizada para $babyName.',
          children: [
            _SurfaceCard(
              child: Padding(
                padding: EdgeInsets.all(theme.spacing.spacingXl),
                child: Row(
                  children: [
                    _InitialAvatar(initials: _initials(member.name), size: 72),
                    SizedBox(width: theme.spacing.spacingL),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: theme.typography.styles.title.md.semibold
                                .copyWith(
                                  color: theme.colors.text.neutralTitle,
                                ),
                          ),
                          SizedBox(height: theme.spacing.spacingS),
                          Chip(label: Text(member.role)),
                          Text(
                            'Miembro del círculo de $babyName',
                            style: theme.typography.styles.body.sm.regular
                                .copyWith(color: theme.colors.text.neutralBody),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: theme.spacing.spacingXl),
            BebeSettingsSection(
              title: 'Capacidades',
              children: [
                for (final capability in FamilyCapability.values)
                  BebeSettingsSwitchTile(
                    title: _capabilityTitle(capability),
                    value: state.capabilityEnabled(capability),
                    onChanged: member.role == 'Administrador/a'
                        ? null
                        : (value) => bloc.add(
                            FamilyFlowCapabilityChanged(capability, value),
                          ),
                  ),
              ],
            ),
            SizedBox(height: theme.spacing.spacingXl),
            BebeSettingsSection(
              title: 'Restricciones',
              children: const [
                BebeSettingsActionTile(
                  title: 'No puede gestionar miembros',
                  icon: Icon(Icons.block_rounded),
                ),
                BebeSettingsActionTile(
                  title: 'No puede eliminar información',
                  icon: Icon(Icons.delete_forever_outlined),
                ),
              ],
            ),
            SizedBox(height: theme.spacing.spacingXl),
            BebeSettingsSection(
              title: 'Actividad reciente',
              children: [
                const BebeSettingsActionTile(
                  title: 'Sin actividad registrada',
                  description: 'Las acciones de esta persona aparecerán aquí.',
                  icon: Icon(Icons.history_rounded),
                ),
              ],
            ),
            SizedBox(height: theme.spacing.spacingXl),
            BebeButton(
              label: 'Guardar cambios de acceso',
              leading: const Icon(Icons.admin_panel_settings_outlined),
              onPressed: () => _showMessage(context, 'Permisos actualizados.'),
            ),
            if (member.role != 'Administrador/a') ...[
              SizedBox(height: theme.spacing.spacingM),
              BebeButton(
                label: 'Revocar acceso',
                variant: BebeButtonVariant.destructive,
                leading: const Icon(Icons.person_remove_outlined),
                onPressed: () => _confirmRevoke(context, member.name, babyName),
              ),
            ],
            SizedBox(height: theme.spacing.spacingL),
            Text(
              'Los registros previos conservan su autoría.',
              textAlign: TextAlign.center,
              style: theme.typography.styles.body.sm.regular.copyWith(
                color: theme.colors.text.neutralBody,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmRevoke(
    BuildContext context,
    String name,
    String babyName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Revocar acceso?'),
        content: Text(
          '$name dejará de ver y registrar información de $babyName.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Revocar'),
          ),
        ],
      ),
    );
    if ((confirmed ?? false) && context.mounted) onRevoked();
  }
}

class _FamilyConfigurationView extends StatelessWidget {
  const _FamilyConfigurationView();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return BlocBuilder<FamilyFlowBloc, FamilyFlowState>(
      builder: (context, state) {
        final bloc = context.read<FamilyFlowBloc>();
        return _FlowPage(
          description:
              'Estas reglas se aplican al núcleo familiar y son independientes de tus preferencias personales.',
          children: [
            BebeSettingsSection(
              title: 'Acceso familiar',
              children: [
                BebeSettingsActionTile(
                  title: 'Miembros y permisos',
                  description: '3 cuidadores activos',
                  icon: const Icon(Icons.groups_2_outlined),
                  onPressed: () => context.push(FamilySubpage.careCirclePath),
                ),
                BebeSettingsActionTile(
                  title: 'Invitaciones pendientes',
                  description: '1 por revisar',
                  icon: const Icon(Icons.mark_email_unread_outlined),
                  onPressed: () =>
                      context.push(FamilySubpage.inviteCaregiverPath),
                ),
                BebeSettingsSwitchTile(
                  title: 'Aprobar nuevas invitaciones',
                  description: 'Un administrador confirma cada incorporación.',
                  value: state.requireInvitationApproval,
                  onChanged: (value) =>
                      bloc.add(FamilyFlowApprovalChanged(value)),
                ),
              ],
            ),
            SizedBox(height: theme.spacing.spacingXl),
            BebeSettingsSection(
              title: 'Privacidad compartida',
              children: [
                BebeSettingsSwitchTile(
                  title: 'Proteger detalles de salud',
                  description:
                      'Solo quienes tengan permiso de Salud verán información clínica.',
                  value: state.protectHealthDetails,
                  onChanged: (value) =>
                      bloc.add(FamilyFlowHealthPrivacyChanged(value)),
                ),
                BebeSettingsSwitchTile(
                  title: 'Resumen de actividad familiar',
                  description: 'Envía un resumen diario a administradores.',
                  value: state.familyDigest,
                  onChanged: (value) =>
                      bloc.add(FamilyFlowFamilyDigestChanged(value)),
                ),
              ],
            ),
            SizedBox(height: theme.spacing.spacingXl),
            BebeInfoBanner(
              title: 'Auditoría activa',
              description:
                  'Cada registro conserva quién lo creó y cuándo fue modificado.',
              icon: const Icon(Icons.fact_check_outlined),
              variant: BebeInfoBannerVariant.success,
            ),
            SizedBox(height: theme.spacing.spacingXl),
            BebeButton(
              label: 'Guardar configuración familiar',
              leading: const Icon(Icons.check_rounded),
              onPressed: () =>
                  _showMessage(context, 'Configuración familiar guardada.'),
            ),
          ],
        );
      },
    );
  }
}

class _BabyMiniHeader extends StatelessWidget {
  const _BabyMiniHeader({required this.babyName});

  final String babyName;

  @override
  Widget build(BuildContext context) => _SurfaceCard(
    child: Padding(
      padding: EdgeInsets.all(context.theme.spacing.spacingL),
      child: Row(
        children: [
          _InitialAvatar(initials: _initials(babyName), size: 52),
          SizedBox(width: context.theme.spacing.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  babyName,
                  style: context.theme.typography.styles.title.sm.semibold
                      .copyWith(color: context.theme.colors.text.neutralTitle),
                ),
                Text(
                  'Perfil activo',
                  style: context.theme.typography.styles.body.sm.regular
                      .copyWith(color: context.theme.colors.text.neutralBody),
                ),
              ],
            ),
          ),
          const Chip(label: Text('Bebé activo')),
        ],
      ),
    ),
  );
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child, this.onPressed});

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final content = onPressed == null
        ? child
        : InkWell(onTap: onPressed, child: child);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: theme.borderRadius.x3l,
        boxShadow: theme.elevation.low,
      ),
      child: Material(
        color: theme.colors.background.neutralsSurface,
        shape: RoundedRectangleBorder(
          borderRadius: theme.borderRadius.x3l,
          side: BorderSide(color: theme.colors.border.neutralDefault),
        ),
        clipBehavior: Clip.antiAlias,
        child: content,
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({
    required this.initials,
    required this.size,
    this.accent = false,
  });

  final String initials;
  final double size;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accent
              ? theme.colors.background.accentSurface
              : theme.colors.background.brandSurface,
          border: Border.all(
            color: accent
                ? theme.colors.border.accentAlternative
                : theme.colors.border.brandAlternative,
          ),
        ),
        child: Center(
          child: Text(
            initials,
            style: theme.typography.styles.title.md.bold.copyWith(
              color: accent
                  ? theme.colors.text.accentDefault
                  : theme.colors.text.brandDefault,
            ),
          ),
        ),
      ),
    );
  }
}

String _initials(String value) => value
    .trim()
    .split(RegExp(r'\s+'))
    .where((part) => part.isNotEmpty)
    .take(2)
    .map((part) => part[0].toUpperCase())
    .join();

String _familyBabyAge(DateTime birthDate) {
  final now = DateTime.now();
  final birth = birthDate.toLocal();
  var months = (now.year - birth.year) * 12 + now.month - birth.month;
  if (now.day < birth.day) months--;
  if (months <= 0) return 'Menos de un mes';
  return months == 1 ? '1 mes' : '$months meses';
}

String _familyBirthDate(DateTime value) {
  const months = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sept',
    'oct',
    'nov',
    'dic',
  ];
  final local = value.toLocal();
  return '${local.day} ${months[local.month - 1]} ${local.year}';
}

String _relationshipLabel(FamilyRelationship relationship) =>
    switch (relationship) {
      FamilyRelationship.mother => 'Mamá',
      FamilyRelationship.father => 'Papá',
      FamilyRelationship.grandparent => 'Abuela/o',
      FamilyRelationship.relative => 'Familiar',
      FamilyRelationship.caregiver => 'Cuidador/a',
    };

String _capabilityTitle(FamilyCapability capability) => switch (capability) {
  FamilyCapability.history => 'Ver historial',
  FamilyCapability.registerEvents => 'Registrar eventos',
  FamilyCapability.health => 'Ver salud',
  FamilyCapability.reminders => 'Recibir recordatorios',
};

String _capabilityDescription(FamilyCapability capability) =>
    switch (capability) {
      FamilyCapability.history => 'Consulta la rutina y registros previos.',
      FamilyCapability.registerEvents =>
        'Agrega alimentación, sueño y pañales.',
      FamilyCapability.health => 'Accede a vacunas, controles y crecimiento.',
      FamilyCapability.reminders => 'Recibe avisos compartidos del bebé.',
    };

Future<void> _copyMemberInvitation(
  BuildContext context,
  FamilyMemberEntity member,
) async {
  final code = member.invitationCode;
  if (code == null) {
    _showMessage(context, 'Esta invitación no tiene un código disponible.');
    return;
  }
  await _copyCodeInvitation(context, code);
}

Future<void> _copyCodeInvitation(BuildContext context, String code) async {
  await Clipboard.setData(
    ClipboardData(
      text: 'Código: $code\nhttps://bebe.app/invitation?code=$code',
    ),
  );
  if (context.mounted) _showMessage(context, 'Código y enlace copiados.');
}

String _invitationExpiryLabel(FamilyMemberEntity member) {
  final expiresAt = member.invitationExpiresAt?.toLocal();
  if (expiresAt == null) return 'sin fecha de vencimiento';
  if (member.invitationExpired) return 'venció el ${_shortDate(expiresAt)}';
  return 'vence el ${_shortDate(expiresAt)}';
}

String _shortDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/'
    '${value.month.toString().padLeft(2, '0')}/${value.year}';

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
