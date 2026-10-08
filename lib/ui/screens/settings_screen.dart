import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../../services/providers.dart';
import '../../core/localization/translations.dart';
import '../../core/localization/app_languages.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _activeCategoryIndex = 0;
  String? _selectedProcedure;
  final _subTypeController = TextEditingController();
  final _procedureController = TextEditingController();

  String? _selectedStorageCategory;
  final _storageCategoryController = TextEditingController();
  final _storageItemController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n(ref);
    
    final categories = [
      {'name': l10n.settingsCatAppearance, 'icon': LucideIcons.palette},
      {'name': l10n.settingsCatLanguage, 'icon': LucideIcons.languages},
      {'name': l10n.settingsCatProcedures, 'icon': LucideIcons.layoutList},
      {'name': l10n.settingsCatStorage, 'icon': LucideIcons.packageOpen},
      {'name': l10n.settingsCatDatabase, 'icon': LucideIcons.database},
      {'name': l10n.settingsCatSystem, 'icon': LucideIcons.info},
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settingsTitle, style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 8),
            Text(l10n.settingsSubtitle, style: TextStyle(color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey), fontSize: 16)),
            const SizedBox(height: 32),
            
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories Sidebar
                  SizedBox(
                    width: 250,
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0; i < categories.length; i++)
                              _buildCategoryTab(
                                i,
                                categories[i]['name'] as String,
                                categories[i]['icon'] as IconData,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Active Panel View
                  Expanded(
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(32),
                        child: _buildActivePanel(l10n),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTab(int index, String title, IconData icon) {
    final isActive = _activeCategoryIndex == index;
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => setState(() => _activeCategoryIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
          border: Border(left: BorderSide(color: isActive ? theme.colorScheme.primary : Colors.transparent, width: 4)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isActive ? theme.colorScheme.primary : (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title, 
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePanel(Translations l10n) {
    switch (_activeCategoryIndex) {
      case 0: return _buildAppearancePanel(ref, l10n);
      case 1: return _buildLanguagePanel(ref, l10n);
      case 2: return _buildProceduresPanel(ref, l10n);
      case 3: return _buildStoragePanel(ref, l10n);
      case 4: return _buildDatabasePanel(ref, l10n);
      case 5: return _buildSystemInfoPanel(l10n);
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildAppearancePanel(WidgetRef ref, Translations l10n) {
    final currentTheme = ref.watch(themeProvider);
    final theme = Theme.of(context);

    // Grouping themes
    final lightThemes = AppThemeMode.values.where((t) => t.name.toLowerCase().contains('light')).toList();
    final darkThemes = AppThemeMode.values.where((t) => !t.name.toLowerCase().contains('light')).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.settingsAppearanceTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(l10n.settingsAppearanceSubtitle, style: TextStyle(color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey))),
        const Divider(height: 48),

        Text(l10n.settingsAppearanceLight, style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: lightThemes.map((t) => _buildThemeCard(t, currentTheme)).toList(),
        ),

        const SizedBox(height: 32),
        Text(l10n.settingsAppearanceDark, style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: darkThemes.map((t) => _buildThemeCard(t, currentTheme)).toList(),
        ),
      ],
    );
  }

  Widget _buildLanguagePanel(WidgetRef ref, Translations l10n) {
    final currentLang = ref.watch(languageProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.settingsLanguageTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(l10n.settingsLanguageSubtitle, style: TextStyle(color: (theme.textTheme.bodyMedium?.color ?? Colors.grey))),
        const Divider(height: 48),

        Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            _buildLanguageCard(AppLanguage.en, l10n.settingsLanguageEnglish, '🇺🇸', currentLang),
            _buildLanguageCard(AppLanguage.bg, l10n.settingsLanguageBulgarian, '🇧🇬', currentLang),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageCard(AppLanguage lang, String label, String flag, AppLanguage currentLang) {
    final isSelected = lang == currentLang;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => ref.read(languageProvider.notifier).setLanguage(lang),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? theme.colorScheme.primary : theme.dividerTheme.color ?? Colors.grey, width: isSelected ? 2 : 1),
          boxShadow: isSelected ? [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.2), blurRadius: 8)] : [],
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(flag, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label, 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(AppThemeMode mode, AppThemeMode currentTheme) {
    final isSelected = mode == currentTheme;
    final themeData = AppThemes.getTheme(mode);
    
    return InkWell(
      onTap: () => ref.read(themeProvider.notifier).changeTheme(mode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 180,
        height: 100,
        decoration: BoxDecoration(
          color: themeData.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? themeData.colorScheme.primary : themeData.dividerTheme.color ?? Colors.grey, width: isSelected ? 2 : 1),
          boxShadow: isSelected ? [BoxShadow(color: themeData.colorScheme.primary.withOpacity(0.3), blurRadius: 8)] : [],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 8, backgroundColor: themeData.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      mode.name, 
                      style: themeData.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              height: 30,
              decoration: BoxDecoration(color: themeData.cardTheme.color, borderRadius: BorderRadius.circular(6)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProceduresPanel(WidgetRef ref, Translations l10n) {
    final proceduresMap = ref.watch(proceduresProvider).valueOrNull ?? {};
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.settingsProceduresTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(l10n.settingsProceduresSubtitle, style: TextStyle(color: (theme.textTheme.bodyMedium?.color ?? Colors.grey))),
        const Divider(height: 48),

        Text(l10n.settingsProceduresStep1, style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        Row(
          children: [
            SizedBox(
              width: 300,
              child: TextField(
                controller: _procedureController,
                decoration: InputDecoration(
                  hintText: l10n.settingsProceduresHint,
                  filled: true,
                  fillColor: theme.scaffoldBackgroundColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                if (_procedureController.text.trim().isNotEmpty) {
                  ref.read(proceduresProvider.notifier).addProcedure(_procedureController.text.trim());
                  _procedureController.clear();
                }
              },
              child: Text(l10n.settingsProceduresAdd),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: proceduresMap.keys.map<Widget>((proc) {
            final isSelected = _selectedProcedure == proc;
            return InputChip(
              label: Text(proc),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedProcedure = selected ? proc : null;
                });
              },
              onDeleted: () {
                if (_selectedProcedure == proc) {
                  setState(() => _selectedProcedure = null);
                }
                ref.read(proceduresProvider.notifier).removeProcedure(proc);
              },
              deleteIcon: const Icon(LucideIcons.x, size: 14),
              showCheckmark: true,
              selectedColor: theme.colorScheme.primary.withOpacity(0.2),
            );
          }).toList(),
        ),

        if (_selectedProcedure != null && proceduresMap.containsKey(_selectedProcedure)) ...[
          const Divider(height: 64),
          Text('${l10n.settingsProceduresStep2} "$_selectedProcedure"', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _subTypeController,
                  decoration: InputDecoration(
                    hintText: l10n.settingsProceduresSubHint,
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  if (_subTypeController.text.trim().isNotEmpty) {
                    ref.read(proceduresProvider.notifier).addSubType(_selectedProcedure!, _subTypeController.text.trim());
                    _subTypeController.clear();
                  }
                },
                child: Text(l10n.settingsProceduresAddSub),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: proceduresMap[_selectedProcedure]!.map((sub) => Chip(
              label: Text(sub, style: const TextStyle(fontSize: 12)),
              deleteIcon: const Icon(LucideIcons.x, size: 12),
              onDeleted: proceduresMap[_selectedProcedure]!.length > 1 
                ? () => ref.read(proceduresProvider.notifier).removeSubType(_selectedProcedure!, sub)
                : null,
              backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildStoragePanel(WidgetRef ref, Translations l10n) {
    final storageMap = ref.watch(storageConfigProvider).valueOrNull ?? {};
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.settingsStorageTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(l10n.settingsStorageSubtitle, style: TextStyle(color: (theme.textTheme.bodyMedium?.color ?? Colors.grey))),
        const Divider(height: 48),

        Text(l10n.settingsStorageStep1, style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        Row(
          children: [
            SizedBox(
              width: 300,
              child: TextField(
                controller: _storageCategoryController,
                decoration: InputDecoration(
                  hintText: l10n.settingsStorageHint,
                  filled: true,
                  fillColor: theme.scaffoldBackgroundColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                if (_storageCategoryController.text.trim().isNotEmpty) {
                  ref.read(storageConfigProvider.notifier).addCategory(_storageCategoryController.text.trim());
                  _storageCategoryController.clear();
                }
              },
              child: Text(l10n.settingsStorageAdd),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: storageMap.keys.map<Widget>((category) {
            final isSelected = _selectedStorageCategory == category;
            return InputChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedStorageCategory = selected ? category : null;
                });
              },
              onDeleted: () {
                if (_selectedStorageCategory == category) {
                  setState(() => _selectedStorageCategory = null);
                }
                ref.read(storageConfigProvider.notifier).removeCategory(category);
              },
              deleteIcon: const Icon(LucideIcons.trash2, size: 14),
              showCheckmark: true,
              selectedColor: theme.colorScheme.primary.withOpacity(0.2),
            );
          }).toList(),
        ),

        if (_selectedStorageCategory != null && storageMap.containsKey(_selectedStorageCategory)) ...[
          const Divider(height: 64),
          Text('${l10n.settingsStorageStep2} "$_selectedStorageCategory"', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _storageItemController,
                  decoration: InputDecoration(
                    hintText: l10n.settingsStorageSubHint,
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  if (_storageItemController.text.trim().isNotEmpty) {
                    ref.read(storageConfigProvider.notifier).addItem(_selectedStorageCategory!, _storageItemController.text.trim());
                    _storageItemController.clear();
                  }
                },
                child: Text(l10n.settingsStorageAddSub),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: storageMap[_selectedStorageCategory]!.map((item) => Chip(
              label: Text(item, style: const TextStyle(fontSize: 12)),
              deleteIcon: const Icon(LucideIcons.x, size: 12),
              onDeleted: () => ref.read(storageConfigProvider.notifier).removeItem(_selectedStorageCategory!, item),
              backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildDatabasePanel(WidgetRef ref, Translations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.settingsDatabaseTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(l10n.settingsDatabaseSubtitle, style: TextStyle(color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey))),
        const Divider(height: 48),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.error.withOpacity(0.05),
            border: Border.all(color: AppTheme.error.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_rounded, color: AppTheme.error),
                  const SizedBox(width: 12),
                  Text(l10n.settingsDatabaseDanger, style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              const SizedBox(height: 16),
              Text(l10n.settingsDatabaseIrreversible, style: TextStyle(color: (Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black))),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error, foregroundColor: Colors.white),
                onPressed: () => _confirmFactoryReset(context, ref, l10n),
                child: Text(l10n.settingsDatabasePurge),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmFactoryReset(BuildContext context, WidgetRef ref, Translations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsDatabaseConfirmTitle),
        content: Text(l10n.settingsDatabaseConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              ref.read(patientsProvider.notifier).clearAll();
              ref.read(appointmentsProvider.notifier).clearAll();
              ref.read(inventoryProvider.notifier).clearAll();
              Navigator.pop(ctx);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.settingsDatabaseSuccess), backgroundColor: AppTheme.success),
              );
            },
            child: Text(l10n.settingsDatabasePurgeConfirm),
          ),
        ],
      )
    );
  }

  Widget _buildSystemInfoPanel(Translations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.settingsCatSystem, style: Theme.of(context).textTheme.titleLarge),
        const Divider(height: 32),
        _buildSysInfoRow(l10n.settingsSystemVersion, 'v1.0.0+1 (Stable Build)'),
        _buildSysInfoRow(l10n.settingsSystemUpdated, 'April 3, 2026'),
        _buildSysInfoRow(l10n.settingsSystemBackend, 'Mock Environment (Ready for Supabase)'),
        _buildSysInfoRow(l10n.settingsSystemLicense, 'Enterprise Medical License #9403-XX'),
      ],
    );
  }

  Widget _buildSysInfoRow(String key, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: TextStyle(color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey), fontWeight: FontWeight.w600)),
          Text(val, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
