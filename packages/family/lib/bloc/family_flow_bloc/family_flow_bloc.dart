import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum FamilyRelationship { mother, father, grandparent, relative, caregiver }

enum FamilyCapability { history, registerEvents, health, reminders }

enum FamilyFlowSubmission { idle, submitting, invalid, success, failure }

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
  const FamilyFlowInvitationSubmitted({
    required this.contact,
    this.familyId = '',
    this.babyId = '',
    this.babyName = '',
    this.name = '',
  });

  final String contact;
  final String familyId;
  final String babyId;
  final String babyName;
  final String name;
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
    this.invitedMember,
    this.message,
  });

  final String selectedBabyId;
  final FamilyRelationship relationship;
  final Map<FamilyCapability, bool> capabilities;
  final FamilyFlowSubmission submission;
  final bool familyDigest;
  final bool requireInvitationApproval;
  final bool protectHealthDetails;
  final FamilyMemberEntity? invitedMember;
  final String? message;

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
    FamilyMemberEntity? invitedMember,
    String? message,
    bool clearInvitedMember = false,
    bool clearMessage = false,
  }) => FamilyFlowState(
    selectedBabyId: selectedBabyId ?? this.selectedBabyId,
    relationship: relationship ?? this.relationship,
    capabilities: capabilities ?? this.capabilities,
    submission: submission ?? this.submission,
    familyDigest: familyDigest ?? this.familyDigest,
    requireInvitationApproval:
        requireInvitationApproval ?? this.requireInvitationApproval,
    protectHealthDetails: protectHealthDetails ?? this.protectHealthDetails,
    invitedMember: clearInvitedMember
        ? null
        : invitedMember ?? this.invitedMember,
    message: clearMessage ? null : message ?? this.message,
  );
}

class FamilyFlowBloc extends Bloc<FamilyFlowEvent, FamilyFlowState> {
  FamilyFlowBloc({String initialBabyId = '', FamilyRepository? repository})
    : _repository = repository,
      super(FamilyFlowState(selectedBabyId: initialBabyId)) {
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
    on<FamilyFlowInvitationSubmitted>((event, emit) async {
      final contact = event.contact.trim();
      final isValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(contact);
      if (!isValid) {
        emit(
          state.copyWith(
            submission: FamilyFlowSubmission.invalid,
            clearMessage: true,
          ),
        );
        return;
      }
      final repository = _repository;
      if (repository == null) {
        emit(state.copyWith(submission: FamilyFlowSubmission.success));
        return;
      }
      emit(
        state.copyWith(
          submission: FamilyFlowSubmission.submitting,
          clearInvitedMember: true,
          clearMessage: true,
        ),
      );
      try {
        final member = await repository.sendInvitation(
          FamilyInvitationDraft(
            familyId: event.familyId,
            babyId: event.babyId,
            babyName: event.babyName,
            name: event.name,
            contact: contact.toLowerCase(),
            role: _relationshipLabel(state.relationship),
            accessDescription: _capabilitySummary(state.capabilities),
            canWrite:
                state.capabilities[FamilyCapability.registerEvents] ?? false,
          ),
        );
        emit(
          state.copyWith(
            submission: FamilyFlowSubmission.success,
            invitedMember: member,
          ),
        );
      } on Object catch (error) {
        final detail = error.toString().replaceFirst('Bad state: ', '');
        emit(
          state.copyWith(
            submission: FamilyFlowSubmission.failure,
            message: detail,
          ),
        );
      }
    });
    on<FamilyFlowInvitationReset>(
      (_, emit) => emit(
        state.copyWith(
          submission: FamilyFlowSubmission.idle,
          clearMessage: true,
        ),
      ),
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

  final FamilyRepository? _repository;

  static String _relationshipLabel(FamilyRelationship relationship) =>
      switch (relationship) {
        FamilyRelationship.mother => 'Mamá',
        FamilyRelationship.father => 'Papá',
        FamilyRelationship.grandparent => 'Abuelo/a',
        FamilyRelationship.relative => 'Familiar',
        FamilyRelationship.caregiver => 'Cuidador/a',
      };

  static String _capabilitySummary(Map<FamilyCapability, bool> values) {
    final enabled = <String>[
      if (values[FamilyCapability.history] ?? false) 'ver historial',
      if (values[FamilyCapability.registerEvents] ?? false) 'registrar',
      if (values[FamilyCapability.health] ?? false) 'ver salud',
      if (values[FamilyCapability.reminders] ?? false) 'recibir recordatorios',
    ];
    return enabled.isEmpty ? 'Sin capacidades asignadas' : enabled.join(', ');
  }
}
