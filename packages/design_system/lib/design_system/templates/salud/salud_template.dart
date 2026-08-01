import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeConsultationDetailTemplate extends StatelessWidget {
  const BebeConsultationDetailTemplate({
    required this.header,
    required this.summary,
    required this.evaluation,
    required this.treatment,
    required this.followUp,
    required this.monitoring,
    required this.attachments,
    this.sectionTitle = 'Resultado de la consulta',
    this.additionalSections = const [],
    this.contentPadding,
    this.bottomSpacing,
    this.useSafeArea = true,
    this.semanticLabel = 'Detalle de consulta pediátrica',
    super.key,
  });

  final Widget header;
  final Widget summary;

  final Widget evaluation;
  final Widget treatment;
  final Widget followUp;
  final Widget monitoring;
  final Widget attachments;

  final String sectionTitle;

  final List<Widget> additionalSections;

  final EdgeInsetsGeometry? contentPadding;
  final double? bottomSpacing;

  final bool useSafeArea;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;

    final effectivePadding =
        contentPadding ??
        EdgeInsets.only(
          left: spacing.spacingXl,
          top: spacing.spacingL,
          right: spacing.spacingXl,
        );

    final effectiveBottomSpacing = bottomSpacing ?? spacing.spacing4xl;

    final body = SingleChildScrollView(
      padding: effectivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          SizedBox(height: spacing.spacing2xl),
          summary,
          SizedBox(height: spacing.spacing2xl),
          BebeTitleSection(title: sectionTitle),
          SizedBox(height: spacing.spacingL),
          evaluation,
          SizedBox(height: spacing.spacingM),
          treatment,
          SizedBox(height: spacing.spacingM),
          followUp,
          SizedBox(height: spacing.spacingM),
          monitoring,
          SizedBox(height: spacing.spacing2xl),
          attachments,
          for (final section in additionalSections) ...[
            SizedBox(height: spacing.spacingM),
            section,
          ],
          SizedBox(height: effectiveBottomSpacing),
        ],
      ),
    );

    return Semantics(
      container: true,
      label: semanticLabel,
      child: useSafeArea ? SafeArea(bottom: false, child: body) : body,
    );
  }
}
