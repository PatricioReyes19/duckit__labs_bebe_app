import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeEventSection extends StatelessWidget {
  const BebeEventSection({
    required this.title,
    this.items = const [],
    this.state = BebeAgendaEventSectionState.empty,
    this.emptyState,
    this.loadingState,
    this.errorState,
    this.trailing,
    super.key,
  });

  final String title;
  final List<BebeAgendaEventSectionItem> items;
  final BebeAgendaEventSectionState state;
  final Widget? emptyState;
  final Widget? loadingState;
  final Widget? errorState;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return Semantics(
      container: true,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BebeTitleSection(title: title.trim(), trailing: trailing),
            SizedBox(height: spacing.spacingL),
            switch (state) {
              BebeAgendaEventSectionState.content => _EventSectionList(
                items: items,
              ),
              BebeAgendaEventSectionState.empty => emptyState!,
              BebeAgendaEventSectionState.loading =>
                loadingState ?? const _DefaultEventSectionLoading(),
              BebeAgendaEventSectionState.error => errorState!,
            },
          ],
        ),
      ),
    );
  }
}

class _DefaultEventSectionLoading extends StatelessWidget {
  const _DefaultEventSectionLoading();

  static const int _placeholderCount = 3;
  static const double _placeholderHeight = 80;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final radius = theme.borderRadius;

    return Column(
      children: [
        for (var index = 0; index < _placeholderCount; index++) ...[
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: _placeholderHeight),
            decoration: BoxDecoration(
              color: colors.background.neutralsActive,
              borderRadius: BorderRadius.circular(radius.radius3xl),
              border: Border.all(color: colors.border.neutralDefault),
            ),
          ),
          if (index < _placeholderCount - 1) SizedBox(height: spacing.spacingM),
        ],
      ],
    );
  }
}

class _EventSectionList extends StatelessWidget {
  const _EventSectionList({required this.items});

  final List<BebeAgendaEventSectionItem> items;

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < items.length; index++) ...[
          KeyedSubtree(
            key: ValueKey<String>(items[index].id),
            child: items[index].child,
          ),
          if (index < items.length - 1) SizedBox(height: spacing.spacingM),
        ],
      ],
    );
  }
}
