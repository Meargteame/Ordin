import '../models/life_area.dart';
import '../models/health_metric.dart';
import '../models/finance_transaction.dart';
import '../models/contact.dart';
import '../models/learning_item.dart';
import 'hive_storage_service.dart';
import 'package:uuid/uuid.dart';

class LifeAreasRepository {
  final HiveStorageService _storage;
  final _uuid = const Uuid();

  LifeAreasRepository(this._storage);

  // Life Areas
  Future<List<LifeArea>> loadLifeAreas() async {
    return _storage.lifeAreasBox.values.toList();
  }

  Future<void> saveLifeArea(LifeArea area) async {
    await _storage.lifeAreasBox.put(area.id, area);
  }

  Future<void> deleteLifeArea(String id) async {
    await _storage.lifeAreasBox.delete(id);
  }

  Future<void> updateHealthScore(String areaId) async {
    final area = _storage.lifeAreasBox.get(areaId);
    if (area == null) return;

    final score = await _calculateHealthScore(area);
    area.healthScore = score;
    area.lastUpdated = DateTime.now();
    await saveLifeArea(area);
  }

  // Health
  Future<List<HealthMetric>> loadHealthMetrics() async {
    return _storage.healthMetricsBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> saveHealthMetric(HealthMetric metric) async {
    await _storage.healthMetricsBox.put(metric.id, metric);
  }

  Future<List<HealthMetric>> getHealthMetricsForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final metrics = await loadHealthMetrics();
    return metrics.where((m) =>
      m.date.isAfter(start.subtract(const Duration(days: 1))) &&
      m.date.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }

  // Finance
  Future<List<FinanceTransaction>> loadTransactions() async {
    return _storage.transactionsBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> saveTransaction(FinanceTransaction transaction) async {
    await _storage.transactionsBox.put(transaction.id, transaction);
  }

  Future<Map<String, double>> getSpendingByCategory(
    DateTime start,
    DateTime end,
  ) async {
    final transactions = await loadTransactions();
    final expenses = transactions.where((t) =>
      t.type == TransactionType.expense &&
      t.date.isAfter(start.subtract(const Duration(days: 1))) &&
      t.date.isBefore(end.add(const Duration(days: 1)))
    );

    final spending = <String, double>{};
    for (final expense in expenses) {
      spending[expense.category] = (spending[expense.category] ?? 0) + expense.amount;
    }
    return spending;
  }

  Future<double> getTotalBalance() async {
    final transactions = await loadTransactions();
    double balance = 0;
    for (final t in transactions) {
      if (t.type == TransactionType.income) {
        balance += t.amount;
      } else {
        balance -= t.amount;
      }
    }
    return balance;
  }

  // Relationships
  Future<List<Contact>> loadContacts() async {
    return _storage.contactsBox.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> saveContact(Contact contact) async {
    await _storage.contactsBox.put(contact.id, contact);
  }

  Future<void> deleteContact(String id) async {
    await _storage.contactsBox.delete(id);
  }

  Future<List<Contact>> getContactsNeedingAttention() async {
    final contacts = await loadContacts();
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return contacts.where((c) =>
      c.lastInteraction == null || c.lastInteraction!.isBefore(thirtyDaysAgo)
    ).toList();
  }

  // Learning
  Future<List<LearningItem>> loadLearningItems() async {
    return _storage.learningItemsBox.values.toList();
  }

  Future<void> saveLearningItem(LearningItem item) async {
    await _storage.learningItemsBox.put(item.id, item);
  }

  Future<void> deleteLearningItem(String id) async {
    await _storage.learningItemsBox.delete(id);
  }

  String generateId() => _uuid.v4();

  Future<double> _calculateHealthScore(LifeArea area) async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    switch (area.type) {
      case LifeAreaType.health:
        final metrics = await getHealthMetricsForDateRange(thirtyDaysAgo, now);
        final daysWithActivity = metrics.map((m) => m.date.day).toSet().length;
        return daysWithActivity / 30.0;

      case LifeAreaType.finance:
        final transactions = await loadTransactions();
        final recentTransactions = transactions.where((t) =>
          t.date.isAfter(thirtyDaysAgo)
        ).toList();
        return recentTransactions.isNotEmpty ? 1.0 : 0.5;

      case LifeAreaType.relationships:
        final contacts = await loadContacts();
        if (contacts.isEmpty) return 1.0;
        final recentInteractions = contacts.where((c) =>
          c.lastInteraction != null && c.lastInteraction!.isAfter(thirtyDaysAgo)
        ).length;
        return recentInteractions / contacts.length;

      case LifeAreaType.learning:
        final items = await loadLearningItems();
        if (items.isEmpty) return 1.0;
        final activeItems = items.where((i) =>
          i.status == LearningStatus.inProgress
        ).length;
        return activeItems / items.length;

      default:
        return 0.5;
    }
  }
}
