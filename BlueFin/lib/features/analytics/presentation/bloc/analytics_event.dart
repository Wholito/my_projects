import 'package:equatable/equatable.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();
  @override
  List<Object> get props => [];
}

class AnalyticsLoadRequested extends AnalyticsEvent {}