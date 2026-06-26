import 'package:flutter/material.dart';

class CurrencyDropdown extends StatelessWidget {
  final String selectedCurrency;
  final List<String> currencies;
  final ValueChanged<String?> onChanged;

  const CurrencyDropdown({
    super.key,
    required this.selectedCurrency,
    required this.currencies,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedCurrency,
      decoration: const InputDecoration(
        labelText: 'Валюта',
        border: OutlineInputBorder(),
      ),
      items: currencies.map((currency) {
        return DropdownMenuItem<String>(
          value: currency,
          child: Text(currency),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}