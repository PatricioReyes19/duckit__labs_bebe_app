import 'package:flutter/widgets.dart';

class AppBuilder extends StatelessWidget {
  const AppBuilder({
    required this.app,
    this.preconditionView,
    super.key,
  });

  final Widget app;
  final Widget? preconditionView;

  @override
  Widget build(BuildContext context) => preconditionView ?? app;
}
