import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'layouts/main_navigation.dart';
import 'providers/settings_provider.dart';
import 'utils/notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationHelper.initialize();
  runApp(
    ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ColorScheme _buildColorScheme(Brightness brightness, {Color? seed}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed ?? Colors.deepPurple,
      brightness: brightness,
    );
    return colorScheme;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    if (!settings.isLoaded) {
      return MaterialApp(
        theme: ThemeData(
          colorScheme: _buildColorScheme(Brightness.light),
          useMaterial3: true,
        ),
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final isDark = settings.themeMode == ThemeMode.dark;
        final useDynamic = settings.useDynamicColor;

        // Use dynamic colors from wallpaper if available and enabled
        // Fall back to seed color if dynamic not available
        final ColorScheme lightScheme = useDynamic && lightDynamic != null
            ? lightDynamic
            : _buildColorScheme(Brightness.light);
        final ColorScheme darkScheme = useDynamic && darkDynamic != null
            ? darkDynamic
            : _buildColorScheme(Brightness.dark);

        return MaterialApp(
          title: 'Momentum',
          theme: ThemeData(
            colorScheme: isDark ? darkScheme : lightScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkScheme,
            useMaterial3: true,
          ),
          themeMode: settings.themeMode,
          home: const MainNavigation(),
        );
      },
    );
  }
}
