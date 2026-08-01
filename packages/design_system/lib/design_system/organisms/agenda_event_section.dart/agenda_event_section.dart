import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeAgendaEventSection extends StatelessWidget {
  const BebeAgendaEventSection({
    required this.title,
    this.items = const [],
    this.state = BebeAgendaEventSectionState.content,
    this.emptyState,
    this.loadingState,
    this.errorState,
    this.trailing,
    this.semanticLabel,
    super.key,
  });

  final String title;
  final List<BebeAgendaEventSectionItem> items;
  final BebeAgendaEventSectionState state;

  final Widget? emptyState;
  final Widget? loadingState;
  final Widget? errorState;
  final Widget? trailing;

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    assert(
      state != BebeAgendaEventSectionState.content || items.isNotEmpty,
      'Content state requires at least one item.',
    );

    final spacing = context.theme.spacing;

    return Semantics(
      container: true,
      label: semanticLabel ?? title,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BebeTitleSection(title: title, trailing: trailing),
            SizedBox(height: spacing.spacingL),
            _AgendaEventSectionBody(
              state: state,
              items: items,
              emptyState: emptyState,
              loadingState: loadingState,
              errorState: errorState,
            ),
          ],
        ),
      ),
    );
  }
}

class _AgendaEventSectionBody extends StatelessWidget {
  const _AgendaEventSectionBody({
    required this.state,
    required this.items,
    required this.emptyState,
    required this.loadingState,
    required this.errorState,
  });

  final BebeAgendaEventSectionState state;
  final List<BebeAgendaEventSectionItem> items;
  final Widget? emptyState;
  final Widget? loadingState;
  final Widget? errorState;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      BebeAgendaEventSectionState.content => _AgendaEventList(items: items),

      BebeAgendaEventSectionState.empty =>
        emptyState ??
            const _DefaultAgendaSectionMessage(
              message: 'No hay eventos para mostrar.',
            ),

      BebeAgendaEventSectionState.loading =>
        loadingState ?? const _DefaultAgendaSectionLoading(),

      BebeAgendaEventSectionState.error =>
        errorState ??
            const _DefaultAgendaSectionMessage(
              message: 'No pudimos cargar los eventos.',
            ),
    };
  }
}

class _DefaultAgendaSectionMessage extends StatelessWidget {
  const _DefaultAgendaSectionMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final typography = theme.typography;
    final radius = theme.borderRadius;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background.neutralsSurface,
        borderRadius: BorderRadius.circular(radius.radius3xl),
        border: Border.all(color: colors.border.accentAlternative),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.spacingXl),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: typography.styles.body.sm.regular.copyWith(
            color: colors.text.neutralBody,
          ),
        ),
      ),
    );
  }
}

class _DefaultAgendaSectionLoading extends StatelessWidget {
  const _DefaultAgendaSectionLoading();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final radius = theme.borderRadius;

    return Column(
      children: [
        for (var index = 0; index < 3; index++) ...[
          Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 6 * 2),
            decoration: BoxDecoration(
              color: colors.background.neutralsActive,
              borderRadius: BorderRadius.circular(radius.radius3xl),
            ),
          ),
          if (index != 2) SizedBox(height: spacing.spacingM),
        ],
      ],
    );
  }
}

class _AgendaEventList extends StatelessWidget {
  const _AgendaEventList({required this.items});

  final List<BebeAgendaEventSectionItem> items;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < items.length; index++) ...[
          KeyedSubtree(
            key: ValueKey(items[index].id),
            child: items[index].child,
          ),
          if (index != items.length - 1) SizedBox(height: spacing.spacingM),
        ],
      ],
    );
  }
}
