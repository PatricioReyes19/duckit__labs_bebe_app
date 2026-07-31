import 'package:flutter/material.dart';

class UseCaseFrame extends StatelessWidget {
  const UseCaseFrame({
    required this.child,
    this.width,
    this.padding = const EdgeInsets.all(24),
    this.scrollable = false,
    super.key,
  });

  final Widget child;
  final double? width;
  final EdgeInsets padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    Widget content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: width ?? 560,
        ),
        child: child,
      ),
    );

    if (scrollable) {
      content = SingleChildScrollView(child: content);
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: padding,
          child: content,
        ),
      ),
    );
  }
}
