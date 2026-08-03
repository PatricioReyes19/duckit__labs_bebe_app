import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({
    required this.child,
    this.customBlocProviders = const <BlocProvider<dynamic>>[],
    this.repositoryProviders = const <RepositoryProvider<dynamic>>[],
    super.key,
  });

  final Widget child;
  final List<BlocProvider<dynamic>> customBlocProviders;
  final List<RepositoryProvider<dynamic>> repositoryProviders;

  @override
  Widget build(BuildContext context) {
    Widget current = child;

    if (customBlocProviders.isNotEmpty) {
      current = MultiBlocProvider(
        providers: customBlocProviders,
        child: current,
      );
    }

    if (repositoryProviders.isNotEmpty) {
      current = MultiRepositoryProvider(
        providers: repositoryProviders,
        child: current,
      );
    }

    return current;
  }
}
