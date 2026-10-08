import 'package:flutter/material.dart';
import 'sidebar.dart';
import 'top_header.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Sidebar Navigation
          const Sidebar(),
          
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Header (Search, Profile)
                const TopHeader(),
                
                // Actual Screen Content with constraints
                Expanded(
                  child: Container(
                    width: double.infinity,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
