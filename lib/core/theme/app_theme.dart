import 'package:flutter/material.dart';

import 'aura.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light, Aura.light);
  static ThemeData dark() => _build(Brightness.dark, Aura.dark);

  static ThemeData _build(Brightness brightness, Aura a) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF233E42),
      brightness: brightness,
    ).copyWith(
      primary: a.accent,
      onPrimary: a.onAccent,
      surface: a.bg,
      onSurface: a.ink,
      onSurfaceVariant: a.inkMuted,
      outline: a.hairline,
      error: a.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: AuraType.family,
      scaffoldBackgroundColor: a.bg,
      splashFactory: InkSparkle.splashFactory,
      iconTheme: IconThemeData(color: a.inkMuted, size: 22),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: a.accent,
        selectionColor: a.accent.withValues(alpha: 0.2),
        selectionHandleColor: a.accent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: a.bg,
        surfaceTintColor: Colors.transparent,
        indicatorColor: a.accentSoft,
        elevation: 0,
        iconTheme: WidgetStateProperty.resolveWith((st) => IconThemeData(
            color: st.contains(WidgetState.selected) ? a.accent : a.inkMuted)),
        labelTextStyle: WidgetStateProperty.resolveWith((st) => AuraType.sans(
            12, st.contains(WidgetState.selected) ? a.ink : a.inkMuted,
            weight: FontWeight.w500)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: a.surfaceSolid,
        modalBackgroundColor: a.surfaceSolid,
        showDragHandle: true,
        dragHandleColor: a.hairline,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AuraSpace.radiusL)),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: a.chrome,
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: AuraType.sans(12, a.onChrome),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: a.chrome,
        contentTextStyle: AuraType.sans(14, a.onChrome),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      extensions: [a],
    );
  }
}
