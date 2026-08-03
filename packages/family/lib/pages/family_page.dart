import 'package:family/family.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FamilyPage extends StatelessWidget {
  const FamilyPage({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => FamilyBloc()..add(const FamilyStarted()),
    child: const FamilyView(),
  );
}
