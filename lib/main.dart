import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/router.dart';
import 'theme/theme_provider.dart';
import 'core/localization/app_languages.dart';
import 'core/localization/translations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(
    const ProviderScope(
      child: MedicalClinicApp(),
    ),
  );
}

class MedicalClinicApp extends ConsumerWidget {
  const MedicalClinicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);
    ref.watch(languageProvider);
    
    final themeData = AppThemes.getTheme(themeMode);
    
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n(ref).appTitle,
      debugShowCheckedModeBanner: false,
      theme: themeData,
      themeMode: themeData.brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      locale: ref.read(languageProvider.notifier).locale,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('bg', 'BG'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
