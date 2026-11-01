import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islami/dezeen/theme.dart';

/// نفس تركيب الويردز اللي في التطبيق (ThemeProvider + ThemeSwitchingArea
/// + ThemeSwitcher.withTheme) ويثبت إن الحركة مش شغالة فعلاً.
void main() {
  testWidgets('theme switch animates between light and dark', (tester) async {
    late ThemeSwitcherState switcher;
    ThemeData activeTheme = Apptheme.lightTheme;

    await tester.pumpWidget(
      ThemeProvider(
        initTheme: Apptheme.lightTheme,
        builder: (context, myTheme) {
          return MaterialApp(
            theme: myTheme,
            home: ThemeSwitchingArea(
              child: Scaffold(
                body: Center(
                  child: ThemeSwitcher.withTheme(
                    builder: (context, s, theme) {
                      switcher = s;
                      activeTheme = theme;
                      return const SizedBox();
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    expect(activeTheme, Apptheme.lightTheme);

    // تشغيل التبديل للدارك (نفس اللي بيتعمل في settings.dart)
    switcher.changeTheme(theme: Apptheme.darkTheme);

    // في نص الحركة: لقطة الشاشة القديمة (RawImage) لازم تكون ظاهرة فوق
    await tester.pump();
    await tester.pump();
    expect(find.byType(RawImage), findsWidgets);

    // بعد نهاية الحركة: الثيم بقى الدارك والقطعة اختفت
    await tester.pumpAndSettle();
    expect(activeTheme, Apptheme.darkTheme);
    expect(find.byType(RawImage), findsNothing);
  });
}
