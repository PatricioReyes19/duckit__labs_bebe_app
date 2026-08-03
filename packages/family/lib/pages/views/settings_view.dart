import 'package:design_system/design_system.dart';
import 'package:family/family.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return BebeSettingsOverviewTemplate(
          accountSection: BebeAccountSummary(
            name: 'Usuario',
            avatar: const CircleAvatar(child: Icon(Icons.person_outline)),
            onPressed: () {},
          ),
          preferencesSection: BebeSettingsSection(
            title: 'Preferencias',
            children: [
              BebeThemeModeSelector(
                value: state.themeMode,
                onChanged: (value) {
                  context.read<SettingsBloc>().add(
                    SettingsEvent.themeChanged(value),
                  );
                },
                systemLabel: 'Usar configuración del sistema',
                lightLabel: 'Claro',
                darkLabel: 'Oscuro',
              ),
              BebeSettingsSwitchTile(
                title: 'Reducir animaciones',
                value: state.reduceMotion,
                onChanged: (value) {
                  context.read<SettingsBloc>().add(
                    SettingsEvent.reduceMotionChanged(value),
                  );
                },
              ),
            ],
          ),
          privacySection: BebeSettingsSection(
            title: 'Privacidad y seguridad',
            children: [
              BebeSettingsActionTile(
                title: 'Privacidad',
                icon: const Icon(Icons.privacy_tip_outlined),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}
