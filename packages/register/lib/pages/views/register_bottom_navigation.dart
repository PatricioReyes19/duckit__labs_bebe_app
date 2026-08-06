import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Bottom navigation shown while the full-screen register flow is open.
///
/// The register route lives above the main navigation shell, so this component
/// preserves the same five-destination mental model without coupling the
/// feature package to GoRouter or AppLayout.
class RegisterBottomNavigation extends StatelessWidget {
  const RegisterBottomNavigation({
    this.onHomePressed,
    this.onAgendaPressed,
    this.onHealthPressed,
    this.onFamilyPressed,
    super.key,
  });

  final VoidCallback? onHomePressed;
  final VoidCallback? onAgendaPressed;
  final VoidCallback? onHealthPressed;
  final VoidCallback? onFamilyPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background.neutralsSurface,
        border: Border(top: BorderSide(color: colors.border.neutralDefault)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: theme.elevation.low,
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 2),
        child: SizedBox(
          height: 82,
          child: Row(
            children: [
              Expanded(
                child: _Destination(
                  label: 'Inicio',
                  icon: Icons.home_outlined,
                  onPressed: onHomePressed,
                ),
              ),
              Expanded(
                child: _Destination(
                  label: 'Agenda',
                  icon: Icons.calendar_today_outlined,
                  onPressed: onAgendaPressed,
                ),
              ),
              const Expanded(child: _RegisterDestination()),
              Expanded(
                child: _Destination(
                  label: 'Salud',
                  icon: Icons.health_and_safety_outlined,
                  onPressed: onHealthPressed,
                ),
              ),
              Expanded(
                child: _Destination(
                  label: 'Familia',
                  icon: Icons.groups_outlined,
                  onPressed: onFamilyPressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Destination extends StatelessWidget {
  const _Destination({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final foreground = theme.colors.icons.neutralAlternative;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 25, color: foreground),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.styles.label.sm.regular.copyWith(
                  color: theme.colors.text.neutralLabel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisterDestination extends StatelessWidget {
  const _RegisterDestination();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Semantics(
      selected: true,
      label: 'Registrar',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(
            offset: const Offset(0, -15),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.background.brandDefault,
                shape: BoxShape.circle,
                boxShadow: theme.elevation.medium,
              ),
              child: SizedBox.square(
                dimension: 58,
                child: Icon(
                  Icons.add_rounded,
                  size: 34,
                  color: theme.colors.onPrimary.neutralDefault,
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -10),
            child: Text(
              'Registrar',
              maxLines: 1,
              style: theme.typography.styles.label.sm.semibold.copyWith(
                color: theme.colors.text.brandDefault,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
