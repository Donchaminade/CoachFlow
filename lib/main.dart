import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/settings_providers.dart';
import 'core/config/supabase_config.dart';
import 'core/l10n/app_localizations.dart';
import 'core/l10n/locale_provider.dart';
import 'features/coach/models/coach.dart';
import 'features/chat/models/message.dart';
import 'features/settings/models/user_context.dart';

import 'features/sharing/models/shared_conversation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  
  await Hive.initFlutter();
  
  Hive.registerAdapter(CoachAdapter());
  Hive.registerAdapter(MessageAdapter());
  Hive.registerAdapter(UserContextAdapter());

  Hive.registerAdapter(SharedConversationAdapter());
  
  // Open boxes
  await Hive.openBox<Coach>('coaches');
  await Hive.openBox<Message>('messages');
  await Hive.openBox<UserContext>('user_context');

  await Hive.openBox('settings'); // For theme & notifications

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the router provider
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'CoachFlow',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
      ],
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
