// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Navigation bar updates destinations when tapped', (WidgetTester tester) async {
    int mutatedIndex = -1;
    final Widget widget = _buildWidget(
      NavigationBar(
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.ac_unit),
            label: 'AC',
          ),
          NavigationDestination(
            icon: Icon(Icons.access_alarm),
            label: 'Alarm',
          ),
        ],
        onDestinationSelected: (int i) {
          mutatedIndex = i;
        },
      ),
    );

    await tester.pumpWidget(widget);

    expect(find.text('AC'), findsOneWidget);
    expect(find.text('Alarm'), findsOneWidget);

    await tester.tap(find.text('Alarm'));
    expect(mutatedIndex, 1);

    await tester.tap(find.text('AC'));
    expect(mutatedIndex, 0);
  });

  testWidgets('NavigationBar can update background color', (WidgetTester tester) async {
    const Color color = Colors.yellow;

    await tester.pumpWidget(
      _buildWidget(
        NavigationBar(
          backgroundColor: color,
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.ac_unit),
              label: 'AC',
            ),
            NavigationDestination(
              icon: Icon(Icons.access_alarm),
              label: 'Alarm',
            ),
          ],
          onDestinationSelected: (int i) {},
        ),
      ),
    );

    expect(_getMaterial(tester).color, equals(color));
  });

  testWidgets('NavigationBar adds bottom padding to height', (WidgetTester tester) async {
    const double bottomPadding = 40.0;

    await tester.pumpWidget(
      _buildWidget(
        NavigationBar(
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.ac_unit),
              label: 'AC',
            ),
            NavigationDestination(
              icon: Icon(Icons.access_alarm),
              label: 'Alarm',
            ),
          ],
          onDestinationSelected: (int i) {},
        ),
      ),
    );

    final double defaultSize = tester.getSize(find.byType(NavigationBar)).height;
    expect(defaultSize, 80);

    await tester.pumpWidget(
      _buildWidget(
        MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(bottom: bottomPadding)),
          child: NavigationBar(
            destinations: const <Widget>[
              NavigationDestination(
                icon: Icon(Icons.ac_unit),
                label: 'AC',
              ),
              NavigationDestination(
                icon: Icon(Icons.access_alarm),
                label: 'Alarm',
              ),
            ],
            onDestinationSelected: (int i) {},
          ),
        ),
      ),
    );

    final double expectedHeight = defaultSize + bottomPadding;
    expect(tester.getSize(find.byType(NavigationBar)).height, expectedHeight);
  });

  testWidgets('NavigationBar shows tooltips with text scaling ', (WidgetTester tester) async {
    const String label = 'A';

    Widget buildApp({ required double textScaleFactor }) {
      return MediaQuery(
        data: MediaQueryData(textScaleFactor: textScaleFactor),
        child: Localizations(
          locale: const Locale('en', 'US'),
          delegates: const <LocalizationsDelegate<dynamic>>[
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Navigator(
              onGenerateRoute: (RouteSettings settings) {
                return MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return Scaffold(
                      bottomNavigationBar: NavigationBar(
                        destinations: const <NavigationDestination>[
                          NavigationDestination(
                            label: label,
                            icon: Icon(Icons.ac_unit),
                            tooltip: label,
                          ),
                          NavigationDestination(
                            label: 'B',
                            icon: Icon(Icons.battery_alert),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp(textScaleFactor: 1.0));
    expect(find.text(label), findsOneWidget);
    await tester.longPress(find.text(label));
    expect(find.text(label), findsNWidgets(2));

    // The default size of a tooltip with the text A.
    const Size defaultTooltipSize = Size(14.0, 14.0);
    expect(tester.getSize(find.text(label).last), defaultTooltipSize);
    // The duration is needed to ensure the tooltip disappears.
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.pumpWidget(buildApp(textScaleFactor: 4.0));
    expect(find.text(label), findsOneWidget);
    await tester.longPress(find.text(label));
    expect(tester.getSize(find.text(label).last), Size(defaultTooltipSize.width * 4, defaultTooltipSize.height * 4));
  });

  testWidgets('Custom tooltips in NavigationBarDestination', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: NavigationBar(
            destinations: const <NavigationDestination>[
              NavigationDestination(
                label: 'A',
                tooltip: 'A tooltip',
                icon: Icon(Icons.ac_unit),
              ),
              NavigationDestination(
                label: 'B',
                icon: Icon(Icons.battery_alert),
              ),
              NavigationDestination(
                label: 'C',
                icon: Icon(Icons.cake),
                tooltip: '',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('A'), findsOneWidget);
    await tester.longPress(find.text('A'));
    expect(find.byTooltip('A tooltip'), findsOneWidget);

    expect(find.text('B'), findsOneWidget);
    await tester.longPress(find.text('B'));
    expect(find.byTooltip('B'), findsOneWidget);

    expect(find.text('C'), findsOneWidget);
    await tester.longPress(find.text('C'));
    expect(find.byTooltip('C'), findsNothing);
  });


  testWidgets('Navigation bar semantics', (WidgetTester tester) async {
    Widget _widget({int selectedIndex = 0}) {
      return _buildWidget(
        NavigationBar(
          selectedIndex: selectedIndex,
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.ac_unit),
              label: 'AC',
            ),
            NavigationDestination(
              icon: Icon(Icons.access_alarm),
              label: 'Alarm',
            ),
          ],
        ),
      );
    }

    await tester.pumpWidget(_widget());

    expect(
      tester.getSemantics(find.text('AC')),
      matchesSemantics(
        label: 'AC\nTab 1 of 2',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        isSelected: true,
        hasTapAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.text('Alarm')),
      matchesSemantics(
        label: 'Alarm\nTab 2 of 2',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        hasTapAction: true,
      ),
    );

    await tester.pumpWidget(_widget(selectedIndex: 1));

    expect(
      tester.getSemantics(find.text('AC')),
      matchesSemantics(
        label: 'AC\nTab 1 of 2',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        hasTapAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.text('Alarm')),
      matchesSemantics(
        label: 'Alarm\nTab 2 of 2',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        isSelected: true,
        hasTapAction: true,
      ),
    );
  });

  testWidgets('Navigation bar semantics with some labels hidden', (WidgetTester tester) async {
    Widget _widget({int selectedIndex = 0}) {
      return _buildWidget(
        NavigationBar(
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          selectedIndex: selectedIndex,
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.ac_unit),
              label: 'AC',
            ),
            NavigationDestination(
              icon: Icon(Icons.access_alarm),
              label: 'Alarm',
            ),
          ],
        ),
      );
    }

    await tester.pumpWidget(_widget());

    expect(
      tester.getSemantics(find.text('AC')),
      matchesSemantics(
        label: 'AC\nTab 1 of 2',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        isSelected: true,
        hasTapAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.text('Alarm')),
      matchesSemantics(
        label: 'Alarm\nTab 2 of 2',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        hasTapAction: true,
      ),
    );

    await tester.pumpWidget(_widget(selectedIndex: 1));

    expect(
      tester.getSemantics(find.text('AC')),
      matchesSemantics(
        label: 'AC\nTab 1 of 2',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        hasTapAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.text('Alarm')),
      matchesSemantics(
        label: 'Alarm\nTab 2 of 2',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        isSelected: true,
        hasTapAction: true,
      ),
    );
  });

  testWidgets('Navigation bar does not grow with text scale factor', (WidgetTester tester) async {
    const int animationMilliseconds = 800;

    Widget _widget({double textScaleFactor = 1}) {
      return _buildWidget(
        MediaQuery(
          data: MediaQueryData(textScaleFactor: textScaleFactor),
          child: NavigationBar(
            animationDuration: const Duration(milliseconds: animationMilliseconds),
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.ac_unit),
                label: 'AC',
              ),
              NavigationDestination(
                icon: Icon(Icons.access_alarm),
                label: 'Alarm',
              ),
            ],
          ),
        ),
      );
    }

    await tester.pumpWidget(_widget());
    final double initialHeight = tester.getSize(find.byType(NavigationBar)).height;

    await tester.pumpWidget(_widget(textScaleFactor: 2));
    final double newHeight = tester.getSize(find.byType(NavigationBar)).height;

    expect(newHeight, equals(initialHeight));
  });
}

Widget _buildWidget(Widget child) {
  return MaterialApp(
    theme: ThemeData.light(),
    home: Scaffold(
      bottomNavigationBar: Center(
        child: child,
      ),
    ),
  );
}

Material _getMaterial(WidgetTester tester) {
  return tester.firstWidget<Material>(
    find.descendant(of: find.byType(NavigationBar), matching: find.byType(Material)),
  );
}
