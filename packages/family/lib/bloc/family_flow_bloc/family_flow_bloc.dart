import 'package:flutter_bloc/flutter_bloc.dart';

enum FamilyRelationship { mother, father, grandparent, relative, caregiver }

enum FamilyCapability { history, registerEvents, health, reminders }

enum FamilyFlowSubmission { idle, invalid, success }

sealed class FamilyFlowEvent {
  const FamilyFlowEvent();
}

final class FamilyFlowBabySelected extends FamilyFlowEvent {
  const FamilyFlowBabySelected(this.babyId);

  final String babyId;
}

final class FamilyFlowRelationshipSelected extends FamilyFlowEvent {
  const FamilyFlowRelationshipSelected(this.relationship);

  final FamilyRelationship relationship;
}

final class FamilyFlowCapabilityChanged extends FamilyFlowEvent {
  const FamilyFlowCapabilityChanged(this.capability, this.value);

  final FamilyCapability capability;
  final bool value;
}

final class FamilyFlowInvitationSubmitted extends FamilyFlowEvent {
  const FamilyFlowInvitationSubmitted({required this.contact});

  final String contact;
}

final class FamilyFlowInvitationReset extends FamilyFlowEvent {
  const FamilyFlowInvitationReset();
}

final class FamilyFlowFamilyDigestChanged extends FamilyFlowEvent {
  const FamilyFlowFamilyDigestChanged(this.value);

  final bool value;
}

final class FamilyFlowApprovalChanged extends FamilyFlowEvent {
  const FamilyFlowApprovalChanged(this.value);

  final bool value;
}

final class FamilyFlowHealthPrivacyChanged extends FamilyFlowEvent {
  const FamilyFlowHealthPrivacyChanged(this.value);

  final bool value;
}

class FamilyFlowState {
  const FamilyFlowState({
    required this.selectedBabyId,
    this.relationship = FamilyRelationship.mother,
    this.capabilities = const {
      FamilyCapability.history: true,
      FamilyCapability.registerEvents: true,
      FamilyCapability.health: true,
      FamilyCapability.reminders: true,
    },
    this.submission = FamilyFlowSubmission.idle,
    this.familyDigest = true,
    this.requireInvitationApproval = true,
    this.protectHealthDetails = true,
  });

  final String selectedBabyId;
  final FamilyRelationship relationship;
  final Map<FamilyCapability, bool> capabilities;
  final FamilyFlowSubmission submission;
  final bool familyDigest;
  final bool requireInvitationApproval;
  final bool protectHealthDetails;

  bool capabilityEnabled(FamilyCapability capability) =>
      capabilities[capability] ?? false;

  FamilyFlowState copyWith({
    String? selectedBabyId,
    FamilyRelationship? relationship,
    Map<FamilyCapability, bool>? capabilities,
    FamilyFlowSubmission? submission,
    bool? familyDigest,
    bool? requireInvitationApproval,
    bool? protectHealthDetails,
  }) => FamilyFlowState(
    selectedBabyId: selectedBabyId ?? this.selectedBabyId,
    relationship: relationship ?? this.relationship,
    capabilities: capabilities ?? this.capabilities,
    submission: submission ?? this.submission,
    familyDigest: familyDigest ?? this.familyDigest,
    requireInvitationApproval:
        requireInvitationApproval ?? this.requireInvitationApproval,
    protectHealthDetails: protectHealthDetails ?? this.protectHealthDetails,
  );
}

class FamilyFlowBloc extends Bloc<FamilyFlowEvent, FamilyFlowState> {
  FamilyFlowBloc({String initialBabyId = 'local-active-baby'})
    : super(FamilyFlowState(selectedBabyId: initialBabyId)) {
    on<FamilyFlowBabySelected>(
      (event, emit) => emit(
        state.copyWith(
          selectedBabyId: event.babyId,
          submission: FamilyFlowSubmission.idle,
        ),
      ),
    );
    on<FamilyFlowRelationshipSelected>(
      (event, emit) => emit(
        state.copyWith(
          relationship: event.relationship,
          submission: FamilyFlowSubmission.idle,
        ),
      ),
    );
    on<FamilyFlowCapabilityChanged>((event, emit) {
      emit(
        state.copyWith(
          capabilities: {...state.capabilities, event.capability: event.value},
          submission: FamilyFlowSubmission.idle,
        ),
      );
    });
    on<FamilyFlowInvitationSubmitted>((event, emit) {
      final contact = event.contact.trim();
      final isValid =
          contact.contains('@') ||
          RegExp(r'^\+?[0-9][0-9\s-]{7,}$').hasMatch(contact);
      emit(
        state.copyWith(
          submission: isValid
              ? FamilyFlowSubmission.success
              : FamilyFlowSubmission.invalid,
        ),
      );
    });
    on<FamilyFlowInvitationReset>(
      (_, emit) => emit(state.copyWith(submission: FamilyFlowSubmission.idle)),
    );
    on<FamilyFlowFamilyDigestChanged>(
      (event, emit) => emit(state.copyWith(familyDigest: event.value)),
    );
    on<FamilyFlowApprovalChanged>(
      (event, emit) =>
          emit(state.copyWith(requireInvitationApproval: event.value)),
    );
    on<FamilyFlowHealthPrivacyChanged>(
      (event, emit) => emit(state.copyWith(protectHealthDetails: event.value)),
    );
  }
}
