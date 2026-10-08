import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ui/layout/main_layout.dart';
import '../ui/screens/dashboard_screen.dart';
import '../ui/screens/patients_screen.dart';
import '../ui/screens/appointments_screen.dart';
import '../ui/screens/reports_screen.dart';
import '../ui/screens/settings_screen.dart';
import '../ui/screens/patient_details_screen.dart';
import '../ui/screens/storage_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/dashboard',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: '/patients',
            name: 'patients',
            pageBuilder: (context, state) => const NoTransitionPage(child: PatientsScreen()),
            routes: [
              GoRoute(
                path: ':id',
                name: 'patientDetails',
                pageBuilder: (context, state) {
                  final patientId = state.pathParameters['id']!;
                  return NoTransitionPage(child: PatientDetailsScreen(patientId: patientId));
                },
              ),
            ],
          ),
          GoRoute(
            path: '/appointments',
            name: 'appointments',
            pageBuilder: (context, state) => const NoTransitionPage(child: AppointmentsScreen()),
          ),
          GoRoute(
            path: '/reports',
            name: 'reports',
            pageBuilder: (context, state) => const NoTransitionPage(child: ReportsScreen()),
          ),
          GoRoute(
            path: '/storage',
            name: 'storage',
            pageBuilder: (context, state) => const NoTransitionPage(child: StorageScreen()),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),
    ],
  );
});
