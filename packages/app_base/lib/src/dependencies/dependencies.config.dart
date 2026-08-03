// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:agenda/agenda.dart' as _i914;
import 'package:app_layout/app_layout.dart' as _i961;
import 'package:family/family.dart' as _i1027;
import 'package:get_it/get_it.dart' as _i174;
import 'package:health/health.dart' as _i237;
import 'package:home/home.dart' as _i1024;
import 'package:injectable/injectable.dart' as _i526;

import 'blocs_module.dart' as _i513;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final blocsModule = _$BlocsModule();
    gh.factory<_i961.AppLayoutBloc>(() => blocsModule.appLayoutBloc());
    gh.factory<_i914.AgendaBloc>(() => blocsModule.agendaBloc());
    gh.factory<_i237.HealthBloc>(() => blocsModule.healthBloc());
    gh.factory<_i1027.FamilyBloc>(() => blocsModule.familyBloc());
    gh.factory<_i1027.SettingsBloc>(() => blocsModule.settingsBloc());
    gh.factory<_i1024.HomeBloc>(
        () => blocsModule.homeBloc(gh<_i1024.LoadHomeOverview>()));
    return this;
  }
}

class _$BlocsModule extends _i513.BlocsModule {}
