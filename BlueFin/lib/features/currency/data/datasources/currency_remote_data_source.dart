import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/rate_model.dart';

abstract class ICurrencyRemoteDataSource {
  Future<List<RateModel>> fetchRates();
}

class CurrencyRemoteDataSource implements ICurrencyRemoteDataSource {
  final Dio dio;

  CurrencyRemoteDataSource(this.dio);

  @override
  Future<List<RateModel>> fetchRates() async {
    try {
      final response = await dio.get(
        'https://api.nbrb.by/exrates/rates',
        queryParameters: {'periodicity': 0},
      );
      if (response.statusCode != 200) {
        throw ServerException('Failed to fetch rates from NBRB API');
      }
      final List<dynamic> data = response.data as List;
      return data.map((json) => RateModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ServerException('Network error: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}