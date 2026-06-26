import '../../domain/entities/exchange_rate.dart';

class RateModel {
  final int curId;
  final DateTime date;
  final String curAbbreviation;
  final int curScale;
  final String curName;
  final double curOfficialRate;

  RateModel({
    required this.curId,
    required this.date,
    required this.curAbbreviation,
    required this.curScale,
    required this.curName,
    required this.curOfficialRate,
  });

  factory RateModel.fromJson(Map<String, dynamic> json) {
    return RateModel(
      curId: json['Cur_ID'] as int,
      date: DateTime.parse(json['Date'] as String),
      curAbbreviation: json['Cur_Abbreviation'] as String,
      curScale: json['Cur_Scale'] as int,
      curName: json['Cur_Name'] as String,
      curOfficialRate: (json['Cur_OfficialRate'] as num).toDouble(),
    );
  }

  ExchangeRate toDomain() {
    return ExchangeRate(
      baseCurrency: 'BYN',
      targetCurrency: curAbbreviation,
      rate: curOfficialRate / curScale,
      updatedAt: date,
    );
  }
}