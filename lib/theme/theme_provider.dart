import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeMode {
  lightVS, lightModern, lightPlus, quietLight, solarizedLight, tokyoNightLight,
  abyss, darkVS, darkModern, darkPlus, kimbieDark, monokai, monokaiDimmed,
  redTheme, solarizedDark, synthWave84, tokyoNight, tokyoNightStorm, tomorrowNightBlue
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.lightModern); // Default to clean medical look

  void changeTheme(AppThemeMode mode) {
    state = mode;
  }
}

class AppThemes {
  static ThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      // ==== LIGHT THEMES ====
      case AppThemeMode.lightVS:
        return _buildTheme(bg: const Color(0xFFF3F3F3), surface: const Color(0xFFFFFFFF), prim: const Color(0xFF007ACC), text: const Color(0xFF333333), isDark: false);
      case AppThemeMode.lightModern:
        return _buildTheme(bg: const Color(0xFFF3F4F6), surface: const Color(0xFFFFFFFF), prim: const Color(0xFF2563EB), text: const Color(0xFF1F2937), isDark: false);
      case AppThemeMode.lightPlus:
        return _buildTheme(bg: const Color(0xFFFFFFFF), surface: const Color(0xFFF9F9F9), prim: const Color(0xFF007ACC), text: const Color(0xFF000000), isDark: false);
      case AppThemeMode.quietLight:
        return _buildTheme(bg: const Color(0xFFF5F5F5), surface: const Color(0xFFFFFFFF), prim: const Color(0xFF705697), text: const Color(0xFF333333), isDark: false);
      case AppThemeMode.solarizedLight:
        return _buildTheme(bg: const Color(0xFFFDF6E3), surface: const Color(0xFFEEE8D5), prim: const Color(0xFF2AA198), text: const Color(0xFF657B83), isDark: false);
      case AppThemeMode.tokyoNightLight:
        return _buildTheme(bg: const Color(0xFFD5D6DB), surface: const Color(0xFFE1E2E7), prim: const Color(0xFF0f4b6e), text: const Color(0xFF343B58), isDark: false);
      
      // ==== DARK THEMES ====
      case AppThemeMode.abyss:
        return _buildTheme(bg: const Color(0xFF000C18), surface: const Color(0xFF00142A), prim: const Color(0xFF6B9ED3), text: const Color(0xFFCCCCCC), isDark: true);
      case AppThemeMode.darkVS:
        return _buildTheme(bg: const Color(0xFF1E1E1E), surface: const Color(0xFF252526), prim: const Color(0xFF007ACC), text: const Color(0xFFD4D4D4), isDark: true);
      case AppThemeMode.darkModern:
        return _buildTheme(bg: const Color(0xFF18181A), surface: const Color(0xFF232326), prim: const Color(0xFF2563EB), text: const Color(0xFFE5E7EB), isDark: true);
      case AppThemeMode.darkPlus:
        return _buildTheme(bg: const Color(0xFF1E1E1E), surface: const Color(0xFF2D2D30), prim: const Color(0xFF0E639C), text: const Color(0xFFCCCCCC), isDark: true);
      case AppThemeMode.kimbieDark:
        return _buildTheme(bg: const Color(0xFF221A0F), surface: const Color(0xFF362712), prim: const Color(0xFFDC3958), text: const Color(0xFFD3AF86), isDark: true);
      case AppThemeMode.monokai:
        return _buildTheme(bg: const Color(0xFF272822), surface: const Color(0xFF3E3D32), prim: const Color(0xFFA6E22E), text: const Color(0xFFF8F8F2), isDark: true);
      case AppThemeMode.monokaiDimmed:
        return _buildTheme(bg: const Color(0xFF1E1E1E), surface: const Color(0xFF272822), prim: const Color(0xFF9B9B9B), text: const Color(0xFFC5C8C6), isDark: true);
      case AppThemeMode.redTheme:
        return _buildTheme(bg: const Color(0xFF390000), surface: const Color(0xFF520000), prim: const Color(0xFFF12A2A), text: const Color(0xFFF8F8F8), isDark: true);
      case AppThemeMode.solarizedDark:
        return _buildTheme(bg: const Color(0xFF002B36), surface: const Color(0xFF073642), prim: const Color(0xFF2AA198), text: const Color(0xFF839496), isDark: true);
      case AppThemeMode.synthWave84:
        return _buildTheme(bg: const Color(0xFF262335), surface: const Color(0xFF2B213A), prim: const Color(0xFFFF7EDB), text: const Color(0xFFFFEEFF), isDark: true);
      case AppThemeMode.tokyoNight:
        return _buildTheme(bg: const Color(0xFF1A1B26), surface: const Color(0xFF24283B), prim: const Color(0xFF7AA2F7), text: const Color(0xFFA9B1D6), isDark: true);
      case AppThemeMode.tokyoNightStorm:
        return _buildTheme(bg: const Color(0xFF24283B), surface: const Color(0xFF1F2335), prim: const Color(0xFF7DCFFF), text: const Color(0xFFC0CAF5), isDark: true);
      case AppThemeMode.tomorrowNightBlue:
        return _buildTheme(bg: const Color(0xFF002451), surface: const Color(0xFF003F8E), prim: const Color(0xFF84D8ED), text: const Color(0xFFFFFFFF), isDark: true);
    }
  }

  static ThemeData _buildTheme({required Color bg, required Color surface, required Color prim, required Color text, required bool isDark}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: prim,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: prim,
      onPrimary: _getTextColor(prim),
      surface: surface,
      onSurface: text,
      secondary: prim.withOpacity(0.8),
      onSecondary: _getTextColor(prim),
      error: const Color(0xFFEF4444),
      onError: Colors.white,
    );

    final baseTextTheme = isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(baseTextTheme).copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.bold, color: text),
      displayMedium: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w700, color: text),
      displaySmall: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w600, color: text),
      titleLarge: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w600, color: text),
      titleMedium: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600, color: text),
      bodyLarge: GoogleFonts.plusJakartaSans(fontSize: 16, color: text),
      bodyMedium: GoogleFonts.plusJakartaSans(fontSize: 14, color: text.withOpacity(0.8)),
      bodySmall: GoogleFonts.plusJakartaSans(fontSize: 12, color: text.withOpacity(0.6)),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bg,
      colorScheme: colorScheme,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), 
          side: BorderSide(color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE5E7EB), width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE5E7EB),
        space: 1,
        thickness: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: prim,
          foregroundColor: _getTextColor(prim),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: prim,
          side: BorderSide(color: prim),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? surface.withOpacity(0.5) : surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: prim, width: 2)),
        labelStyle: GoogleFonts.plusJakartaSans(color: text.withOpacity(0.7)),
        hintStyle: GoogleFonts.plusJakartaSans(color: text.withOpacity(0.5)),
      ),
      iconTheme: IconThemeData(color: text),
    );
  }

  static Color _getTextColor(Color background) {
    if (background.computeLuminance() > 0.5) return Colors.black;
    return Colors.white;
  }
}

extension AppThemeModeExtension on AppThemeMode {
  String get name {
    switch (this) {
      case AppThemeMode.lightVS: return "Light (Visual Studio)";
      case AppThemeMode.lightModern: return "Light Modern";
      case AppThemeMode.lightPlus: return "Light+";
      case AppThemeMode.quietLight: return "Quiet Light";
      case AppThemeMode.solarizedLight: return "Solarized Light";
      case AppThemeMode.tokyoNightLight: return "Tokyo Night Light";
      case AppThemeMode.abyss: return "Abyss";
      case AppThemeMode.darkVS: return "Dark (Visual Studio)";
      case AppThemeMode.darkModern: return "Dark Modern";
      case AppThemeMode.darkPlus: return "Dark+";
      case AppThemeMode.kimbieDark: return "Kimbie Dark";
      case AppThemeMode.monokai: return "Monokai";
      case AppThemeMode.monokaiDimmed: return "Monokai Dimmed";
      case AppThemeMode.redTheme: return "Red";
      case AppThemeMode.solarizedDark: return "Solarized Dark";
      case AppThemeMode.synthWave84: return "SynthWave '84";
      case AppThemeMode.tokyoNight: return "Tokyo Night";
      case AppThemeMode.tokyoNightStorm: return "Tokyo Night Storm";
      case AppThemeMode.tomorrowNightBlue: return "Tomorrow Night Blue";
    }
  }
}
