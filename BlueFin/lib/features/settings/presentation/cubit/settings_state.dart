import 'package:equatable/equatable.dart';
import '../../domain/entities/user_settings.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final UserSettings settings;
  const SettingsLoaded(this.settings);
  @override
  List<Object> get props => [settings];
}

class SettingsSaved extends SettingsState {}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);
  @override
  List<Object> get props => [message];
}