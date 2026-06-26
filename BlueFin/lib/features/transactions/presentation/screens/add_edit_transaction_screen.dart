import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:BlueFin/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:BlueFin/features/transactions/presentation/bloc/transactions_event.dart';
import 'package:BlueFin/features/transactions/presentation/bloc/transactions_state.dart';
import 'package:BlueFin/features/transactions/presentation/widgets/date_picker_field.dart';
import 'package:BlueFin/features/transactions/domain/entities/transaction.dart';

import '../../../categories/presentation/bloc/categories_bloc.dart';
import '../../../categories/presentation/bloc/categories_event.dart';
import '../../../categories/presentation/widgets/category_dropdown.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  const AddEditTransactionScreen({super.key, this.transaction});

  @override
  State<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late TransactionType _type;
  late DateTime _date;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    context.read<CategoriesBloc>().add(CategoryLoadRequested());
    if (widget.transaction != null) {
      _type = widget.transaction!.type;
      _selectedCategoryId = widget.transaction!.categoryId;
      _date = widget.transaction!.date;
      _amountController = TextEditingController(text: widget.transaction!.amount.toString());
      _descriptionController = TextEditingController(text: widget.transaction!.description);
    } else {
      _type = TransactionType.expense;
      _selectedCategoryId = null;
      _date = DateTime.now();
      _amountController = TextEditingController();
      _descriptionController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Выберите категорию')),
        );
        return;
      }
      final transaction = Transaction(
        id: widget.transaction?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        amount: double.parse(_amountController.text),
        categoryId: _selectedCategoryId!,
        date: _date,
        description: _descriptionController.text,
        type: _type,
      );
      if (widget.transaction == null) {
        context.read<TransactionsBloc>().add(TransactionAddRequested(transaction));
      } else {
        context.read<TransactionsBloc>().add(TransactionUpdateRequested(transaction));
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.transaction != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Редактировать' : 'Добавить транзакцию')),
      body: BlocListener<TransactionsBloc, TransactionsState>(
        listener: (context, state) {
          if (state is TransactionsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Доход'),
                      icon: Icon(Icons.arrow_upward),
                    ),
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Расход'),
                      icon: Icon(Icons.arrow_downward),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (Set<TransactionType> newSelection) {
                    setState(() {
                      _type = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 16),

                CategoryDropdown(
                  selectedCategoryId: _selectedCategoryId,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Сумма',
                    border: OutlineInputBorder(),
                    prefixText: '₽ ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите сумму';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Некорректное число';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                DatePickerField(
                  selectedDate: _date,
                  onDateSelected: (newDate) {
                    setState(() {
                      _date = newDate;
                    });
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Описание (необязательно)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _submit,
                  child: Text(isEdit ? 'Сохранить' : 'Добавить'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}