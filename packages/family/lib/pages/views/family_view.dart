import 'package:design_system/design_system.dart';
import 'package:family/family.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FamilyView extends StatelessWidget {
  const FamilyView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FamilyBloc, FamilyState>(
      builder: (context, state) {
        return switch (state) {
          FamilyInitial() ||
          FamilyLoading() => const _FamilyContent(loading: true),
          FamilyFailure(:final message) => Center(child: Text(message)),
          FamilyLoaded() => const _FamilyContent(),
        };
      },
    );
  }
}

class _FamilyContent extends StatelessWidget {
  const _FamilyContent({this.loading = false});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    return BebeFamilyOverviewTemplate(
      familyContext: const SizedBox.shrink(),
      familySummary: const SizedBox.shrink(),
      babiesSection: const SizedBox.shrink(),
      careCircleSection: const SizedBox.shrink(),
      familyActions: const SizedBox.shrink(),
    );
  }
}
