import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/localization/translations.dart';

class TopHeader extends ConsumerWidget {
  const TopHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n(ref);
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerTheme.color ?? const Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Search Bar
          SizedBox(
            width: 400,
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.commonSearchHint,
                prefixIcon: Icon(LucideIcons.search, color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).textTheme.bodyMedium?.color, size: 20),
                constraints: const BoxConstraints(maxHeight: 45),
                contentPadding: EdgeInsets.zero,
                fillColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
              ),
            ),
          ),
          
          const SizedBox.shrink(),
        ],
      ),
    );
  }
}
