import 'package:chatglobe/route/route.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  usePathUrlStrategy();

  await Supabase.initialize(
    url: const String.fromEnvironment("SUPABASE_URL"),
    anonKey: const String.fromEnvironment("SUPABASE_KEY"),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ChatGlobe',
      theme: ThemeData.dark().copyWith(
          useMaterial3: true,
          textTheme: ThemeData.dark().textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
          canvasColor: Colors.black,
          focusColor: Colors.black,
          scaffoldBackgroundColor: Colors.black,
          colorScheme: const ColorScheme.dark(
            background: Colors.black,
            surface: Colors.transparent,
          )),
      routerConfig: router,
    );
  }
}
