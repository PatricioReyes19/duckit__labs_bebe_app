import 'package:app_layout/src/bloc/app_layout_bloc.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppLayoutScrolling {
  static const double toggleThreshold = 180;
  static final Map<ScrollController, _ScrollState> _states = {};

  static void handleBottomBar(
    BuildContext context,
    ScrollController controller,
  ) {
    if (!controller.hasClients) return;
    final position = controller.position;
    if (position.maxScrollExtent <= 0 || position.outOfRange) return;

    final direction = position.userScrollDirection;
    if (direction == ScrollDirection.idle) return;

    final state = _states.putIfAbsent(controller, _ScrollState.new);
    final offset = position.pixels.clamp(0.0, position.maxScrollExtent);

    if (state.lastDirection != direction) {
      state
        ..lastDirection = direction
        ..lastTriggerOffset = offset;
      return;
    }

    if ((offset - state.lastTriggerOffset).abs() < toggleThreshold) return;

    final shouldShow = direction == ScrollDirection.forward;
    final bloc = context.read<AppLayoutBloc>();

    if (bloc.state.showBottomBar != shouldShow) {
      bloc.add(AppLayoutEvent.toggleBottomBar(show: shouldShow));
      state.lastTriggerOffset = offset;
    }
  }

  static void disposeFor(ScrollController controller) {
    _states.remove(controller);
  }
}

class _ScrollState {
  double lastTriggerOffset = 0;
  ScrollDirection? lastDirection;
}
