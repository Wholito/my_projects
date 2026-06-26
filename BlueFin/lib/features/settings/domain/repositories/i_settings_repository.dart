import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_settings.dart';

abstract class ISettingsRepository {
  Future<Either<Failure, UserSettings>> getSettings();
  Future<Either<Failure, void>> saveSettings(UserSettings settings);
}