part of 'app_layout_bloc.dart';

@freezed
abstract class AppLayoutState with _$AppLayoutState {
  const factory AppLayoutState({
    @Default(true) bool showHeader,
    @Default(true) bool showBottomBar,
    @Default(true) bool showPrimaryAction,
    @Default(false) bool primaryActionExpanded,
    @Default(0) int activeDisplayIndex,
    @Default(0) int activeBranchIndex,
    @Default('home') String activeTabId,
    @Default(<AppLayoutTabConfig>[]) List<AppLayoutTabConfig> tabs,
    @Default(<String, bool>{}) Map<String, bool> scrollToTopFlagsById,
    String? currentRoute,
    String? previousRoute,
  }) = _AppLayoutState;

  factory AppLayoutState.initial() => const AppLayoutState();
}
