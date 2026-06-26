import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/i_settings_repository.dart';
import '../datasources/settings_local_data_source.dart';

class SettingsRepositoryImpl implements ISettingsRepository {
  final ISettingsLocalDataSource local;

  SettingsRepositoryImpl(this.local);

  @override
  Future<Either<Failure, UserSettings>> getSettings() async {
    try {
      final settings = await local.getSettings();
      return Right(settings ?? const UserSettings());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveSettings(UserSettings settings) async {
    try {
      await local.saveSettings(settings);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}