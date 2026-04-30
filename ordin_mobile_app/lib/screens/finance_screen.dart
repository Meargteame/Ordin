import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/finance_transaction.dart';
import '../data/life_areas_repository.dart';
import '../data/hive_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_app_bar.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  late LifeAreasRepository _repo;
  List<FinanceTransaction> _transactions = [];
  double _balance = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initRepo();
  }

  Future<void> _initRepo() async {
    final storage = HiveStorageService();
    await storage.init();
    _repo = LifeAreasRepository(storage);
    await _loadData();
  }

  Future<void> _loadData() async {
    final transactions = await _repo.loadTransactions();
    final balance = await _repo.getTotalBalance();
    setState(() {
      _transactions = transactions;
      _balance = balance;
      _isLoading = false;
    });
  }

  Future<void> _addTransaction() async {
    TransactionType? type;
    final amountController = TextEditingController();
    final categoryController = TextEditingController();
    final descController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('New Transaction', style: AppTheme.headingLarge),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<TransactionType>(
                  value: type,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    labelStyle: AppTheme.labelMedium,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: TransactionType.values.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(t == TransactionType.income ? 'Income' : 'Expense', style: AppTheme.bodyLarge),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => type = value),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: AppTheme.bodyLarge,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: AppTheme.labelMedium,
                    prefixText: '\$',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.successGreen, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: categoryController,
                  style: AppTheme.bodyLarge,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: AppTheme.labelMedium,
                    hintText: 'Food, Transport, Salary, etc.',
                    hintStyle: AppTheme.bodyMedium,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.successGreen, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  style: AppTheme.bodyLarge,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: AppTheme.labelMedium,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.successGreen, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: AppTheme.labelLarge.copyWith(color: AppTheme.textSecondary)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Add', style: AppTheme.labelLarge.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (result == true && type != null && amountController.text.isNotEmpty && categoryController.text.isNotEmpty) {
      final transaction = FinanceTransaction(
        id: const Uuid().v4(),
        date: DateTime.now(),
        type: type!,
        category: categoryController.text,
        amount: double.parse(amountController.text),
        description: descController.text,
      );
      await _repo.saveTransaction(transaction);
      await _loadData();
    }
  }

  int get _incomeCount => _transactions.where((t) => t.type == TransactionType.income).length;
  int get _expenseCount => _transactions.where((t) => t.type == TransactionType.expense).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: GradientAppBar(
        title: 'Finance',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildBalanceCard(),
                const SizedBox(height: 8),
                Expanded(
                  child: _transactions.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _transactions.length,
                          itemBuilder: (context, index) => _buildTransactionCard(_transactions[index]),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'finance_fab',
        onPressed: _addTransaction,
        backgroundColor: AppTheme.successGreen,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Transaction', style: AppTheme.labelLarge.copyWith(color: Colors.white)),
      ),
    );
  }

  Widget _buildBalanceCard() {
    final balanceColor = _balance >= 0 ? AppTheme.successGreen : AppTheme.dangerRed;

    return Container(
      padding: const EdgeInsets.all(24),
      color: AppTheme.surfaceWhite,
      child: Column(
        children: [
          Text('Total Balance', style: AppTheme.labelLarge),
          const SizedBox(height: 8),
          Text(
            '\$${_balance.toStringAsFixed(2)}',
            style: AppTheme.displayLarge.copyWith(color: balanceColor, fontSize: 40),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Income', '$_incomeCount', Icons.arrow_upward_rounded, AppTheme.successGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Expenses', '$_expenseCount', Icons.arrow_downward_rounded, AppTheme.dangerRed),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Total', '${_transactions.length}', Icons.receipt_rounded, AppTheme.primaryBlue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppTheme.headingMedium.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppTheme.labelMedium),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(FinanceTransaction transaction) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppTheme.successGreen : AppTheme.dangerRed;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(transaction.category, style: AppTheme.labelMedium.copyWith(color: AppTheme.primaryBlue)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(transaction.description, style: AppTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, h:mm a').format(transaction.date),
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
            style: AppTheme.headingMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.account_balance_wallet_rounded, size: 64, color: AppTheme.successGreen.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          Text('No transactions yet', style: AppTheme.headingLarge),
          const SizedBox(height: 8),
          Text('Start tracking your finances', style: AppTheme.bodyMedium),
        ],
      ),
    );
  }
}
