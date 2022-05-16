import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debouncer/debouncer.dart';

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
    testWidgets(
      'Displays the child widget provided',
      (WidgetTester tester) async {
        final child = Text('test');
        final action = () {};

        await tester.pumpWidget(
          MaterialApp(
            home: Debouncer(action: action, child: (_) => child),
          ),
        );

        expect(find.text('test'), findsOneWidget);
        expect(find.byWidget(child), findsOneWidget);
      },
    );

    testWidgets(
      'Finds and executes the Debouncer action if Debouncer is the button\'s parent',
      (WidgetTester tester) async {
        bool run = false;
        final action = () {
          run = true;
        };

        final buttonKey = Key('buttonKey');

        await tester.pumpWidget(
          MaterialApp(
            home: Debouncer(
              timeout: Duration(milliseconds: 1),
              action: action,
              child: (context) => TextButton(
                key: buttonKey,
                child: Container(),
                onPressed: () {
                  Debouncer.execute(context);
                },
              ),
            ),
          ),
        );

        expect(run, false);

        expect(find.byKey(buttonKey), findsOneWidget);

        await tester.tap(find.byKey(buttonKey));

        await tester.pumpAndSettle();

        expect(run, true);
      },
    );

    testWidgets(
      'Finds and executes the Debouncer action if Debouncer is the parent further up the tree',
      (WidgetTester tester) async {
        bool run = false;
        final action = () {
          run = true;
        };

        final buttonKey = Key('buttonKey');

        await tester.pumpWidget(
          MaterialApp(
            home: Debouncer(
              timeout: Duration(milliseconds: 1),
              action: action,
              child: (context) => Container(
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

        expect(run, false);

        expect(find.byKey(buttonKey), findsOneWidget);

        await tester.tap(find.byKey(buttonKey));

        await tester.pumpAndSettle();

        expect(run, true);
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
}
