import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/providers.dart';
import '../../models/models.dart';
import '../../core/localization/translations.dart';
import '../../core/localization/app_languages.dart';

class StorageScreen extends ConsumerStatefulWidget {
  const StorageScreen({super.key});

  @override
  ConsumerState<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends ConsumerState<StorageScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _translateCategory(String category, Translations l10n) {
    switch (category) {
      case 'Medication':
        return l10n.storageCategoryMedication;
      case 'Equipment':
        return l10n.storageCategoryEquipment;
      case 'Supplies':
        return l10n.storageCategorySupplies;
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryProvider);
    final l10n = context.l10n(ref);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.storageTitle, style: Theme.of(context).textTheme.displayMedium),
                ElevatedButton.icon(
                  onPressed: () => _showAddInventoryDialog(context, ref, l10n),
                  icon: const Icon(LucideIcons.plus),
                  label: Text(l10n.storageAddButton),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                SizedBox(
                  width: 350,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.storageSearchHint,
                      prefixIcon: Icon(LucideIcons.search, color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).textTheme.bodyMedium?.color, size: 20),
                      fillColor: Theme.of(context).cardTheme.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                child: inventoryAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  data: (inventory) {
                    final filteredList = inventory.where((item) {
                      if (_searchQuery.isEmpty) return true;
                      return item.name.toLowerCase().contains(_searchQuery) ||
                             item.category.toLowerCase().contains(_searchQuery);
                    }).toList();

                    return Column(
                      children: [
                        _buildTableHeader(l10n),
                        const Divider(height: 1),
                        Expanded(
                          child: filteredList.isEmpty
                              ? Center(child: Text(l10n.storageNoRecords, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)))
                              : ListView.separated(
                                  itemCount: filteredList.length,
                                  separatorBuilder: (context, index) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    return _buildInventoryRow(context, filteredList[index], l10n);
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(Translations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(l10n.tableId, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(flex: 3, child: Text(l10n.storageTableItemName, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(flex: 2, child: Text(l10n.storageTableCategory, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(flex: 1, child: Text(l10n.storageTableQuantity, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(flex: 2, child: Text(l10n.storageTableExpiration, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(flex: 1, child: Text(l10n.patientsTableActions, textAlign: TextAlign.right, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.bold, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildInventoryRow(BuildContext context, InventoryItem item, Translations l10n) {
    bool isLowStock = item.quantity <= 10;
    bool isExpired = false;
    bool isExpiringSoon = false;

    if (item.expirationDate != null) {
      final daysUntilExp = item.expirationDate!.difference(DateTime.now()).inDays;
      if (daysUntilExp < 0) {
        isExpired = true;
      } else if (daysUntilExp < 30) {
        isExpiringSoon = true;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(item.id, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(item.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_getCategoryIcon(item.category), color: _getCategoryColor(item.category), size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(item.name, style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
                )
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(_translateCategory(item.category, l10n), style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isLowStock ? AppTheme.error.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.quantity.toString(), 
                style: TextStyle(fontWeight: FontWeight.bold, color: isLowStock ? AppTheme.error : Theme.of(context).textTheme.bodyLarge?.color),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                if (item.expirationDate != null) ...[
                  if (isExpired || isExpiringSoon)
                    Icon(Icons.warning_rounded, size: 14, color: isExpired ? AppTheme.error : AppTheme.warning),
                  if (isExpired || isExpiringSoon) const SizedBox(width: 6),
                  Text(
                    DateFormat('MMM dd, yyyy', l10n.language == AppLanguage.en ? 'en_US' : 'bg_BG').format(item.expirationDate!),
                    style: TextStyle(
                      color: isExpired ? AppTheme.error : (isExpiringSoon ? AppTheme.warning : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                      fontWeight: isExpired || isExpiringSoon ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ] else
                  Text(l10n.commonNA, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
              ],
            )
          ),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(icon: const Icon(LucideIcons.pencil, color: AppTheme.primaryBlue, size: 20), onPressed: () => _showEditInventoryDialog(context, ref, item, l10n)),
                  IconButton(icon: const Icon(LucideIcons.trash2, color: AppTheme.error, size: 20), onPressed: () => _confirmDeleteInventory(context, ref, item, l10n)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddInventoryDialog(BuildContext context, WidgetRef ref, Translations l10n) {
    final formKey = GlobalKey<FormState>();
    final config = ref.read(storageConfigProvider).valueOrNull ?? {};
    if (config.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Please add at least one storage category in Settings first.', style: TextStyle(color: Colors.white)), backgroundColor: AppTheme.error));
      return;
    }
    
    String selectedCategory = config.keys.first;
    String? selectedItem;
    DateTime? selectedExpDate;
    final qtyController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text(l10n.storageAddButton),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(labelText: l10n.storageTableCategory, border: const OutlineInputBorder()),
                    items: config.keys.map((c) => DropdownMenuItem(value: c, child: Text(_translateCategory(c, l10n)))).toList(),
                    onChanged: (val) {
                      setModalState(() {
                        selectedCategory = val!;
                        selectedItem = null; // Reset item when category changes
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedItem,
                    hint: Text(l10n.storageSelectSpecific),
                    decoration: InputDecoration(labelText: l10n.storageTableItemName, border: const OutlineInputBorder()),
                    items: (config[selectedCategory] ?? []).map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                    onChanged: (val) => setModalState(() => selectedItem = val),
                    validator: (val) => val == null ? l10n.storageErrorSelectItem : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: qtyController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(labelText: l10n.storageFieldQty, border: const OutlineInputBorder()),
                          validator: (val) => val == null || val.isEmpty || int.tryParse(val) == 0 ? l10n.storageErrorInvalidQty : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final d = await showDatePicker(
                                context: context,
                                initialDate: selectedExpDate ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                            );
                            if (d != null) setModalState(() => selectedExpDate = d);
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(labelText: l10n.storageFieldExpiration, border: const OutlineInputBorder()),
                            child: Text(selectedExpDate != null ? DateFormat('MMM yyyy', l10n.language == AppLanguage.en ? 'en_US' : 'bg_BG').format(selectedExpDate!) : l10n.storageNoExpiry, style: TextStyle(color: selectedExpDate == null ? Theme.of(context).textTheme.bodyMedium?.color : Theme.of(context).textTheme.bodyLarge?.color)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.commonCancel)),
            ElevatedButton(
               onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newId = 'I-${DateTime.now().millisecondsSinceEpoch}';
                  final newItem = InventoryItem(
                    id: newId,
                    name: selectedItem!,
                    category: selectedCategory,
                    quantity: int.parse(qtyController.text),
                    expirationDate: selectedExpDate,
                  );
                  ref.read(inventoryProvider.notifier).addItem(newItem);
                  Navigator.of(ctx).pop();
                }
              },
              child: Text(l10n.storageAddButton),
            )
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  void _showEditInventoryDialog(BuildContext context, WidgetRef ref, InventoryItem item, Translations l10n) {
    final formKey = GlobalKey<FormState>();
    final config = ref.read(storageConfigProvider).valueOrNull ?? {};

    String selectedCategory = item.category;
    String selectedItem = item.name;
    DateTime? selectedExpDate = item.expirationDate;
    final qtyController = TextEditingController(text: item.quantity.toString());

    if (!config.containsKey(selectedCategory) && config.isNotEmpty) {
        selectedCategory = config.keys.first;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text('${l10n.patientsDialogEditTitle}: ${item.name}'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: config.isEmpty ? const Center(child: Text('Storage Categories configuration represents an empty state. Please verify settings.')) : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: config.containsKey(selectedCategory) ? selectedCategory : config.keys.first,
                    decoration: InputDecoration(labelText: l10n.storageTableCategory, border: const OutlineInputBorder()),
                    items: config.keys.map((c) => DropdownMenuItem(value: c, child: Text(_translateCategory(c, l10n)))).toList(),
                    onChanged: (val) {
                      setModalState(() {
                        selectedCategory = val!;
                        if (config[selectedCategory]!.isNotEmpty) {
                          selectedItem = config[selectedCategory]!.first;
                        } else {
                          selectedItem = '';
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: (config[selectedCategory] ?? []).contains(selectedItem) ? selectedItem : null,
                    hint: Text(l10n.storageSelectSpecific),
                    decoration: InputDecoration(labelText: l10n.storageTableItemName, border: const OutlineInputBorder()),
                    items: (config[selectedCategory] ?? []).map((it) => DropdownMenuItem(value: it, child: Text(it))).toList(),
                    onChanged: (val) => setModalState(() => selectedItem = val!),
                    validator: (val) => val == null ? l10n.storageErrorSelectItem : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: qtyController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(labelText: l10n.storageFieldQty, border: const OutlineInputBorder()),
                          validator: (val) => val == null || val.isEmpty || int.tryParse(val) == null ? l10n.storageErrorInvalidQty : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final d = await showDatePicker(
                                context: context,
                                initialDate: selectedExpDate ?? DateTime.now(),
                                firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
                                lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                            );
                            if (d != null) setModalState(() => selectedExpDate = d);
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(labelText: l10n.storageFieldExpiration, border: const OutlineInputBorder()),
                            child: Text(selectedExpDate != null ? DateFormat('MMM yyyy', l10n.language == AppLanguage.en ? 'en_US' : 'bg_BG').format(selectedExpDate!) : l10n.storageNoExpiry, style: TextStyle(color: selectedExpDate == null ? Theme.of(context).textTheme.bodyMedium?.color : Theme.of(context).textTheme.bodyLarge?.color)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.commonCancel)),
            ElevatedButton(
               onPressed: () {
                if (formKey.currentState!.validate()) {
                  final updatedItem = InventoryItem(
                    id: item.id,
                    name: selectedItem,
                    category: selectedCategory,
                    quantity: int.parse(qtyController.text),
                    expirationDate: selectedExpDate,
                  );
                  ref.read(inventoryProvider.notifier).updateItem(updatedItem);
                  Navigator.of(ctx).pop();
                }
              },
              child: Text(l10n.patientsSaveChanges),
            )
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  void _confirmDeleteInventory(BuildContext context, WidgetRef ref, InventoryItem item, Translations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.storageDialogRemoveTitle),
        content: Text('${l10n.storageDialogRemoveConfirm}\n\n${item.name}'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.commonCancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              ref.read(inventoryProvider.notifier).deleteItem(item.id);
              Navigator.of(ctx).pop();
            },
            child: Text(l10n.commonDelete),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Medication':
        return AppTheme.primaryBlue;
      case 'Equipment':
        return AppTheme.warning;
      case 'Supplies':
        return const Color(0xFF10B981);
      default:
        return Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Medication':
        return LucideIcons.pill;
      case 'Equipment':
        return LucideIcons.stethoscope;
      case 'Supplies':
        return LucideIcons.package;
      default:
        return LucideIcons.box;
    }
  }
}
