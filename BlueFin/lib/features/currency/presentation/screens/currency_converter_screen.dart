import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/currency_cubit.dart';
import '../cubit/currency_state.dart';
import '../widgets/currency_dropdown.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'BYN';
  String _toCurrency = 'USD';
  final List<String> _currencies = ['BYN', 'RUB', 'USD', 'EUR', 'CNY'];

  @override
  void initState() {
    super.initState();
    context.read<CurrencyCubit>().loadRates();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _convert() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректную сумму')),
      );
      return;
    }
    context.read<CurrencyCubit>().convert(
      from: _fromCurrency,
      to: _toCurrency,
      amount: amount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Конвертер валют'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CurrencyCubit>().loadRates();
            },
          ),
        ],
      ),
      body: BlocConsumer<CurrencyCubit, CurrencyState>(
        listener: (context, state) {
          if (state is CurrencyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ошибка: ${state.message}')),
            );
          }
          if (state is CurrencyConversionResult) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Результат конвертации'),
                content: Text(
                  '${state.amount} ${state.fromCurrency} = ${state.result.toStringAsFixed(2)} ${state.toCurrency}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CurrencyLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CurrencyRatesLoaded) {
            final rates = state.rates;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CurrencyDropdown(
                          selectedCurrency: _fromCurrency,
                          currencies: _currencies,
                          onChanged: (value) {
                            if (value != null) setState(() => _fromCurrency = value);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CurrencyDropdown(
                          selectedCurrency: _toCurrency,
                          currencies: _currencies,
                          onChanged: (value) {
                            if (value != null) setState(() => _toCurrency = value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Сумма',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _convert,
                    child: const Text('Конвертировать'),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: rates.length,
                      itemBuilder: (ctx, index) {
                        final rate = rates[index];
                        return Card(
                          child: ListTile(
                            title: Text('${rate.baseCurrency} → ${rate.targetCurrency}'),
                            trailing: Text(rate.rate.toStringAsFixed(4)),
                            subtitle: Text('Обновлён: ${_formatDate(rate.updatedAt)}'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else if (state is CurrencyError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Ошибка: ${state.message}', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CurrencyCubit>().loadRates();
                    },
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Нажмите "Обновить", чтобы загрузить курсы'));
          }
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute}';
  }
}