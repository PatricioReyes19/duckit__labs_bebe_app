import 'package:design_system/design_system/design_system.dart';

enum BebeQuickActionType {
  feeding,
  sleep,
  diaper,
  observation,
  medicine,
  measurement,
}

extension BebeQuickActionTypeMapper on BebeQuickActionType {
  BebeCategoryActionTileVariant toTitleVariant() {
    return switch (this) {
      BebeQuickActionType.feeding => BebeCategoryActionTileVariant.feeding,
      BebeQuickActionType.sleep => BebeCategoryActionTileVariant.sleep,
      BebeQuickActionType.diaper => BebeCategoryActionTileVariant.diaper,
      BebeQuickActionType.observation =>
        BebeCategoryActionTileVariant.observation,
      BebeQuickActionType.medicine => BebeCategoryActionTileVariant.medication,
      BebeQuickActionType.measurement => BebeCategoryActionTileVariant.neutral,
    };
  }
}
