import 'package:flutter_bloc/flutter_bloc.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';
import '../../domain/usecases/get_spending_summary.dart';
import '../../../../core/usecases/usecase.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final GetSpendingSummaryUseCase getSpendingSummary;

  AnalyticsBloc({required this.getSpendingSummary}) : super(AnalyticsInitial()) {
    on<AnalyticsLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
      AnalyticsLoadRequested event,
      Emitter<AnalyticsState> emit,
      ) async {
    emit(AnalyticsLoading());
    final result = await getSpendingSummary(NoParams());
    result.fold(
          (failure) => emit(AnalyticsError(failure.message)),
          (summary) => emit(AnalyticsLoaded(summary)),
    );
  }
}