import 'package:family/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Cuenta y configuración'),
              DropdownButtonFormField<SettingsThemeMode>(
                initialValue: state.themeMode,
                items: const [
                  DropdownMenuItem(
                    value: SettingsThemeMode.system,
                    child: Text('Sistema'),
                  ),
                  DropdownMenuItem(
                    value: SettingsThemeMode.light,
                    child: Text('Claro'),
                  ),
                  DropdownMenuItem(
                    value: SettingsThemeMode.dark,
                    child: Text('Oscuro'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null)
                    context.read<SettingsBloc>().add(
                      SettingsThemeModeChanged(v),
                    );
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Reducir animaciones'),
                value: state.reduceMotion,
                onChanged: (v) => context.read<SettingsBloc>().add(
                  SettingsReduceMotionChanged(v),
                ),
              ),
            ],
          );
        },
      );
}
