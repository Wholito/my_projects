import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_state.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/save_settings.dart';
import '../../domain/entities/user_settings.dart';
import '../../../../core/usecases/usecase.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final GetSettingsUseCase getSettings;
  final SaveSettingsUseCase saveSettingsUseCase;

  SettingsCubit({
    required this.getSettings,
    required this.saveSettingsUseCase,
  }) : super(SettingsInitial());

  Future<void> loadSettings() async {
    emit(SettingsLoading());
    final result = await getSettings(NoParams());
    result.fold(
          (failure) => emit(SettingsError(failure.message)),
          (settings) => emit(SettingsLoaded(settings)),
    );
  }

  Future<void> saveSettings(UserSettings settings) async {
    emit(SettingsLoading());
    final result = await saveSettingsUseCase(SaveSettingsParams(settings));
    result.fold(
          (failure) => emit(SettingsError(failure.message)),
          (_) => emit(SettingsSaved()),
    );
  }
}