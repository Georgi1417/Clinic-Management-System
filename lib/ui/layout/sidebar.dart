import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/localization/translations.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curPath = GoRouterState.of(context).uri.path;
    final theme = Theme.of(context);
    final l10n = context.l10n(ref);
    
    return Container(
      width: 250,
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Area
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(LucideIcons.activity, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.brandName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _NavItem(
                  icon: LucideIcons.layoutDashboard,
                  label: l10n.sidebarDashboard,
                  path: '/dashboard',
                  isSelected: curPath.startsWith('/dashboard'),
                ),
                _NavItem(
                  icon: LucideIcons.users,
                  label: l10n.sidebarPatients,
                  path: '/patients',
                  isSelected: curPath.startsWith('/patients'),
                ),
                _NavItem(
                  icon: LucideIcons.calendarDays,
                  label: l10n.sidebarAppointments,
                  path: '/appointments',
                  isSelected: curPath.startsWith('/appointments'),
                ),
                _NavItem(
                  icon: LucideIcons.packageSearch,
                  label: l10n.sidebarStorage,
                  path: '/storage',
                  isSelected: curPath.startsWith('/storage'),
                ),
                _NavItem(
                  icon: Icons.bar_chart,
                  label: l10n.sidebarReports,
                  path: '/reports',
                  isSelected: curPath.startsWith('/reports'),
                ),
                _NavItem(
                  icon: LucideIcons.settings,
                  label: l10n.sidebarSettings,
                  path: '/settings',
                  isSelected: curPath.startsWith('/settings'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;
  final bool isSelected;
  final bool isDanger;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.isSelected,
    // ignore: unused_element_parameter
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDanger 
        ? theme.colorScheme.error 
        : isSelected ? theme.colorScheme.primary : (theme.textTheme.bodyMedium?.color ?? Theme.of(context).textTheme.bodyMedium?.color);
    
    final bgColor = isSelected ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!isDanger) context.go(path);
          },
          borderRadius: BorderRadius.circular(10),
          hoverColor: theme.scaffoldBackgroundColor,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected ? theme.colorScheme.primary : (isDanger ? theme.colorScheme.error : theme.textTheme.bodyLarge?.color),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
