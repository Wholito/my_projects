import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_settings.dart';
import '../repositories/i_settings_repository.dart';

class SaveSettingsParams {
  final UserSettings settings;
  const SaveSettingsParams(this.settings);
}

class SaveSettingsUseCase implements UseCase<void, SaveSettingsParams> {
  final ISettingsRepository repository;
  const SaveSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveSettingsParams params) {
    return repository.saveSettings(params.settings);
  }
}