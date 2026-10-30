import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/session.dart';
import 'core/theme/app_theme.dart';
import 'features/shell/shell_screen.dart';

class RaahApp extends StatefulWidget {
  const RaahApp({super.key});

  @override
  State<RaahApp> createState() => _RaahAppState();
}

class _RaahAppState extends State<RaahApp> {
  final _session = Session();

  @override
  void initState() {
    super.initState();
    _session.load();
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SessionScope(
      session: _session,
      child: ListenableBuilder(
        listenable: _session,
        builder: (context, _) => MaterialApp(
          title: 'Raah',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: _session.themeMode,
          builder: (context, child) {
            final dark = Theme.of(context).brightness == Brightness.dark;
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: (dark
                      ? SystemUiOverlayStyle.light
                      : SystemUiOverlayStyle.dark)
                  .copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: Colors.transparent,
              ),
              child: child!,
            );
          },
          home: const ShellScreen(),
        ),
      ),
    );
  }
}
