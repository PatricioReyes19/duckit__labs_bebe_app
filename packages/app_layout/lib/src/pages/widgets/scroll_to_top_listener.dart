import 'package:app_layout/src/bloc/app_layout_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScrollToTopListener extends StatelessWidget {
  const ScrollToTopListener({
    required this.scrollController,
    required this.tabId,
    required this.child,
    super.key,
  });

  final ScrollController scrollController;
  final String tabId;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppLayoutBloc, AppLayoutState>(
      listenWhen: (previous, current) =>
          previous.scrollToTopFlagsById[tabId] !=
          current.scrollToTopFlagsById[tabId],
      listener: (context, state) {
        final shouldScroll = state.scrollToTopFlagsById[tabId] ?? false;
        if (!shouldScroll || !scrollController.hasClients) return;
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      },
      child: child,
    );
  }
}
