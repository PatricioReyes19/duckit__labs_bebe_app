import 'package:family/family.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FamilyFlowBloc', () {
    test('selects a baby and updates an individual capability', () async {
      final bloc = FamilyFlowBloc();
      addTearDown(bloc.close);

      bloc
        ..add(const FamilyFlowBabySelected('sofia'))
        ..add(
          const FamilyFlowCapabilityChanged(FamilyCapability.health, false),
        );

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<FamilyFlowState>()
              .having((state) => state.selectedBabyId, 'baby', 'sofia')
              .having(
                (state) => state.capabilityEnabled(FamilyCapability.health),
                'health capability',
                false,
              ),
        ),
      );
    });

    test('validates invitation contact before completing the flow', () async {
      final bloc = FamilyFlowBloc();
      addTearDown(bloc.close);

      bloc.add(const FamilyFlowInvitationSubmitted(contact: 'not-valid'));
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<FamilyFlowState>().having(
            (state) => state.submission,
            'submission',
            FamilyFlowSubmission.invalid,
          ),
        ),
      );

      bloc.add(const FamilyFlowInvitationSubmitted(contact: '+56912345678'));
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<FamilyFlowState>().having(
            (state) => state.submission,
            'phone invitation without phone authentication',
            FamilyFlowSubmission.invalid,
          ),
        ),
      );

      bloc.add(
        const FamilyFlowInvitationSubmitted(contact: 'abuela@example.com'),
      );
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<FamilyFlowState>().having(
            (state) => state.submission,
            'submission',
            FamilyFlowSubmission.success,
          ),
        ),
      );
    });

    test('keeps family-level preferences independent', () async {
      final bloc = FamilyFlowBloc();
      addTearDown(bloc.close);

      bloc
        ..add(const FamilyFlowApprovalChanged(false))
        ..add(const FamilyFlowFamilyDigestChanged(false));

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<FamilyFlowState>()
              .having(
                (state) => state.requireInvitationApproval,
                'approval',
                false,
              )
              .having((state) => state.familyDigest, 'digest', false)
              .having(
                (state) => state.protectHealthDetails,
                'health privacy',
                true,
              ),
        ),
      );
    });
  });
}
