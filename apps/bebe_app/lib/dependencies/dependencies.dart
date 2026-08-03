import 'dart:async';

import 'package:app_base/app_base.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

// Import dependecies config
// ignore: always_use_package_imports
import 'dependencies.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(preferRelativeImports: true)
Future<GetIt> setupDependencies() async {
  await setupAppBaseDependencies();

  await getIt.init();

  return getIt;
}
