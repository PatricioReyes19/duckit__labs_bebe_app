import 'package:design_system/design_system.dart';

sealed class SettingsEvent {
  const SettingsEvent();

  const factory SettingsEvent.started() = SettingsStarted;
  const factory SettingsEvent.themeChanged(BebeThemeModeOption value) =
      SettingsThemeChanged;
  const factory SettingsEvent.highContrastChanged(bool value) =
      SettingsHighContrastChanged;
  const factory SettingsEvent.personalRemindersChanged(bool value) =
      SettingsPersonalRemindersChanged;
  const factory SettingsEvent.familyActivityChanged(bool value) =
      SettingsFamilyActivityChanged;
  const factory SettingsEvent.dailySummaryChanged(bool value) =
      SettingsDailySummaryChanged;
  const factory SettingsEvent.reduceMotionChanged(bool value) =
      SettingsReduceMotionChanged;
  const factory SettingsEvent.wifiOnlyChanged(bool value) =
      SettingsWifiOnlyChanged;
}

final class SettingsStarted extends SettingsEvent {
  const SettingsStarted();
}

final class SettingsThemeChanged extends SettingsEvent {
  const SettingsThemeChanged(this.value);

  final BebeThemeModeOption value;
}

final class SettingsHighContrastChanged extends SettingsEvent {
  const SettingsHighContrastChanged(this.value);

  final bool value;
}

final class SettingsPersonalRemindersChanged extends SettingsEvent {
  const SettingsPersonalRemindersChanged(this.value);

  final bool value;
}

final class SettingsFamilyActivityChanged extends SettingsEvent {
  const SettingsFamilyActivityChanged(this.value);

  final bool value;
}

final class SettingsDailySummaryChanged extends SettingsEvent {
  const SettingsDailySummaryChanged(this.value);

  final bool value;
}

final class SettingsReduceMotionChanged extends SettingsEvent {
  const SettingsReduceMotionChanged(this.value);

  final bool value;
}

final class SettingsWifiOnlyChanged extends SettingsEvent {
  const SettingsWifiOnlyChanged(this.value);

  final bool value;
}

final class SettingsAccountNameChanged extends SettingsEvent {
  const SettingsAccountNameChanged(this.value);

  final String value;
}

final class SettingsLanguageChanged extends SettingsEvent {
  const SettingsLanguageChanged(this.value);

  final String value;
}

final class SettingsTimeFormatChanged extends SettingsEvent {
  const SettingsTimeFormatChanged(this.value);

  final String value;
}

final class SettingsTextSizeChanged extends SettingsEvent {
  const SettingsTextSizeChanged(this.value);

  final String value;
}
