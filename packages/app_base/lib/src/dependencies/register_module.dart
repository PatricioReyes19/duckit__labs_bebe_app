import 'package:core/core.dart';
import 'package:injectable/injectable.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  RegisterEventRepository registerEventRepository() {
    return SqliteRegisterEventRepository();
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
}
