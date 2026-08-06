import 'package:core/core.dart';

abstract final class StartupPaths {
  static const splash = '/';
  static const authEntry = '/welcome';
  static const login = '/login';
  static const signUp = '/create-account';
  static const onboarding = '/onboarding';
  static const invitation = '/invitation';
  static const createCareCircle = '/care-circle/create';
  static const selectCareCircle = '/care-circle/select';
  static const createBaby = '/baby/create';
  static const selectBaby = '/baby/select';
  static const home = '/home';
}

class StartupRouteMapper {
  const StartupRouteMapper();

  String pathFor(EntryDestination destination) {
    return switch (destination) {
      EntryDestination.authEntry => StartupPaths.authEntry,
      EntryDestination.login => StartupPaths.login,
      EntryDestination.signUp => StartupPaths.signUp,
      EntryDestination.onboarding => StartupPaths.onboarding,
      EntryDestination.invitation => StartupPaths.invitation,
      EntryDestination.createCareCircle => StartupPaths.createCareCircle,
      EntryDestination.selectCareCircle => StartupPaths.selectCareCircle,
      EntryDestination.createBaby => StartupPaths.createBaby,
      EntryDestination.selectBaby => StartupPaths.selectBaby,
      EntryDestination.home => StartupPaths.home,
    };
  }
}
