import 'package:core/core.dart';
import 'package:injectable/injectable.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  RegisterEventRepository registerEventRepository(BebeDatabase database) {
    return SqliteRegisterEventRepository(database: database);
  }

  @lazySingleton
  SaveRegisterEvent saveRegisterEvent(RegisterEventRepository repository) {
    return SaveRegisterEvent(repository);
  }

  @lazySingleton
  GetRegisterEvents getRegisterEvents(RegisterEventRepository repository) {
    return GetRegisterEvents(repository);
  }

  @lazySingleton
  DeleteRegisterEvent deleteRegisterEvent(
    RegisterEventRepository repository,
  ) {
    return DeleteRegisterEvent(repository);
  }

  @lazySingleton
  UpdateRegisterEvent updateRegisterEvent(RegisterEventRepository repository) {
    return UpdateRegisterEvent(repository);
  }
}
