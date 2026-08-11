import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Estructura visual de Home.
///
/// La shell y el fondo global pertenecen a `app_layout`. Este template solo
/// administra el contenido vertical de Home y su desplazamiento.
class BebeHomeTemplate extends StatelessWidget {
  const BebeHomeTemplate({
    required this.activeBabyHeader,
    required this.todaySummary,
    required this.quickActions,
    required this.upcomingHealth,
    required this.recentInformation,
    this.visualReminder,
    this.isEmpty = false,
    this.emptyState,
    this.isLoading = false,
    this.loadingState,
    this.errorMessage,
    this.errorState,
    this.onRetry,
    this.onRefresh,
    this.maximumContentWidth = BebeLayout.pageContentMaxWidth,
    super.key,
  });

  final Widget activeBabyHeader;
  final Widget todaySummary;
  final Widget quickActions;
  final Widget upcomingHealth;
  final Widget recentInformation;
  final Widget? visualReminder;
  final bool isEmpty;
  final Widget? emptyState;

  final bool isLoading;
  final Widget? loadingState;

  final String? errorMessage;
  final Widget? errorState;
  final VoidCallback? onRetry;
  final Future<void> Function()? onRefresh;

  final double maximumContentWidth;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingState ?? const _HomeLoadingState();
    }

    final message = errorMessage;
    if (message != null) {
      return errorState ?? _HomeErrorState(message: message, onRetry: onRetry);
    }

    final spacing = context.theme.spacing;
    final horizontalPadding = spacing.spacing2xl;

    Widget padded(Widget child) => Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: child,
    );

    return SafeArea(
      top: false,
      child: ColoredBox(
        color: context.theme.colors.background.neutralsSurface,
        child: _HomeRefreshableScroll(
          onRefresh: onRefresh,
          child: SingleChildScrollView(
            primary: true,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.symmetric(vertical: spacing.spacingXl),
            child: BebeResponsiveContent(
              maxWidth: maximumContentWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  padded(activeBabyHeader),
                  if (visualReminder != null) ...[
                    SizedBox(height: spacing.spacingL),
                    padded(visualReminder!),
                  ],
                  if (isEmpty) ...[
                    SizedBox(height: spacing.spacing4xl),
                    padded(emptyState ?? const SizedBox.shrink()),
                  ] else ...[
                    SizedBox(height: spacing.spacing4xl),
                    todaySummary,
                    SizedBox(height: spacing.spacing4xl),
                    quickActions,
                    SizedBox(height: spacing.spacing4xl),
                    padded(upcomingHealth),
                    SizedBox(height: spacing.spacing4xl),
                    padded(recentInformation),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeRefreshableScroll extends StatelessWidget {
  const _HomeRefreshableScroll({required this.child, this.onRefresh});

  final Widget child;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) => onRefresh == null
      ? child
      : RefreshIndicator(onRefresh: onRefresh!, child: child);
}

class _HomeErrorState extends StatelessWidget {
  const _HomeErrorState({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final typography = theme.typography;

    return SafeArea(
      top: false,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(spacing.spacing3xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: spacing.spacing6xl,
                  color: colors.icons.errorDefault,
                ),
                SizedBox(height: spacing.spacingXl),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: typography.styles.body.lg.regular.copyWith(
                    color: colors.text.neutralBody,
                  ),
                ),
                if (onRetry != null) ...[
                  SizedBox(height: spacing.spacing2xl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onRetry,
                      child: const Text('Reintentar'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeLoadingState extends StatelessWidget {
  const _HomeLoadingState();

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return SafeArea(
      top: false,
      child: Center(
        child: CircularProgressIndicator(color: colors.icons.brandDefault),
      ),
    );
  }
}
