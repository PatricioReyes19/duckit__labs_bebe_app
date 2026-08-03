part of 'settings_bloc.dart';

enum SettingsThemeMode { system, light, dark }

class SettingsState extends Equatable {
  const SettingsState({
    this.isLoading = false,
    this.themeMode = SettingsThemeMode.system,
    this.reduceMotion = false,
  });
  final bool isLoading;
  final SettingsThemeMode themeMode;
  final bool reduceMotion;
  SettingsState copyWith({
    bool? isLoading,
    SettingsThemeMode? themeMode,
    bool? reduceMotion,
  }) => SettingsState(
    isLoading: isLoading ?? this.isLoading,
    themeMode: themeMode ?? this.themeMode,
    reduceMotion: reduceMotion ?? this.reduceMotion,
  );
  @override
  List<Object?> get props => [isLoading, themeMode, reduceMotion];
}
