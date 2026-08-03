import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

// ignore: always_use_package_imports
import 'dependencies.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  preferRelativeImports: true,
)
FutureOr<GetIt> setupAppBaseDependencies() {
  return getIt.init();
}
