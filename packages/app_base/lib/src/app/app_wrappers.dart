import 'package:flutter/widgets.dart';

class AppWrappers extends StatelessWidget {
  const AppWrappers({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
