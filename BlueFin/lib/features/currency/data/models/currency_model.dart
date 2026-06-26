import '../../domain/entities/exchange_rate.dart';

class CurrencyModel {
  final int curId;
  final String curAbbreviation;
  final int curScale;
  final String curName;

  CurrencyModel({
    required this.curId,
    required this.curAbbreviation,
    required this.curScale,
    required this.curName,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      curId: json['Cur_ID'] as int,
      curAbbreviation: json['Cur_Abbreviation'] as String,
      curScale: json['Cur_Scale'] as int,
      curName: json['Cur_Name'] as String,
    );
  }
}