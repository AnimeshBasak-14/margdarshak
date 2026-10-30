import 'package:flutter/material.dart';

/// App design tokens, built on the ZAP (Dawnlit) palette.
///
/// Light: white page, Atlantic Waves for the mic, buttons and your own chat
/// bubbles, Child of Light for cards and the composer, Aruba Aqua for the
/// soft glow that washes in from the top of each screen.
///
/// Dark: plain black with neutral grey surfaces and near-white text. The glow
/// and the voice orb turn neutral silver, so nothing tinted competes with the
/// content.
///
/// Portsmouth Bay (#A1ACAC) is too light for text on white, so it is only used
/// for borders. Deadline and eligibility states keep muted functional hues.
@immutable
class Aura extends ThemeExtension<Aura> {
  final Color bg;
  final Color bgTint;
  final Color surface; // cards, composer, assistant bubbles
  final Color surfaceSolid; // elevated / sheets
  final Color hairline;
  final Color ink;
  final Color inkMuted;
  final Color inkFaint;
  final Color accent;
  final Color accentSoft;
  final Color onAccent;
  final Color review;
  final Color danger;
  final Color info;
  final Color success;
  final Color chrome;
  final Color onChrome;
  final Color tint;
  final Color onTint;

  /// Colour that washes in from the screen edges behind the content.
  final Color glow;

  /// Mic button and your own chat bubbles, light corner first.
  final List<Color> accentGradient;

  /// Voice orb, from the specular highlight to the shadowed edge.
  final List<Color> orb;

  /// Halo around the orb.
  final Color orbHalo;

  final List<BoxShadow> shadow;
  final List<BoxShadow> elevatedShadow;

  const Aura({
    required this.bg,
    required this.bgTint,
    required this.surface,
    required this.surfaceSolid,
    required this.hairline,
    required this.ink,
    required this.inkMuted,
    required this.inkFaint,
    required this.accent,
    required this.accentSoft,
    required this.onAccent,
    required this.review,
    required this.danger,
    required this.info,
    required this.success,
    required this.chrome,
    required this.onChrome,
    required this.tint,
    required this.onTint,
    required this.glow,
    required this.accentGradient,
    required this.orb,
    required this.orbHalo,
    required this.shadow,
    required this.elevatedShadow,
  });

  static const light = Aura(
    bg: Color(0xFFFFFFFF), // Pure White
    bgTint: Color(0xFFF0F4F8), // Child of Light
    surface: Color(0xFFF0F4F8),
    surfaceSolid: Color(0xFFFFFFFF),
    hairline: Color(0x4DA1ACAC), // Portsmouth Bay, 30%
    ink: Color(0xFF010101), // Vantablack
    inkMuted: Color(0xFF5E6161), // Blackish Green
    inkFaint: Color(0xFF687070), // Slate Grey
    accent: Color(0xFF233E42), // Atlantic Waves
    accentSoft: Color(0x14233E42),
    onAccent: Color(0xFFF0F4F8),
    review: Color(0xFF8A6A2E),
    danger: Color(0xFFA5483C),
    info: Color(0xFF3F6B70),
    success: Color(0xFF2F6B55),
    chrome: Color(0xFF010101),
    onChrome: Color(0xFFF0F4F8),
    tint: Color(0xFFD2DDD4), // Aruba Aqua
    onTint: Color(0xFF010101),
    glow: Color(0xFFD2DDD4),
    accentGradient: [Color(0xFF3F6B70), Color(0xFF233E42)],
    orb: [
      Color(0xFFF0F4F8),
      Color(0xFFD2DDD4),
      Color(0xFF3F6B70),
      Color(0xFF233E42),
      Color(0xFF0F1D1F),
    ],
    orbHalo: Color(0x553F6B70),
    shadow: [
      BoxShadow(color: Color(0x0A233E42), blurRadius: 20, offset: Offset(0, 6)),
    ],
    elevatedShadow: [
      BoxShadow(
          color: Color(0x1F233E42), blurRadius: 32, offset: Offset(0, 12)),
    ],
  );

  /// Plain black. Greys are neutral on purpose.
  static const dark = Aura(
    bg: Color(0xFF000000),
    bgTint: Color(0xFF0B0B0B),
    surface: Color(0xFF111111),
    surfaceSolid: Color(0xFF161616),
    hairline: Color(0x1FFFFFFF),
    ink: Color(0xFFF2F2F2),
    inkMuted: Color(0xFFA6A6A6),
    inkFaint: Color(0xFF858585),
    accent: Color(0xFFF0F4F8),
    accentSoft: Color(0x14FFFFFF),
    onAccent: Color(0xFF010101),
    review: Color(0xFFD4B072),
    danger: Color(0xFFE88B80),
    info: Color(0xFFA1ACAC),
    success: Color(0xFF7BC9A0),
    chrome: Color(0xFF141414),
    onChrome: Color(0xFFF2F2F2),
    tint: Color(0xFF1A1A1A),
    onTint: Color(0xFFF2F2F2),
    glow: Color(0xFF262626),
    accentGradient: [Color(0xFFFFFFFF), Color(0xFFD6DADA)],
    orb: [
      Color(0xFFFFFFFF),
      Color(0xFFC9CFCF),
      Color(0xFF687070),
      Color(0xFF262626),
      Color(0xFF050505),
    ],
    orbHalo: Color(0x26FFFFFF),
    shadow: [],
    elevatedShadow: [],
  );

  @override
  Aura copyWith() => this;

  @override
  Aura lerp(covariant Aura? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    List<Color> ls(List<Color> a, List<Color> b) =>
        [for (var i = 0; i < a.length; i++) l(a[i], b[i])];
    return Aura(
      bg: l(bg, other.bg),
      bgTint: l(bgTint, other.bgTint),
      surface: l(surface, other.surface),
      surfaceSolid: l(surfaceSolid, other.surfaceSolid),
      hairline: l(hairline, other.hairline),
      ink: l(ink, other.ink),
      inkMuted: l(inkMuted, other.inkMuted),
      inkFaint: l(inkFaint, other.inkFaint),
      accent: l(accent, other.accent),
      accentSoft: l(accentSoft, other.accentSoft),
      onAccent: l(onAccent, other.onAccent),
      review: l(review, other.review),
      danger: l(danger, other.danger),
      info: l(info, other.info),
      success: l(success, other.success),
      chrome: l(chrome, other.chrome),
      onChrome: l(onChrome, other.onChrome),
      tint: l(tint, other.tint),
      onTint: l(onTint, other.onTint),
      glow: l(glow, other.glow),
      accentGradient: ls(accentGradient, other.accentGradient),
      orb: ls(orb, other.orb),
      orbHalo: l(orbHalo, other.orbHalo),
      shadow: t < 0.5 ? shadow : other.shadow,
      elevatedShadow: t < 0.5 ? elevatedShadow : other.elevatedShadow,
    );
  }
}

extension AuraContext on BuildContext {
  Aura get aura => Theme.of(this).extension<Aura>() ?? Aura.light;
}

/// Inter throughout: big tight headlines like the reference, plain body text.
class AuraType {
  AuraType._();

  static const family = 'Inter';

  static TextStyle display(double size, Color color) => TextStyle(
        fontFamily: family,
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.05,
        letterSpacing: -size * 0.04,
      );

  static TextStyle sans(double size, Color color,
          {FontWeight weight = FontWeight.w400,
          double height = 1.35,
          double letterSpacing = 0}) =>
      TextStyle(
        fontFamily: family,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  /// Key numbers ("4,500 vacancies", "3 days left") that don't jitter.
  static TextStyle digits(double size, Color color,
          {FontWeight weight = FontWeight.w600}) =>
      TextStyle(
        fontFamily: family,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: 1.1,
        letterSpacing: -size * 0.03,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}

class AuraSpace {
  AuraSpace._();
  static const double gutter = 20;
  static const double radius = 22;
  static const double radiusL = 32;
}
