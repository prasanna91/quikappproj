import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickappproj/module/myapp.dart';
import 'package:quickappproj/utils/menu_parser.dart';
import 'dart:convert'; // Add this import

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Dummy test data
    const testWebUrl = "https://example.com";
    const testIsBottomMenu = true;
    const testIsSplashEnabled = false;
    const testSplashUrl = "";
    const testSplashBgUrl = "";
    const testSplashDuration = 3;
    const testSplashAnimation = "zoom";
    const testSplashTaglineColor = Colors.black;
    const testSplashBgColor = Colors.white;
    const testBottomMenuBgColor = Colors.white;
    const testBottomMenuActiveTabColor = Colors.blue;
    const testBottomMenuTextColor = Colors.black;
    const testBottomMenuIconColor = Colors.black;
    const testBottomMenuIconPosition = "above";
    const testIsDeepLink = true;
    const testIsLoadIndicator = true;
    final testBottomMenuItems = parseBottomMenuItems(jsonEncode([
      {"icon": "home", "label": "Home", "url": "https://example.com/home"},
    ]));

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: MyApp(
          webUrl: testWebUrl,
          isSplash: testIsSplashEnabled,
          splashLogo: testSplashUrl,
          splashBg: testSplashBgUrl,
          splashDuration: testSplashDuration,
          splashAnimation: testSplashAnimation,
          taglineColor: testSplashTaglineColor,
          spbgColor: testSplashBgColor,
          isBottomMenu: testIsBottomMenu,
          bottomMenuItems: testBottomMenuItems,
          isDeeplink: testIsDeepLink,
          backgroundColor: testBottomMenuBgColor,
          activeTabColor: testBottomMenuActiveTabColor,
          textColor: testBottomMenuTextColor,
          iconColor: testBottomMenuIconColor,
          iconPosition: testBottomMenuIconPosition,
          isLoadIndicator: testIsLoadIndicator,
        ),
      ),
    );

    // Assuming your app has a '+' icon and counter logic for testing
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
