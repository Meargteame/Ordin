import 'package:flutter/material.dart';
import '../theme/theme_helper.dart';
import '../theme/ordin_theme.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: ThemeHelper.backgroundColor(context),
        elevation: 0,
        title: Text(
          'Finance',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ThemeHelper.textPrimary(context),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeHelper.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.attach_money, size: 80, color: ThemeHelper.borderColor(context)),
              const SizedBox(height: 24),
              Text(
                'Finance',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ThemeHelper.textSecondary(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage budgets and track expenses',
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeHelper.textTertiary(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: OrdinTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
