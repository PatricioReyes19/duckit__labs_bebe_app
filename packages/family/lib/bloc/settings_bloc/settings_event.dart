part of 'settings_bloc.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => const [];
}

final class SettingsStarted extends SettingsEvent {
  const SettingsStarted();
}

final class SettingsThemeModeChanged extends SettingsEvent {
  const SettingsThemeModeChanged(this.themeMode);
  final SettingsThemeMode themeMode;
  @override
  List<Object?> get props => [themeMode];
}

final class SettingsReduceMotionChanged extends SettingsEvent {
  const SettingsReduceMotionChanged(this.enabled);
  final bool enabled;
  @override
  List<Object?> get props => [enabled];
}
