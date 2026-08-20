import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health/bloc/health_flow_bloc.dart';
import 'package:health/models/health_flow_controller.dart';

class HealthFlowBody extends StatefulWidget {
  const HealthFlowBody({
    required this.controller,
    required this.builder,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 28),
    super.key,
  });

  final HealthFlowController controller;
  final EdgeInsets padding;
  final List<Widget> Function(BuildContext context) builder;

  @override
  State<HealthFlowBody> createState() => _HealthFlowBodyState();
}

class _HealthFlowBodyState extends State<HealthFlowBody> {
  late HealthFlowBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = HealthFlowBloc(widget.controller)..load();
  }

  @override
  void didUpdateWidget(covariant HealthFlowBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      unawaited(_bloc.close());
      _bloc = HealthFlowBloc(widget.controller)..load();
    }
  }

  @override
  void dispose() {
    unawaited(_bloc.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HealthFlowBloc, HealthFlowState>(
      bloc: _bloc,
      builder: (context, state) {
        if (state.isLoading) {
          return HealthFlowSkeleton(padding: widget.padding);
        }
        if (state.error != null && widget.controller.activeBaby == null) {
          return HealthFlowError(
            message: 'No pudimos cargar la información de salud.',
            onRetry: () => _bloc.load(force: true),
          );
        }
        return RefreshIndicator(
          onRefresh: () => _bloc.load(force: true),
          child: ListView(
            padding: widget.padding,
            children: widget.builder(context),
          ),
        );
      },
    );
  }
}

class HealthFlowSkeleton extends StatelessWidget {
  const HealthFlowSkeleton({
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 28),
    super.key,
  });

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Cargando información de salud',
      child: ExcludeSemantics(
        child: ListView(
          key: const ValueKey('health-flow-skeleton'),
          padding: padding,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            BebeSkeleton.line(width: 210, height: 22),
            SizedBox(height: 10),
            BebeSkeleton.line(width: 280, height: 12),
            SizedBox(height: 22),
            BebeSkeleton(height: 148),
            SizedBox(height: 16),
            BebeSkeleton(height: 96),
            SizedBox(height: 16),
            BebeSkeleton(height: 180),
          ],
        ),
      ),
    );
  }
}

class HealthFlowError extends StatelessWidget {
  const HealthFlowError({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}

class HealthEmptyState extends StatelessWidget {
  const HealthEmptyState({
    required this.title,
    required this.description,
    required this.icon,
    this.actionLabel,
    this.onActionPressed,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return HealthSurface(
      child: BebeStatePanel(
        title: title,
        description: description,
        variant: BebeStatePanelVariant.empty,
        illustration: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 34, color: colors.primary),
        ),
        primaryActionLabel: actionLabel,
        onPrimaryActionPressed: onActionPressed,
      ),
    );
  }
}

class HealthSurface extends StatelessWidget {
  const HealthSurface({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
    this.borderColor,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor ?? colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return content;
    return Semantics(
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class HealthSectionHeading extends StatelessWidget {
  const HealthSectionHeading({
    required this.title,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class HealthActionRow extends StatelessWidget {
  const HealthActionRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.tint,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? tint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final effectiveTint = tint ?? colors.primary;
    return HealthSurface(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: effectiveTint.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: effectiveTint),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing ?? Icon(Icons.chevron_right_rounded, color: effectiveTint),
        ],
      ),
    );
  }
}

class HealthSyncBadge extends StatelessWidget {
  const HealthSyncBadge({
    required this.status,
    this.compact = false,
    super.key,
  });

  final RegisterSyncStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (label, icon, color) = switch (status) {
      RegisterSyncStatus.synced => (
        'Sincronizado',
        Icons.cloud_done_outlined,
        colors.tertiary,
      ),
      RegisterSyncStatus.syncing => (
        'Sincronizando',
        Icons.sync_rounded,
        colors.primary,
      ),
      RegisterSyncStatus.failed => (
        'Error de sync',
        Icons.cloud_off_outlined,
        colors.error,
      ),
      RegisterSyncStatus.pending => (
        'Guardado local',
        Icons.cloud_queue_outlined,
        colors.secondary,
      ),
    };
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 12,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 16 : 18, color: color),
          if (!compact) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class HealthPrimaryButton extends StatelessWidget {
  const HealthPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.outlined = false,
    this.busy = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final child = busy
        ? const SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 2,
            children: [
              if (icon != null) Icon(icon, size: 20),
              Text(label, textAlign: TextAlign.center, maxLines: 2),
            ],
          );
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(54)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      textStyle: WidgetStatePropertyAll(
        Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
    if (outlined) {
      return OutlinedButton(
        onPressed: busy ? null : onPressed,
        style: style,
        child: child,
      );
    }
    return FilledButton(
      onPressed: busy ? null : onPressed,
      style: style,
      child: child,
    );
  }
}

class HealthMetricTile extends StatelessWidget {
  const HealthMetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.caption,
    super.key,
  });

  final String label;
  final String value;
  final String? caption;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (caption != null) ...[
            const SizedBox(height: 4),
            Text(
              caption!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

RegisterSyncStatus registerStatusFor(RegisteredEvent event) => event.syncStatus;

String healthDateLabel(DateTime value) {
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

String healthTimeLabel(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
