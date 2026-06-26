import 'package:BlueFin/features/analytics/domain/repositories/i_analytics_repository.dart';
import 'package:BlueFin/features/analytics/domain/usecases/get_spending_summary.dart';
import 'package:dartz/dartz.dart';
import 'package:BlueFin/core/errors/failures.dart';
import 'package:BlueFin/core/usecases/usecase.dart';
import 'package:BlueFin/features/analytics/domain/entities/spending_summary.dart';


class GetSpendingSummaryUseCase implements UseCase<SpendingSummary, NoParams> {
  final IAnalyticsRepository analyticsRepository;

  const GetSpendingSummaryUseCase(this.analyticsRepository);

  @override
  Future<Either<Failure, SpendingSummary>> call(NoParams params) async {
    return analyticsRepository.getSpendingSummary();
  }

}