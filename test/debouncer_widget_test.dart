import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:debouncer_widget/debouncer_widget.dart';

class RealClass {
  action() {}
}

class FakeClass extends Mock implements RealClass {}

class TestWidget extends StatelessWidget {
  final Widget Function(BuildContext context) builder;

  TestWidget({
    Key? key,
    require,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return builder(context);
  }
}

void main() {
  group('Debouncer', () {
    group('UI', () {
      testWidgets(
        'Displays the child widget provided',
        (WidgetTester tester) async {
          final child = Text('test');
          final action = () {};

          await tester.pumpWidget(
            MaterialApp(
              home: Debouncer(action: action, builder: (_, __) => child),
            ),
          );

          expect(find.text('test'), findsOneWidget);
          expect(find.byWidget(child), findsOneWidget);
        },
      );
    });

    group('execute', () {
      testWidgets(
        'Finds and executes the Debouncer action if Debouncer is the button\'s parent',
        (WidgetTester tester) async {
          final fake = FakeClass();

          final buttonKey = Key('buttonKey');

          await tester.pumpWidget(
            MaterialApp(
              home: Debouncer(
                timeout: Duration(milliseconds: 1),
                action: fake.action,
                builder: (context, __) => TextButton(
                  key: buttonKey,
                  child: Container(),
                  onPressed: () {
                    Debouncer.execute(context);
                  },
                ),
              ),
            ),
          );

          verifyNever(fake.action());

          expect(find.byKey(buttonKey), findsOneWidget);

          await tester.tap(find.byKey(buttonKey));

          await tester.pumpAndSettle();

          verify(fake.action()).called(1);
        },
      );

      testWidgets(
        'Finds and executes the Debouncer action if Debouncer is the parent further up the tree',
        (WidgetTester tester) async {
          final fake = FakeClass();

          final buttonKey = Key('buttonKey');

          await tester.pumpWidget(
            MaterialApp(
              home: Debouncer(
                timeout: Duration(milliseconds: 1),
                action: fake.action,
                builder: (context, __) => Container(
                  padding: EdgeInsets.all(10),
                  child: FractionallySizedBox(
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: TextButton(
                        key: buttonKey,
                        child: Container(),
                        onPressed: () {
                          Debouncer.execute(context);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          verifyNever(fake.action());

          expect(find.byKey(buttonKey), findsOneWidget);

          await tester.tap(find.byKey(buttonKey));

          await tester.pumpAndSettle();

          verify(fake.action()).called(1);
        },
      );

      testWidgets(
        'Finds and executes the Debouncer by key',
        (WidgetTester tester) async {
          final fake = FakeClass();

          final buttonKey = Key('buttonKey');

          await tester.pumpWidget(
            MaterialApp(
              home: Debouncer(
                timeout: Duration(milliseconds: 1),
                action: fake.action,
                builder: (_, theKey) => Debouncer(
                  action: () {},
                  timeout: Duration(milliseconds: 1),
                  builder: (context, __) => Container(
                    padding: EdgeInsets.all(10),
                    child: FractionallySizedBox(
                      child: Padding(
                        padding: EdgeInsets.zero,
                        child: TextButton(
                          key: buttonKey,
                          child: Container(),
                          onPressed: () {
                            Debouncer.execute(context, debouncerKey: theKey);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          verifyNever(fake.action());

          expect(find.byKey(buttonKey), findsOneWidget);

          await tester.tap(find.byKey(buttonKey));

          await tester.pumpAndSettle();

          verify(fake.action()).called(1);
        },
      );

      testWidgets(
        'throws an error if Debouncer is not used in the parent tree',
        (WidgetTester tester) async {
          final buttonKey = Key('buttonKey');

          bool threwException = false;

          await tester.pumpWidget(MaterialApp(
            home: TestWidget(
              builder: (context) => TextButton(
                key: buttonKey,
                child: Container(),
                onPressed: () {
                  try {
                    Debouncer.execute(context);
                  } catch (e) {
                    threwException = true;
                  }
                },
              ),
            ),
          ));

          await tester.tap(find.byKey(buttonKey));
          await tester.pumpAndSettle();

          expect(threwException, true);
        },
      );
    });

    group('cancel', () {
      testWidgets(
        'Finds and cancel the Debouncer action if Debouncer is the button\'s parent',
        (WidgetTester tester) async {
          final fake = FakeClass();

          final buttonKeyExecute = Key('buttonKeyExecute');
          final buttonKeyCancel = Key('buttonKeyCancel');

          await tester.pumpWidget(
            MaterialApp(
              home: Debouncer(
                timeout: Duration(seconds: 1),
                action: fake.action,
                builder: (context, __) => Row(
                  children: [
                    TextButton(
                      key: buttonKeyExecute,
                      child: Container(),
                      onPressed: () {
                        Debouncer.execute(context);
                      },
                    ),
                    TextButton(
                      key: buttonKeyCancel,
                      child: Container(),
                      onPressed: () {
                        Debouncer.cancel(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );

          verifyNever(fake.action());

          expect(find.byKey(buttonKeyExecute), findsOneWidget);
          await tester.tap(find.byKey(buttonKeyExecute));

          await tester.pumpAndSettle();

          expect(find.byKey(buttonKeyCancel), findsOneWidget);
          await tester.tap(find.byKey(buttonKeyCancel));

          await tester.pumpAndSettle();

          verifyNever(fake.action());
        },
      );

      testWidgets(
        'Finds and cancels the Debouncer action if Debouncer is the parent further up the tree',
        (WidgetTester tester) async {
          final fake = FakeClass();

          final buttonKeyExecute = Key('buttonKeyExecute');
          final buttonKeyCancel = Key('buttonKeyCancel');

          await tester.pumpWidget(
            MaterialApp(
              home: Debouncer(
                timeout: Duration(seconds: 1),
                action: fake.action,
                builder: (context, __) => Container(
                  padding: EdgeInsets.all(10),
                  child: FractionallySizedBox(
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: Row(
                        children: [
                          TextButton(
                            key: buttonKeyExecute,
                            child: Container(),
                            onPressed: () {
                              Debouncer.execute(context);
                            },
                          ),
                          TextButton(
                            key: buttonKeyCancel,
                            child: Container(),
                            onPressed: () {
                              Debouncer.cancel(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          verifyNever(fake.action());

          expect(find.byKey(buttonKeyExecute), findsOneWidget);
          await tester.tap(find.byKey(buttonKeyExecute));

          await tester.pumpAndSettle();

          expect(find.byKey(buttonKeyCancel), findsOneWidget);
          await tester.tap(find.byKey(buttonKeyCancel));

          await tester.pumpAndSettle();

          verifyNever(fake.action());
        },
      );

      testWidgets(
        'Finds and cancels the Debouncer by key',
        (WidgetTester tester) async {
          final fake = FakeClass();

          final buttonKeyExecute = Key('buttonKeyExecute');
          final buttonKeyCancel = Key('buttonKeyCancel');

          await tester.pumpWidget(
            MaterialApp(
              home: Debouncer(
                timeout: Duration(seconds: 1),
                action: fake.action,
                builder: (_, theKey) => Debouncer(
                  action: () {},
                  timeout: Duration(milliseconds: 1),
                  builder: (context, __) => Container(
                    padding: EdgeInsets.all(10),
                    child: FractionallySizedBox(
                      child: Padding(
                        padding: EdgeInsets.zero,
                        child: Row(
                          children: [
                            TextButton(
                              key: buttonKeyExecute,
                              child: Container(),
                              onPressed: () {
                                Debouncer.execute(context);
                              },
                            ),
                            TextButton(
                              key: buttonKeyCancel,
                              child: Container(),
                              onPressed: () {
                                Debouncer.cancel(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          verifyNever(fake.action());

          expect(find.byKey(buttonKeyExecute), findsOneWidget);
          await tester.tap(find.byKey(buttonKeyExecute));

          await tester.pumpAndSettle();

          expect(find.byKey(buttonKeyCancel), findsOneWidget);
          await tester.tap(find.byKey(buttonKeyCancel));

          await tester.pumpAndSettle();

          verifyNever(fake.action());
        },
      );

      testWidgets(
        'throws an error if Debouncer is not used in the parent tree',
        (WidgetTester tester) async {
          final buttonKey = Key('buttonKey');

          bool threwException = false;

          await tester.pumpWidget(MaterialApp(
            home: TestWidget(
              builder: (context) => TextButton(
                key: buttonKey,
                child: Container(),
                onPressed: () {
                  try {
                    Debouncer.cancel(context);
                  } catch (e) {
                    threwException = true;
                  }
                },
              ),
            ),
          ));

          await tester.tap(find.byKey(buttonKey));
          await tester.pumpAndSettle();

          expect(threwException, true);
        },
      );
    });
  });
}
