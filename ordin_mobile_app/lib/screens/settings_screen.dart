import 'package:flutter/material.dart';
import '../theme/ordin_theme.dart';

class SettingsScreen extends StatelessWidget {
  final Function(ThemeMode)? onThemeChanged;
  final ThemeMode? currentThemeMode;
  
  const SettingsScreen({
    super.key,
    this.onThemeChanged,
    this.currentThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? OrdinTheme.darkBackground : const Color(0xFFF8F9FA);
    final cardColor = isDark ? OrdinTheme.darkCard : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1F2937);
    final textSecondary = isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B7280);
    final borderColor = isDark ? OrdinTheme.darkBorder : const Color(0xFFE5E7EB);
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSection(
            context,
            'Appearance',
            [
              _buildThemeOption(context, cardColor, textPrimary, textSecondary, borderColor),
            ],
            cardColor,
            textPrimary,
            borderColor,
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'General',
            [
              _buildSettingItem(
                context,
                Icons.notifications_outlined,
                'Notifications',
                'Manage notification preferences',
                () {},
                cardColor,
                textPrimary,
                textSecondary,
                borderColor,
              ),
              _buildDivider(borderColor),
              _buildSettingItem(
                context,
                Icons.language_outlined,
                'Language',
                'English',
                () {},
                cardColor,
                textPrimary,
                textSecondary,
                borderColor,
              ),
            ],
            cardColor,
            textPrimary,
            borderColor,
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Data',
            [
              _buildSettingItem(
                context,
                Icons.backup_outlined,
                'Backup & Restore',
                'Manage your data backups',
                () {},
                cardColor,
                textPrimary,
                textSecondary,
                borderColor,
              ),
              _buildDivider(borderColor),
              _buildSettingItem(
                context,
                Icons.delete_outline,
                'Clear Cache',
                'Free up storage space',
                () {},
                cardColor,
                textPrimary,
                textSecondary,
                borderColor,
              ),
            ],
            cardColor,
            textPrimary,
            borderColor,
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'About',
            [
              _buildSettingItem(
                context,
                Icons.info_outline,
                'Version',
                '1.0.0',
                null,
                cardColor,
                textPrimary,
                textSecondary,
                borderColor,
              ),
              _buildDivider(borderColor),
              _buildSettingItem(
                context,
                Icons.privacy_tip_outlined,
                'Privacy Policy',
                'Read our privacy policy',
                () {},
                cardColor,
                textPrimary,
                textSecondary,
                borderColor,
              ),
              _buildDivider(borderColor),
              _buildSettingItem(
                context,
                Icons.description_outlined,
                'Terms of Service',
                'Read our terms',
                () {},
                cardColor,
                textPrimary,
                textSecondary,
                borderColor,
              ),
            ],
            cardColor,
            textPrimary,
            borderColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
    Color cardColor,
    Color textPrimary,
    Color borderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
  ) {
    final currentMode = currentThemeMode ?? ThemeMode.system;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: OrdinTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.palette_outlined,
                  color: OrdinTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Choose your preferred theme',
                      style: TextStyle(
                        fontSize: 13,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildThemeButton(
                  context,
                  'Light',
                  Icons.light_mode,
                  ThemeMode.light,
                  currentMode == ThemeMode.light,
                  textPrimary,
                  borderColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeButton(
                  context,
                  'Dark',
                  Icons.dark_mode,
                  ThemeMode.dark,
                  currentMode == ThemeMode.dark,
                  textPrimary,
                  borderColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeButton(
                  context,
                  'System',
                  Icons.brightness_auto,
                  ThemeMode.system,
                  currentMode == ThemeMode.system,
                  textPrimary,
                  borderColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeButton(
    BuildContext context,
    String label,
    IconData icon,
    ThemeMode mode,
    bool isSelected,
    Color textColor,
    Color borderColor,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (onThemeChanged != null) {
            onThemeChanged!(mode);
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? OrdinTheme.primary.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? OrdinTheme.primary : borderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? OrdinTheme.primary : textColor,
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? OrdinTheme.primary : textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback? onTap,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: textSecondary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right, color: textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(Color borderColor) {
    return Divider(height: 1, indent: 58, color: borderColor);
  }
}
