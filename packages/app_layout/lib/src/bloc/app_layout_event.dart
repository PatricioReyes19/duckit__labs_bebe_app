part of 'app_layout_bloc.dart';

@freezed
sealed class AppLayoutEvent with _$AppLayoutEvent {
  const factory AppLayoutEvent.started({
    required List<AppLayoutTabConfig> tabs,
  }) = _Started;

  const factory AppLayoutEvent.routeChanged({
    required String location,
    required AppLayoutChromeConfig chrome,
  }) = _RouteChanged;

  const factory AppLayoutEvent.tabChanged({
    required int displayIndex,
    required int branchIndex,
    required String tabId,
  }) = _TabChanged;

  const factory AppLayoutEvent.toggleBottomBar({required bool show}) =
      _ToggleBottomBar;

  const factory AppLayoutEvent.toggleHeader({required bool show}) =
      _ToggleHeader;

  const factory AppLayoutEvent.togglePrimaryAction({required bool show}) =
      _TogglePrimaryAction;

  const factory AppLayoutEvent.togglePrimaryActionExpanded({
    required bool expanded,
  }) = _TogglePrimaryActionExpanded;

  const factory AppLayoutEvent.scrollToTop({required String tabId}) =
      _ScrollToTop;
}
