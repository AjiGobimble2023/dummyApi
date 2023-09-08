import 'package:flutter/material.dart';

class Palette {
  /// GENERATE SHADE AND TINT LINK : https://maketintsandshades.com/
  // Primary Swatch
  static const MaterialColor kPrimarySwatch = MaterialColor(
    0xffed323e, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      50: Color(0xfffdebec), // tintColor - 0.9
      100: Color(0xfffbd6d8), // tintColor - 0.8
      200: Color(0xfff8adb2), // tintColor - 0.6
      300: Color(0xfff4848b), // tintColor - 0.4
      400: Color(0xfff15b65), // tintColor - 0.2
      500: Color(0xffed323e), // color
      600: Color(0xffd52d38), // shadeColor - 0.1
      700: Color(0xffbe2832), // shadeColor - 0.2
      800: Color(0xffa6232b), // shadeColor - 0.3
      900: Color(0xff8e1e25), // shadeColor - 0.4
    },
  );
  // Secondary Swatch
  static const MaterialColor kSecondarySwatch = MaterialColor(
    0xffffcc29,
    <int, Color>{
      50: Color(0xfffffaea), // tintColor - 0.9
      100: Color(0xfffff5d4), // tintColor - 0.8
      200: Color(0xffffeba9), // tintColor - 0.6
      300: Color(0xffffe07f), // tintColor - 0.4
      400: Color(0xffffd654), // tintColor - 0.2
      500: Color(0xffffcc29), // color
      600: Color(0xffe6b825), // shadeColor - 0.1
      700: Color(0xffcca321), // shadeColor - 0.2
      800: Color(0xffb38f1d), // shadeColor - 0.3
      900: Color(0xff997a19), // shadeColor - 0.4
    },
  );
  // Tertiary Swatch
  static const MaterialColor kTertiarySwatch = MaterialColor(
    0xff395759,
    <int, Color>{
      50: Color(0xffebeeee), // tintColor - 0.9
      100: Color(0xffd7ddde), // tintColor - 0.8
      200: Color(0xffb0bcbd), // tintColor - 0.6
      300: Color(0xff889a9b), // tintColor - 0.4
      400: Color(0xff61797a), // tintColor - 0.2
      500: Color(0xff395759), // color
      600: Color(0xff334e50), // shadeColor - 0.1
      700: Color(0xff2e4647), // shadeColor - 0.2
      800: Color(0xff283d3e), // shadeColor - 0.3
      900: Color(0xff223435), // shadeColor - 0.4
    },
  );
  // Error Swatch
  static const MaterialColor kErrorSwatch = MaterialColor(
    0xffef9f2c,
    <int, Color>{
      50: Color(0xfffdf5ea), // tintColor - 0.9
      100: Color(0xfffcecd5), // tintColor - 0.8
      200: Color(0xfff9d9ab), // tintColor - 0.6
      300: Color(0xfff5c580), // tintColor - 0.4
      400: Color(0xfff2b256), // tintColor - 0.2
      500: Color(0xffef9f2c), // color
      600: Color(0xffd78f28), // shadeColor - 0.1
      700: Color(0xffbf7f23), // shadeColor - 0.2
      800: Color(0xffa76f1f), // shadeColor - 0.3
      900: Color(0xff8f5f1a), // shadeColor - 0.4
    },
  );
  // Success Swatch
  static const MaterialColor kSuccessSwatch = MaterialColor(
    0xff4ca817,
    <int, Color>{
      50: Color(0xffedf6e8), // tintColor - 0.9
      100: Color(0xffdbeed1), // tintColor - 0.8
      200: Color(0xffb7dca2), // tintColor - 0.6
      300: Color(0xff94cb74), // tintColor - 0.4
      400: Color(0xff70b945), // tintColor - 0.2
      500: Color(0xff4ca817), // color
      600: Color(0xff449715), // shadeColor - 0.1
      700: Color(0xff3d8612), // shadeColor - 0.2
      800: Color(0xff357610), // shadeColor - 0.3
      900: Color(0xff2e650e), // shadeColor - 0.4
    },
  );
}

class CustomTheme {
  static final ThemeData lightTheme = ThemeData(
    fontFamily: 'Poppins',
    useMaterial3: true,
    colorScheme: lightColorScheme,
    textTheme: textTheme,
    hintColor: const Color.fromRGBO(0, 0, 0, 0.541),
    disabledColor: Colors.black38,
    pageTransitionsTheme: pageTransitionsTheme,
    dividerColor: Colors.black26,
    inputDecorationTheme: inputDecorationTheme,
    radioTheme: _radioThemeData,
    dividerTheme: const DividerThemeData(thickness: 0.3),
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style:
          ElevatedButton.styleFrom(surfaceTintColor: const Color(0xffed323e)),
    ),
  );

  static final RadioThemeData _radioThemeData = RadioThemeData(
    fillColor: MaterialStateProperty.resolveWith((states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
        MaterialState.selected,
      };
      if (states.any(interactiveStates.contains)) {
        return Palette.kPrimarySwatch[500];
      }
      return Colors.black38;
    }),
  );

  static const InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFFBFDFD),
      contentPadding: EdgeInsets.all(10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.black38),
      ),
      suffixIconColor: Colors.black87,
      suffixStyle: TextStyle(
          fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 14),
      prefixIconColor: Colors.black87,
      prefixStyle: TextStyle(
          fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 14),
      hintStyle: TextStyle(
          fontWeight: FontWeight.w500, color: Colors.black38, fontSize: 14));

  static const PageTransitionsTheme pageTransitionsTheme =
      PageTransitionsTheme(builders: {
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.android: CupertinoPageTransitionsBuilder(),
  });

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        height: 1.123,
        letterSpacing: 0),
    displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        height: 1.55,
        letterSpacing: 0),
    displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        height: 1.22,
        letterSpacing: 0),
    headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        height: 1.25,
        letterSpacing: 0),
    headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        height: 1.2857,
        letterSpacing: 0),
    headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: 0),
    titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        height: 1.2727,
        letterSpacing: 0),
    titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0.15),
    titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.42857,
        letterSpacing: 0.1),
    labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.42857,
        letterSpacing: 0.1),
    labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.33,
        letterSpacing: 0.5),
    labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.4545,
        letterSpacing: 0.5),
    bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.15),
    bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.42857,
        letterSpacing: 0.25),
    bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: 0.4),
  );

  static final ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    surfaceTint: const Color(0xFFFBFDFD),
    primary: Palette.kPrimarySwatch[500]!,
    onPrimary: Colors.white,
    primaryContainer: Palette.kPrimarySwatch[100]!,
    onPrimaryContainer: const Color(0xFF470f13),
    secondary: Palette.kSecondarySwatch[500]!,
    onSecondary: Colors.black87,
    secondaryContainer: Palette.kSecondarySwatch[200]!,
    onSecondaryContainer: const Color(0xFF332908),
    tertiary: Palette.kTertiarySwatch[500]!,
    onTertiary: Colors.white,
    tertiaryContainer: Palette.kTertiarySwatch[300]!,
    onTertiaryContainer: const Color(0xFF111a1b),
    error: Palette.kErrorSwatch[500]!,
    errorContainer: Palette.kErrorSwatch[200]!,
    onError: Colors.black54,
    onErrorContainer: const Color(0xFF302009),
    background: const Color(0xFFFBFDFD),
    onBackground: const Color(0xFF191C1D),
    surface: const Color(0xFFFBFDFD),
    onSurface: const Color(0xFF191C1D),
    surfaceVariant: const Color(0xFFe2e4e4),
    onSurfaceVariant: const Color(0xFF4b4c4c),
    outline: const Color(0xFF7e7f7f),
    onInverseSurface: const Color(0xFFe2e4e4),
    inverseSurface: const Color(0xFF323333),
    inversePrimary: Palette.kPrimarySwatch[300]!,
    shadow: Colors.black87,
  );

  static final ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    surfaceTint: const Color(0xFF191C1D),
    primary: Palette.kPrimarySwatch[300]!,
    onPrimary: const Color(0xFF470f13),
    primaryContainer: Palette.kPrimarySwatch[900]!,
    onPrimaryContainer: Palette.kPrimarySwatch[50]!,
    secondary: Palette.kSecondarySwatch[500]!,
    onSecondary: const Color(0xFF4c3d0c),
    secondaryContainer: Palette.kSecondarySwatch[200]!,
    onSecondaryContainer: const Color(0xFF332908),
    tertiary: Palette.kTertiarySwatch[500]!,
    onTertiary: Colors.white,
    tertiaryContainer: Palette.kTertiarySwatch[300]!,
    onTertiaryContainer: const Color(0xFF111a1b),
    error: Palette.kErrorSwatch[500]!,
    errorContainer: Palette.kErrorSwatch[200]!,
    onError: Colors.white,
    onErrorContainer: const Color(0xFF302009),
    background: const Color(0xFF191C1D),
    onBackground: const Color(0xFFE0E3E3),
    surface: const Color(0xFF191C1D),
    onSurface: const Color(0xFFE0E3E3),
    surfaceVariant: const Color(0xFF47494a),
    onSurfaceVariant: const Color(0xFFd1d2d2),
    outline: const Color(0xFF8c8e8e),
    onInverseSurface: const Color(0xFF191C1D),
    inverseSurface: const Color(0xFFFBFDFD),
    inversePrimary: Palette.kPrimarySwatch[500]!,
    shadow: Colors.black87,
  );
}
