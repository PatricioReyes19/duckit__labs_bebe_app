import 'dart:async';

import 'package:app_layout/src/config/app_layout_chrome_config.dart';
import 'package:app_layout/src/config/app_layout_tab_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_layout_bloc.freezed.dart';
part 'app_layout_event.dart';
part 'app_layout_state.dart';

class AppLayoutBloc extends Bloc<AppLayoutEvent, AppLayoutState> {
  AppLayoutBloc() : super(AppLayoutState.initial()) {
    on<_Started>(_onStarted);
    on<_RouteChanged>(_onRouteChanged);
    on<_TabChanged>(_onTabChanged);
    on<_ToggleBottomBar>((event, emit) {
      emit(state.copyWith(showBottomBar: event.show));
    });
    on<_ToggleHeader>((event, emit) {
      emit(state.copyWith(showHeader: event.show));
    });
    on<_TogglePrimaryAction>((event, emit) {
      emit(state.copyWith(showPrimaryAction: event.show));
    });
    on<_TogglePrimaryActionExpanded>((event, emit) {
      emit(state.copyWith(primaryActionExpanded: event.expanded));
    });
    on<_ScrollToTop>(_onScrollToTop);
  }

  void _onStarted(_Started event, Emitter<AppLayoutState> emit) {
    final tabs = event.tabs.where((tab) => tab.enabled).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    final initial = tabs.isEmpty ? null : tabs.first;
    emit(
      state.copyWith(
        tabs: tabs,
        activeDisplayIndex: 0,
        activeBranchIndex: initial?.branchIndex ?? 0,
        activeTabId: initial?.id ?? 'home',
      ),
    );
  }

  void _onRouteChanged(_RouteChanged event, Emitter<AppLayoutState> emit) {
    final index = _findDisplayIndex(event.location, state.tabs);
    final tab = index == null ? null : state.tabs[index];
    emit(
      state.copyWith(
        previousRoute: state.currentRoute,
        currentRoute: event.location,
        showHeader: event.chrome.showHeader,
        showBottomBar: event.chrome.showBottomBar,
        showPrimaryAction: event.chrome.showPrimaryAction,
        activeDisplayIndex: index ?? state.activeDisplayIndex,
        activeBranchIndex: tab?.branchIndex ?? state.activeBranchIndex,
        activeTabId: tab?.id ?? state.activeTabId,
      ),
    );
  }

  void _onTabChanged(_TabChanged event, Emitter<AppLayoutState> emit) {
    emit(
      state.copyWith(
        activeDisplayIndex: event.displayIndex,
        activeBranchIndex: event.branchIndex,
        activeTabId: event.tabId,
      ),
    );
  }

  Future<void> _onScrollToTop(
    _ScrollToTop event,
    Emitter<AppLayoutState> emit,
  ) async {
    emit(
      state.copyWith(
        scrollToTopFlagsById: {
          ...state.scrollToTopFlagsById,
          event.tabId: true,
        },
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (isClosed) return;
    emit(
      state.copyWith(
        scrollToTopFlagsById: {
          ...state.scrollToTopFlagsById,
          event.tabId: false,
        },
      ),
    );
  }

  int? _findDisplayIndex(String location, List<AppLayoutTabConfig> tabs) {
    final current = _normalize(location);
    for (var index = 0; index < tabs.length; index++) {
      final root = _normalize(tabs[index].route);
      if (current == root || current.startsWith('$root/')) return index;
    }
    return null;
  }

  String _normalize(String value) {
    var path = Uri.tryParse(value)?.path ?? value;
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    return path;
  }
}
