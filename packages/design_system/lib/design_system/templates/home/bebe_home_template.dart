import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BebeHomeTemplate extends StatelessWidget {
  const BebeHomeTemplate({
    required this.title,
    required this.activeBabyHeader,
    required this.todaySummary,
    required this.quickActions,
    required this.upcomingHealth,
    required this.recentInformation,
    this.notificationIcon,
    this.onNotificationPressed,
    this.hasUnreadNotifications = false,
    this.isLoading = false,
    this.loadingState,
    this.errorMessage,
    this.errorState,
    this.onRetry,
    super.key,
  });

  final String title;

  /// El template recibe contenido visual, no Organisms concretos.
  final Widget activeBabyHeader;
  final Widget todaySummary;
  final Widget quickActions;
  final Widget upcomingHealth;
  final Widget recentInformation;

  final Widget? notificationIcon;
  final VoidCallback? onNotificationPressed;
  final bool hasUnreadNotifications;

  final bool isLoading;
  final Widget? loadingState;

  final String? errorMessage;
  final Widget? errorState;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingState ?? const _HomeLoadingState();
    }

    if (errorMessage != null) {
      return errorState ??
          _HomeErrorState(message: errorMessage!, onRetry: onRetry);
    }

    final theme = context.theme;
    final spacing = theme.spacing;
    final colors = theme.colors;
    final typography = theme.typography;

    return Scaffold(
      backgroundColor: colors.background.neutralsSurface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: colors.background.neutralsSurface,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: typography.styles.headline.md.bold.copyWith(
            color: colors.text.brandDefault,
          ),
        ),
        actions: [
          Semantics(
            button: true,
            enabled: onNotificationPressed != null,
            label: 'Notificaciones',
            child: IconButton(
              onPressed: onNotificationPressed,
              tooltip: 'Notificaciones',
              icon: Badge(
                isLabelVisible: hasUnreadNotifications,
                smallSize: 10,
                child:
                    notificationIcon ??
                    Icon(
                      Icons.notifications_none_rounded,
                      color: colors.icons.neutralDefault,
                    ),
              ),
            ),
          ),
          SizedBox(width: spacing.spacingM),
        ],
      ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                spacing.spacing3xl,
                spacing.spacingXl,
                spacing.spacing3xl,
                spacing.spacing5xl,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  SizedBox(width: double.infinity, child: activeBabyHeader),
                  SizedBox(height: spacing.spacing4xl),
                  SizedBox(width: double.infinity, child: todaySummary),
                  SizedBox(height: spacing.spacing4xl),
                  SizedBox(width: double.infinity, child: quickActions),
                  SizedBox(height: spacing.spacing4xl),
                  SizedBox(width: double.infinity, child: upcomingHealth),
                  SizedBox(height: spacing.spacing4xl),
                  SizedBox(width: double.infinity, child: recentInformation),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
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

    return Scaffold(
      backgroundColor: colors.background.neutralsSurface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(spacing.spacing3xl),
            child: SizedBox(
              width: double.infinity,
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
      ),
    );
  }
}

class _HomeLoadingState extends StatelessWidget {
  const _HomeLoadingState();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    return Scaffold(
      backgroundColor: colors.background.neutralsSurface,
      body: Center(
        child: CircularProgressIndicator(color: colors.icons.brandDefault),
      ),
    );
  }
}
