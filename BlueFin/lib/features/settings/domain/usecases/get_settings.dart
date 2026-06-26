import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_settings.dart';
import '../repositories/i_settings_repository.dart';

class GetSettingsUseCase implements UseCase<UserSettings, NoParams> {
  final ISettingsRepository repository;
  const GetSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, UserSettings>> call(NoParams params) {
    return repository.getSettings();
  }
}