import 'package:BlueFin/core/errors/failures.dart';
import 'package:BlueFin/features/analytics/domain/entities/spending_summary.dart';
import 'package:BlueFin/features/analytics/domain/usecases/get_spending_summary.dart';
import 'package:dartz/dartz.dart';

abstract class IAnalyticsRepository {
  Future<Either<Failure,SpendingSummary>> getSpendingSummary();
}