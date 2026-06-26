import 'package:equatable/equatable.dart';
import '../../domain/usecases/get_spending_summary.dart';
import 'package:BlueFin/features/analytics/domain/entities/spending_summary.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();
  @override
  List<Object> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final SpendingSummary summary;
  const AnalyticsLoaded(this.summary);
  @override
  List<Object> get props => [summary];
}

class AnalyticsError extends AnalyticsState {
  final String message;
  const AnalyticsError(this.message);
  @override
  List<Object> get props => [message];
}